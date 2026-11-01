#!/usr/bin/env python3
"""Download vetted CC0 production assets and leave auditable provenance.

Run on a build runner with external network access; never from the live game.
Requires Python 3.10+ standard library. Does not fetch any credential or user data.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import os
from pathlib import Path
import re
import struct
import tempfile
import time
from urllib.parse import urlparse
from urllib.request import Request, urlopen

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "assets" / "production"
MAX_MODEL_BYTES = 32 * 1024 * 1024
MAX_TEXTURE_BYTES = 12 * 1024 * 1024
MAX_TOTAL_BYTES = 92 * 1024 * 1024
USER_AGENT = "ProjectNexus-CC0-AssetImport/2.4 (https://github.com/inexxone-art/Nexus-project)"
MODEL_HOSTS = {"raw.githubusercontent.com", "cdn.3dassets.dev"}
POLY_API = "https://api.polyhaven.com"
MATERIALS = {
    "roof": ("roof_tiles", "2k"),
    "rock": ("rock_face", "2k"),
    "grass": ("forest_ground_04", "2k"),
    "asphalt": ("asphalt_01", "2k"),
    "wood": ("wood_planks", "1k"),
    "plaster": ("plastered_wall", "1k"),
    "concrete": ("t_concrete_wall_002", "1k"),
}
CANDIDATES = {
    "car": {
        "url": "https://raw.githubusercontent.com/JaronKBragg7337/spectral-gt-rs/main/spectral_gt_rs_game_ready.glb",
        "page": "https://github.com/JaronKBragg7337/spectral-gt-rs",
        "author": "JaronKBragg7337", "license": "CC0-1.0",
        "filename": "vortex_sport.glb", "front": "+X", "hero_id": "CAR_041",
    },
    "helicopter": {
        "url": "https://cdn.3dassets.dev/assets/32807/v1/model.glb",
        "page": "https://3dassets.dev/assets/aircraft-fleet-and-airfield-medium-twin-air-ambulance-52d4f7fc",
        "author": "3DAssets.dev", "license": "CC0-1.0",
        "filename": "alpin_h1.glb", "front": "+Z", "hero_id": "HELI_01",
    },
}
EXCAVATOR_PACK = "https://3dassets.dev/api/v1/packs/demolition-and-site-clearance"


def https_get(url: str, limit: int, hosts: set[str] | None = None) -> bytes:
    host = (urlparse(url).hostname or "").lower()
    if urlparse(url).scheme != "https":
        raise ValueError(f"Refusing non-HTTPS URL: {url}")
    if hosts is not None and host not in hosts:
        raise ValueError(f"Source host not approved: {host}")
    last_error: Exception | None = None
    for attempt in range(3):
        try:
            req = Request(url, headers={"User-Agent": USER_AGENT, "Accept": "*/*"})
            with urlopen(req, timeout=60) as res:
                final_host = (urlparse(res.geturl()).hostname or "").lower()
                if hosts is not None and final_host not in hosts:
                    raise ValueError(f"Redirect to unexpected host: {final_host}")
                length = int(res.headers.get("Content-Length", "0"))
                if length > limit:
                    raise ValueError(f"Asset too large ({length} bytes): {url}")
                data = res.read(limit + 1)
                if len(data) > limit:
                    raise ValueError(f"Asset exceeds size limit: {url}")
                return data
        except (OSError, TimeoutError) as exc:
            last_error = exc
            if attempt < 2:
                time.sleep(2 + attempt * 3)
    raise OSError(f"Download failed: {url}: {last_error}")


def read_glb_header(data: bytes) -> dict:
    if len(data) < 28 or len(data) > MAX_MODEL_BYTES:
        raise ValueError("GLB byte length invalid")
    magic, version, claimed = struct.unpack_from("<4sII", data, 0)
    if (magic, version, claimed) != (b"glTF", 2, len(data)):
        raise ValueError("Invalid glTF/GLB v2 header")
    length, chunk = struct.unpack_from("<I4s", data, 12)
    if chunk != b"JSON" or length < 12 or 20 + length > len(data):
        raise ValueError("Missing GLB JSON chunk")
    meta = json.loads(data[20:20 + length].decode("utf-8"))
    if meta.get("asset", {}).get("version") != "2.0" or not meta.get("meshes"):
        raise ValueError("GLB lacks glTF 2.0 meshes")
    for extension in meta.get("extensionsRequired", []):
        if extension not in {"KHR_mesh_quantization", "KHR_materials_unlit", "KHR_texture_transform", "KHR_materials_emissive_strength", "KHR_materials_clearcoat", "KHR_materials_ior"}:
            raise ValueError(f"Model needs unverified glTF extension: {extension}")
    # Imported models may contain legitimate clips that need remapping to NEXUS controls.
    return {
        "mesh_count": len(meta["meshes"]),
        "material_count": len(meta.get("materials", [])),
        "animation_names": [x.get("name", "unnamed") for x in meta.get("animations", [])],
        "node_names": [x.get("name", "") for x in meta.get("nodes", [])][:150],
        "required_extensions": meta.get("extensionsRequired", []),
    }


def store(target: Path, data: bytes) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    with tempfile.NamedTemporaryFile(dir=target.parent, suffix=".tmp", delete=False) as temp:
        temp.write(data)
        temporary = Path(temp.name)
    try:
        os.replace(temporary, target)
    finally:
        temporary.unlink(missing_ok=True)


def url_from_model_item(record: dict) -> str:
    for field in ("cdnUrl", "cdn_url", "downloadUrl", "download_url", "modelUrl", "glbUrl", "fileUrl", "url"):
        candidate = record.get(field)
        if isinstance(candidate, str) and candidate.startswith("https://cdn.3dassets.dev/") and candidate.endswith(".glb"):
            return candidate
    model = record.get("model")
    if isinstance(model, dict):
        candidate = url_from_model_item(model)
        if candidate:
            return candidate
    ident = record.get("id") or record.get("assetId")
    if isinstance(ident, int) or (isinstance(ident, str) and ident.isdecimal()):
        return f"https://cdn.3dassets.dev/assets/{ident}/v1/model.glb"
    return ""


def find_excavator(pack: object) -> str:
    """Find the 22 t digging-bucket model, not the hydraulic-breaker variant."""
    matches = []
    def walk(item: object) -> None:
        if isinstance(item, list):
            for element in item:
                walk(element)
        elif isinstance(item, dict):
            label = " ".join(str(item.get(k, "")) for k in ("name", "title", "slug", "assetName")).lower()
            if "excavator" in label and ("digging bucket" in label or "digging-bucket" in label):
                if "breaker" not in label and "high reach" not in label:
                    uri = url_from_model_item(item)
                    if uri:
                        matches.append(uri)
            for val in item.values():
                if isinstance(val, (list, dict)):
                    walk(val)
    walk(pack)
    return matches[0] if matches else ""


def poly_file_url(files: dict, channel: str, resolution: str) -> tuple[str, str]:
    aliases = {
        "albedo": ("Diffuse", "diffuse", "diff", "albedo", "Color", "color"),
        "normal": ("nor_gl", "NormalGL", "normal_gl", "normal", "Normal"),
        "roughness": ("Rough", "rough", "Roughness", "roughness"),
    }
    for name in aliases[channel]:
        actual = next((k for k in files if k.lower() == name.lower()), None)
        if actual is None:
            continue
        variants = files[actual]
        if not isinstance(variants, dict):
            continue
        for res in (resolution, "1k"):
            options = variants.get(res, {})
            if not isinstance(options, dict):
                continue
            for ext in (("jpg", "png") if channel == "albedo" else ("png", "jpg")):
                item = options.get(ext)
                if isinstance(item, dict) and isinstance(item.get("url"), str):
                    return item["url"], ext
    raise ValueError(f"Poly Haven channel {channel} unavailable at {resolution}")


def import_assets(destination: Path, *, with_materials: bool, with_models: bool, require_excavator: bool) -> dict:
    manifest: dict = {"version": 1, "notice": "Licensing provenance for built-in original or CC0 production meshes and materials; not a photorealism certification.", "models": {}, "materials": {}}
    used_bytes = 0
    if with_models:
        candidates = dict(CANDIDATES)
        try:
            pack = json.loads(https_get(EXCAVATOR_PACK, 2 * 1024 * 1024, {"3dassets.dev"}))
            excavator_url = find_excavator(pack)
            if excavator_url:
                candidates["excavator"] = {"url": excavator_url, "page": "https://3dassets.dev/packs/demolition-and-site-clearance", "author": "3DAssets.dev", "license": "CC0-1.0", "filename": "excavator_22t.glb", "front": "+Z", "hero_id": "EXC_02", "note": "22-tonne animated tracked excavator; intentionally NOT described as a 14-ton machine."}
            elif require_excavator:
                raise ValueError("No digging-bucket excavator URL found in the source pack")
            else:
                print("WARNING: 22t excavator unavailable in pack manifest; retain existing 14t procedural mesh")
        except (ValueError, OSError) as error:
            if require_excavator:
                raise
            print(f"WARNING: Excavator lookup failed: {error}")
        for name, cfg in candidates.items():
            blob = https_get(cfg["url"], MAX_MODEL_BYTES, MODEL_HOSTS)
            info = read_glb_header(blob)
            used_bytes += len(blob)
            if used_bytes > MAX_TOTAL_BYTES:
                raise ValueError("Global asset size budget exceeded")
            target = destination / "vehicles" / cfg["filename"]
            store(target, blob)
            entry = {"filename": target.name, "sha256": hashlib.sha256(blob).hexdigest(), "size_bytes": len(blob), **cfg, **info}
            entry.pop("url", None)
            entry["source_url"] = cfg["url"]
            manifest["models"][name] = entry
            print(f"MODEL {name}: {target.name}, {len(blob):,} bytes, {info['mesh_count']} meshes")
    if with_materials:
        for name, (poly_id, resolution) in MATERIALS.items():
            api_url = f"{POLY_API}/files/{poly_id}"
            files = json.loads(https_get(api_url, 3 * 1024 * 1024, {"api.polyhaven.com"}))
            manifest["materials"][name] = {"asset": poly_id, "license": "CC0-1.0", "page": f"https://polyhaven.com/a/{poly_id}", "channels": {}}
            for channel in ("albedo", "normal", "roughness"):
                url, extension = poly_file_url(files, channel, resolution)
                host = (urlparse(url).hostname or "").lower()
                if host not in {"dl.polyhaven.org", "polyhaven.com", "cdn.polyhaven.com"}:
                    raise ValueError(f"Unexpected Poly Haven image host: {host}")
                img = https_get(url, MAX_TEXTURE_BYTES, {host})
                if extension == "png" and img[:8] != b"\x89PNG\r\n\x1a\n":
                    raise ValueError(f"Invalid PNG for {name}/{channel}")
                if extension == "jpg" and img[:3] != b"\xff\xd8\xff":
                    raise ValueError(f"Invalid JPEG for {name}/{channel}")
                used_bytes += len(img)
                if used_bytes > MAX_TOTAL_BYTES:
                    raise ValueError("Global asset size budget exceeded")
                target = destination / "materials" / f"{name}_{channel}.{extension}"
                store(target, img)
                manifest["materials"][name]["channels"][channel] = {"file": target.name, "sha256": hashlib.sha256(img).hexdigest(), "size_bytes": len(img), "source_url": url}
                print(f"PBR {name}/{channel}: {target.name}, {len(img):,} bytes")
    store(destination / "ASSET_PROVENANCE.json", (json.dumps(manifest, indent=2, ensure_ascii=False) + "\n").encode("utf-8"))
    return manifest


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--destination", type=Path, default=OUT)
    parser.add_argument("--models-only", action="store_true")
    parser.add_argument("--materials-only", action="store_true")
    parser.add_argument("--require-excavator", action="store_true")
    args = parser.parse_args()
    if args.models_only and args.materials_only:
        parser.error("Select --models-only or --materials-only, not both")
    result = import_assets(args.destination, with_materials=not args.models_only, with_models=not args.materials_only, require_excavator=args.require_excavator)
    print(f"DONE: {len(result['models'])} GLB models and {len(result['materials'])} PBR material sets")


if __name__ == "__main__":
    main()
