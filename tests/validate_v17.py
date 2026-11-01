"""V1.7 contract checks for distinct vehicle art and show-room preview.
Run Godot CI separately: static checks cannot validate the full renderer.
"""
from pathlib import Path
import json

root = Path(__file__).resolve().parents[1]
visual = (root / 'scripts/nexus_vehicle_visuals.gd').read_text(encoding='utf-8')
vehicle = (root / 'scripts/vehicle.gd').read_text(encoding='utf-8')
menu = (root / 'scripts/nexus_fleet_menu.gd').read_text(encoding='utf-8')
workflow = (root / '.github/workflows/godot-check.yml').read_text(encoding='utf-8')
data = json.loads((root / 'data/vehicle_catalog.json').read_text(encoding='utf-8'))
assert len(data['vehicles']) == 123
assert {v['kind'] for v in data['vehicles']} == {'car', 'tank', 'helicopter', 'excavator', 'utility'}
assert len({v['id'] for v in data['vehicles']}) == 123
for fn in ['_build_car', '_build_utility', '_build_tank', '_build_helicopter', '_build_excavator', '_wheel', '_loft', 'animate_vehicle']:
    assert f'func {fn}(' in visual, fn
for token in ['Fahrzeugkollision','visuals.animate_vehicle','VISUAL_SCRIPT.new()']:
    assert token in vehicle, token
for token in ['SubViewportContainer','_show_vehicle','_spawn_selected','VISUALS.new()']:
    assert token in menu, token
assert 'vehicle_detail_smoke.gd' in workflow
assert (root / 'tests/vehicle_detail_smoke.gd').exists()
print('PASS: V1.7 detailed five-class vehicle assembly, showroom and CI integration')
