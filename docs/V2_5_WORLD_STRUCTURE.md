# PROJECT NEXUS V2.5 — Alpine Region Structure and Performance

## Geographically coherent sectors

Seven zones: **Alpendorf, Bergrettung, Sektor 31, NEXUS City, Wiederaufbau, Industrie, Raumhafen**. The existing playable 460m × 460m flat terrain, existing missions, buildings, factories, cars, and six-planet campaign are preserved.

`nexus_world_structure.gd` introduces:
- Named, connected road routing via explicit waypoint edges (`find_road_route`), including links from the starting garage to all seven zones.
- Deterministic district lookup by proximity (`get_district_at`) rather than random building coordinates.
- Continuous visually legible connector roads with lane markers and shoulders; district-specific sidewalks, safety barriers, materials, helipad and cargo cues.
- MultiMesh foliage, named scene chunks and range-based scenic culling. **No gameplay collisions are unloaded**, only visual enhancements. `apply_graphics_tier(0/1/2)` disables detail on mobile, activates reduced-distance details in balanced mode, and extended range on cinematic mode.
- Actual downloaded Poly Haven PBR textures are applied where available; otherwise safe material fallbacks.

## Limits and next steps

This is **world-layout and LOD infrastructure**, not yet a AAA scanned mountainous terrain or full open-world streaming pipeline. Existing zones still sit on a flat collision plane; authentic alpine roads require authored heightfields, road mesh conforming, terrain collisions, paths/navigation, navmesh baking, licensed high-poly architecture and foliage LOD0/LOD1/LOD2. The data layout allows later migration to terrain streaming without rewriting mission IDs or driving logic.

## Acceptance

`tests/world_structure_v25_smoke.gd` checks all district graph routes, detail culling on low graphics, far-area hiding, and unchanged vehicle/station counts. `tests/validate_world_structure_v25.py` checks integration contract. Godot import and scene runtime are the authoritative checks; static Python success alone is insufficient.
