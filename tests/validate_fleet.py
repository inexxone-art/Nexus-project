"""Static structural checks for V1.3 fleet and cinematic campaign. No Godot runtime guarantee."""
from pathlib import Path
import json
root=Path(__file__).resolve().parents[1]
records=json.loads((root/'data/vehicle_catalog.json').read_text(encoding='utf-8'))['vehicles']
groups={}
for item in records:
    assert item['id'] and item['name'] and 5<item['top_kmh']<360
    assert item['acceleration']>0 and item['length']>2 and item['width']>1
    groups[item['group']]=groups.get(item['group'],0)+1
assert groups=={'Autos':70,'Panzer':20,'Helikopter':10,'Bagger':3,'Nutzfahrzeuge':20},groups
assert len(records)==len({r['id'] for r in records})==123
for f in ['scripts/nexus_vehicle_catalog.gd','scripts/nexus_fleet_menu.gd','scripts/nexus_world_operations.gd','scripts/nexus_lore.gd','scripts/nexus_set_dressing.gd','tests/fleet_smoke.gd']:
    assert (root/f).exists(),f
for texture in ['nexus_pbr_forest','nexus_pbr_alpine','nexus_pbr_sand','nexus_pbr_ice','nexus_pbr_lava','nexus_pbr_umbra','nexus_pbr_wet_street','nexus_pbr_stone']:
    assert (root/'assets'/f'{texture}.png').exists()
    assert (root/'assets'/f'{texture}_normal.png').exists()
world=(root/'scripts/world.gd').read_text()
for phrase in ['_make_fleet_menu()', 'world_operations.try_interact(', 'world_operations.get_data()', 'CATALOG_SCRIPT.by_id(', 'FLEET_MENU_SCRIPT.new()']:
    assert phrase in world,phrase
print('PASS: 123 unique vehicle IDs, five categories, 16 PBR textures, world integration')
print('NOTE: procedural model variants are NOT individually sculpted 3D assets')
