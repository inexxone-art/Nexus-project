#!/usr/bin/env python3
"""Download genuine 2k CC0 rock scans from Poly Haven with MD5 verification.
Official source https://polyhaven.com/a/rock_moss_set_02
API https://api.polyhaven.com/files/rock_moss_set_02
Credits: Powered by Poly Haven. Asset artist: Kless Gyzen.
This is genuine photogrammetry, NOT an AI-generated picture.
"""
from __future__ import annotations
from pathlib import Path
from urllib.request import Request, urlopen
import hashlib
import json
import sys

API="https://api.polyhaven.com/files/"
OUT=Path(sys.argv[1] if len(sys.argv)>1 else "build/cc0_scanned_rocks")
OUT.mkdir(parents=True,exist_ok=True)
ASSET_IDS=("rock_moss_set_02",)
HEADER={"User-Agent":"NEXUS-UE5-CC0-AssetInstaller/1.0"}
def download_checked(url,path,md5,expected_max_bytes):
    if not url.startswith("https://dl.polyhaven.org/"):
        raise ValueError("Only official Poly Haven CDN paths are allowed.")
    req=Request(url,headers=HEADER)
    dig=hashlib.md5()
    total=0
    path.parent.mkdir(parents=True,exist_ok=True)
    with urlopen(req,timeout=45) as response, open(path,"wb") as out:
        while True:
            data=response.read(256*1024)
            if not data:break
            total+=len(data)
            if total>expected_max_bytes:
                raise ValueError(f"Asset too large: {url}")
            dig.update(data)
            out.write(data)
    if dig.hexdigest()!=md5:
        path.unlink(missing_ok=True)
        raise ValueError(f"Checksum mismatch {path.name}")
    return total

def main():
    report={
        "source":"https://polyhaven.com",
        "rights":"CC0-1.0",
        "api_credit":"Powered by Poly Haven",
        "author":"Kless Gyzen",
        "asset_ids":list(ASSET_IDS),
        "resolution":"2k",
        "files":[]
    }
    for asset in ASSET_IDS:
        with urlopen(Request(API+asset,headers=HEADER),timeout=30) as req:
            manifest=json.load(req)
        item=manifest["gltf"]["2k"]["gltf"]
        records={f"{asset}/{asset}_2k.gltf":item}
        for filename,metadata in item.get("include",{}).items():
            records[f"{asset}/{filename}"]=metadata
        for relative,meta in records.items():
            actual=OUT/relative
            size=download_checked(meta["url"],actual,meta["md5"],200*1024*1024)
            report["files"].append({"path":relative,"md5":meta["md5"],"bytes":size,"origin":meta["url"]})
            print(f"CC0 PHOTO-SCAN VERIFIED {relative}: {size} bytes")
    # Convert the full downloaded glTF scene + 2K maps into ONE portable GLB.
    # The original glTF remains included for provenance and manual UE import.
    import trimesh
    source=OUT/"rock_moss_set_02"/"rock_moss_set_02_2k.gltf"
    scene=trimesh.load(source,force="scene")
    triangles=sum(len(m.faces) for m in scene.geometry.values())
    if triangles<10000:
        raise ValueError(f"Low-poly model unexpected: {triangles} faces")
    glb=OUT/"SM_NEXUS_ScannedRockSet.glb"
    glb.write_bytes(scene.export(file_type="glb"))
    verify=trimesh.load(glb,force="scene")
    assert sum(len(m.faces) for m in verify.geometry.values())==triangles
    report["converted_glb"]={"file":glb.name,"triangles":triangles,
        "bytes":glb.stat().st_size,"sha256":hashlib.sha256(glb.read_bytes()).hexdigest()}
    print("REAL CC0 PHOTO-SCANNED GLB VERIFIED",triangles,"triangles")
    (OUT/"CC0_PROVENANCE.json").write_text(json.dumps(report,indent=2),encoding="utf-8")
    (OUT/"README_CC0.txt").write_text(
        "Rock Moss Set 02 by Kless Gyzen, Poly Haven, CC0-1.0.\n"
        "https://polyhaven.com/a/rock_moss_set_02\n"
        "Powered by Poly Haven.\n"
        "This is a photogrammetry-derived rock asset with real PBR textures.\n"
        "Unreal Editor can import the .gltf; textures and .bin must remain alongside it.\n",
        encoding="utf-8")
    assert len(report["files"])>=4
    print("NEXUS_CC0_PHOTOSCANS_VERIFIED",len(report["files"]))
if __name__=="__main__": main()
