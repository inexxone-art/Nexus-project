#!/usr/bin/env python3
"""Asset-intake audit: verifies .glb structure and PBR inputs without external packages.

Use: python tools/audit_production_assets.py
No media are downloaded. This does not guarantee visible photorealism.
"""
from __future__ import annotations
import json
import struct
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PRODUCTION = ROOT / 'assets/production'
VEHICLES = {
    'CAR_041': ('vortex_sport.glb', ['Wheel_FL','Wheel_FR','Wheel_RL','Wheel_RR']),
    'HELI_01': ('alpin_h1.glb', ['Rotor_Main','Rotor_Tail']),
    'EXC_02': ('excavator_14t.glb', ['Boom','Bucket']),
}
MATERIALS = ['asphalt','rock','roof','plaster','wood','grass','concrete']


def scan_glb(path: Path) -> dict:
    raw = path.read_bytes()
    if len(raw) < 20:
        return {'ok': False, 'error': 'GLB smaller than 20 bytes'}
    magic, version, length = struct.unpack_from('<III', raw, 0)
    if magic != 0x46546C67 or version != 2 or length != len(raw):
        return {'ok': False, 'error': 'Invalid glTF 2.0 GLB header or size'}
    chunk_len, chunk_type = struct.unpack_from('<II', raw, 12)
    if chunk_type != 0x4E4F534A or 20 + chunk_len > len(raw):
        return {'ok': False, 'error': 'Missing or truncated GLB JSON chunk'}
    try:
        model = json.loads(raw[20:20+chunk_len].decode('utf-8').strip('\x00 \n'))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        return {'ok': False, 'error': f'Invalid GLB JSON: {exc}'}
    if model.get('asset', {}).get('version') != '2.0':
        return {'ok': False, 'error': 'glTF asset version != 2.0'}
    return {
        'ok': True,
        'bytes': len(raw),
        'nodes': [str(n.get('name','')) for n in model.get('nodes', [])],
        'meshes': len(model.get('meshes',[])),
        'materials': len(model.get('materials',[])),
        'textures': len(model.get('textures',[])),
        'images': len(model.get('images',[])),
        'animations': len(model.get('animations',[])),
    }


def report() -> dict:
    assets = {'vehicles': {}, 'materials': {}, 'warnings': []}
    for vehicle_id,(filename,rig) in VEHICLES.items():
        path = PRODUCTION / 'vehicles' / filename
        if not path.exists():
            assets['vehicles'][vehicle_id] = {'present': False, 'filename': filename, 'status': 'procedural-fallback'}
            continue
        result = scan_glb(path)
        result['present'] = True
        result['filename'] = filename
        if result.get('ok'):
            result['missing_optional_rig_nodes'] = [n for n in rig if n not in result['nodes']]
            if result['meshes'] < 1:
                assets['warnings'].append(f'{filename}: no meshes found')
        assets['vehicles'][vehicle_id] = result
    for material in MATERIALS:
        assets['materials'][material] = {
            channel: (PRODUCTION / 'materials' / f'{material}_{channel}.png').is_file()
            for channel in ('albedo','normal','roughness','metallic')
        }
    if any(v.get('present') for v in assets['vehicles'].values()):
        assets['warnings'].append('Confirm license/provenance for all supplied models before distribution.')
    return assets


if __name__ == '__main__':
    print(json.dumps(report(), ensure_ascii=False, indent=2))
