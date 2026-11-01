"""V1.8 source contract checks; Godot headless checks are separate."""
from pathlib import Path
import json
root=Path(__file__).resolve().parents[1]
hero=(root/'scripts/nexus_hero_vehicles.gd').read_text()
visual=(root/'scripts/nexus_vehicle_visuals.gd').read_text()
menu=(root/'scripts/nexus_fleet_menu.gd').read_text()
records={item['id']:item for item in json.loads((root/'data/vehicle_catalog.json').read_text())['vehicles']}
assert len(records)==123
assert all(key in records for key in ('CAR_041','HELI_01','EXC_02'))
for name in ('_build_sportscar','_build_mountain_rescue','_build_medium_excavator','animate_hero'):
 assert 'func '+name+'(' in hero,name
for part in ('performance brake caliper','rescue searchlight','hydraulic piston rod','original nexus emblem'):
 assert part in hero.lower(),part
assert 'HERO_DETAILS.new()' in visual
assert 'hero_details.call("animate_hero"' in visual
for token in ('_make_showcase_buttons','_on_preview_input','_jump_to_showcase'):
 assert token in menu
assert (root/'tests/hero_vehicle_smoke.gd').exists()
for name in ('hero_carbon_albedo.png','hero_carbon_normal.png','hero_brushed_metal_normal.png','hero_painted_metal_normal.png'):
 assert (root/'assets'/name).is_file(), name
print('V1.8 HERO PASS: vehicle ID integrity, three detail builders, mobile preview wiring')
