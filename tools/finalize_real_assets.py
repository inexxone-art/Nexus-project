#!/usr/bin/env python3
"""Record output hashes after glTF Transform dequantization for Godot 4.4."""
from __future__ import annotations
import hashlib
import json
from pathlib import Path
from import_real_assets import OUT, read_glb_header


def finalize(folder: Path = OUT) -> dict:
    manifest_path = folder / 'ASSET_PROVENANCE.json'
    manifest = json.loads(manifest_path.read_text(encoding='utf-8'))
    for name, entry in manifest.get('models', {}).items():
        path = folder / 'vehicles' / entry['filename']
        data = path.read_bytes()
        parsed = read_glb_header(data)
        if 'KHR_mesh_quantization' in parsed.get('required_extensions', []):
            raise ValueError(f'{name}: still requires KHR_mesh_quantization; Godot 4.4 cannot import it')
        entry['original_source_sha256'] = entry.get('sha256')
        entry['sha256'] = hashlib.sha256(data).hexdigest()
        entry['size_bytes'] = len(data)
        entry['normalized_for_godot_4_4'] = entry['sha256'] != entry['original_source_sha256']
        entry.update(parsed)
        print(f'FINAL GLB {name}: {len(data):,} bytes, dequantized={entry["normalized_for_godot_4_4"]}')
    manifest_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False)+'\n',encoding='utf-8')
    return manifest


if __name__ == '__main__':
    finalize()
