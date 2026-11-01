from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
checks={
 'scripts/nexus_production_assets.gd':['class_name NexusProductionAssets','create_hero_instance','vortex_sport.glb','alpin_h1.glb','excavator_22t.glb','surface_texture'],
 'scripts/nexus_weather_surface.gd':['class_name NexusWeatherSurface','make_road_material','set_clock','wetness'],
 'shaders/nexus_wet_asphalt.gdshader':['shader_type spatial;','uniform float wetness','ROUGHNESS = mix'],
 'scripts/nexus_vehicle_visuals.gd':['PRODUCTION.create_hero_instance','_bind_imported_rig','imported_model != null'],
 'scripts/world.gd':['weather_surface.make_road_material','Geneigtes Ziegeldach','Schornstein','Balkonstrebe','PRODUCTION_ASSETS.surface_texture'],
}
for path,needles in checks.items():
 source=(ROOT/path).read_text(encoding='utf8')
 for needle in needles:
  assert needle in source, (path,needle)
assert (ROOT/'assets/production/README.md').exists()
print('V2.3 GRAPHICS STATIC PASS: PBR asset slots, procedural village, rain-linked wet road shader, GLB hero substitution')
