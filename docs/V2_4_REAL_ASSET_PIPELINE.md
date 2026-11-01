# PROJECT NEXUS V2.4 – genuine CC0 asset integration

This release introduces *real third-party 3D meshes and photographed PBR materials*, not a claim of photorealistic AAA gameplay. V2.3 procedural models remain if a download/import fails.

## Models

| Vehicle | Original source | Approx. source poly count / notes | License | Orientation |
|---|---|---|---|---|
| CAR_041 Vortex | [Spectral GT RS](https://github.com/JaronKBragg7337/spectral-gt-rs) | detailed Blender authoring, cockpit, animation clips, 4.7 MB GLB | CC0 1.0 | +X model → -Z game |
| HELI_01 Alpin H1 | [Air Ambulance Twin](https://3dassets.dev/assets/aircraft-fleet-and-airfield-medium-twin-air-ambulance-52d4f7fc) | ~35k tris, 8 rotor/door clips, material palette (not photographic textures) | CC0 1.0 | +Z → -Z |
| EXC_02 excavator | [Demolition and Site Clearance](https://3dassets.dev/packs/demolition-and-site-clearance) | **22-tonne**, roughly 2.3k tris, animatable boom/bucket; optional import; **low-poly**, not photoreal | CC0 1.0 | +Z → -Z |

The code fetches directly from the source at build time, checks GLB header/chunks and texture content signatures, calculates SHA-256, and commits the provenance manifest with files in the asset branch. For each asset, sources and exact downloaded checksums are in `assets/production/ASSET_PROVENANCE.json` once the action has run.

**Important:** GLB animation clips and named nodes will only control the car wheels/rotors/bucket after their imported node names are mapped to the existing movement system. The models are physical visual assets, not full realistic vehicle dynamics or professional rigged animations.

## Photographed PBR materials (Poly Haven, CC0)

- `roof_tiles` → roof
- `rock_face` → rock
- `forest_ground_04` → grass/soil
- `asphalt_01` → asphalt
- `wood_planks` → wood
- `plastered_wall` → plaster
- `t_concrete_wall_002` → concrete

Official source: https://polyhaven.com/license; API: https://api.polyhaven.com. Imports prefer 2K for prominent surfaces, 1K for minor details, each with albedo, OpenGL-normal and roughness channels. The high-res sources are not included in the source-only ZIP; they are downloaded in Actions and reviewed for legal use and integrity.

## Quality modes

**Mobile/Browser:** SSR, SSIL and volumetric fog disabled, lower-resolution textures/LODs recommended. **Desktop cinematic:** SSAO, SSIL, SSR, volumetric fog and glow enabled where supported. Actual FPS must be measured on target hardware, not inferred from CI headless tests.

## Workflow

1. `python3 -m unittest discover -s tests -p 'test_real_asset_importer.py'`
2. `python3 tools/import_real_assets.py` (requires internet)
3. Godot 4.4.1 `--editor --import --headless`, check parse/import diagnostics.
4. `godot --headless --path . --script res://tests/real_assets_smoke.gd`.
5. Only on successful import/test, commit binary assets to a separate GitHub branch for review/merge.
6. Capture the *real* Godot scene, compare to the six original graphics target references, and profile GPU/texture memory.

## Not yet complete

The models/photographed materials improve visual fidelity but do not guarantee film-quality lighting, terrain scans, forests, character meshes, destruction, fully animated controls, multi-player or a completed story. Quality assessment requires rendered game footage and device testing. Never present concept art as real gameplay.
