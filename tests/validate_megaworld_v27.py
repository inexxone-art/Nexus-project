from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
world = (ROOT/'scripts/world.gd').read_text()
planet = (ROOT/'scripts/nexus_planet.gd').read_text()
map_code = (ROOT/'scripts/nexus_megamap_v27.gd').read_text()
planet_code = (ROOT/'scripts/nexus_planet_cities_v27.gd').read_text()
assert 'mega_map = MEGAMAP_SCRIPT.new()' in world
assert 'mega_map.set_actor(player)' in world
assert 'mega_map.set_graphics_tier(mode)' in world
assert 'planet_cities.configure(biome' in planet
for identifier in ('aurelia','stahlhafen','silberkueste','bergstadt','canyon'):
    assert f'"{identifier}"' in map_code
for biome in ('alpine','desert','ice','jungle','volcanic','alien'):
    assert f'"{biome}"' in planet_code
assert 'bridge_deck' in map_code and 'StaticBody3D' in map_code
print('V2.7 megamap source contracts PASS')
