from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
world=(ROOT/'scripts/world.gd').read_text()
layout=(ROOT/'scripts/nexus_world_structure.gd').read_text()
assert 'world_structure.bind_actor(player)' in world
assert 'world_structure.apply_graphics_tier(mode)' in world
assert 'find_road_route' in layout and 'get_district_at' in layout
assert 'MultiMesh.new()' in layout and 'UPDATE_INTERVAL' in layout
for name in ('alpendorf','rettungsbasis','sektor31','stadt','bauhof','industrie','raumhafen'):
    assert f'"{name}"' in layout
print('NEXUS V2.5 static world structure PASS')
