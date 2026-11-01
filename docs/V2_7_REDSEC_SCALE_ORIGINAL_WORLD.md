# PROJECT NEXUS V2.7 — Original multi-city map, quality foundations

Reference intent: large multi-zone open-world gameplay, architectural variety, vertical routes and vehicle traversability as in large contemporary shooter maps. This is **not** a Battlefield REDSEC replica or a claim of Battlefield 6/GTA 6 graphical quality.

## Code-added Alpine map regions (persistent positions)

- **Aurelia** `(-135,86)` — glass luxury towers (16 skyline structures), warm windows, podiums, roof terraces and a district plaza
- **Stahlhafen** `(-165,-112)` — industrial warehouses, rooftop ventilators, steel reconstruction frames
- **Silberküste** `(-175,166)` — marina water, piers, hotels and waterside promenade
- **Bergstadt** `(12,177)` — alpine timber houses, balconies, stone church and bell tower
- **Adlerklamm** `(175,168)` — 82 m long 10 m wide collider bridge over the carved V2.6 canyon, crash barriers, piers, railings

Existing NEXUS City, Bergrettung, Sektor 31, Alpendorf, industrial mission zones and spaceport remain. New asphalt roads join the regions visually; a future navigation mesh, traffic AI, bridge ramps, surface blending and real streaming are required.

## Per-planet varied constructions

Six unique architectural kits, placed on existing generated planet terrain after ruins: terran outpost; desert windbreak neighborhoods; polar insulated bases; jungle raised walkway habitats; volcanic thermal plants; alien crystal towers. Locations are chosen to avoid primary mission points. Geometry is provisional; none are 3D-scanned photoreal assets.

## Quality & performance

- High, Balanced and Mobile profiles via existing performance panel.
- City scenic visibility distance culled, high-detail glazing only in desktop profile and near player.
- Repeated tower windows are batched through a MultiMesh rather than separate draw calls.
- Asphalt/rock/wood/roof/concrete surfaces load properly licensed PBR assets if packaged; colors remain fallback.
- Existing mission/vehicle/player collision preserved; bridge and primary buildings have colliders.

## Important limitations

This is a **playable integrated alpha world pass** only after headless Godot CI passes. It does not equal ultra-photorealism: procedural towers and buildings need high-poly modular architecture with bespoke UVs, realistic facade atlases, interior streaming, physical sky and GI calibration, optimized vegetation, terrain material splatting, traffic/navmesh/occlusion and extensive gameplay/console/device testing. A full REDSEC-scale authored AAA map is a large team-years production task. Current playable land stays constrained by the V2.6 terrain extents ±230 m; visible new districts are not square kilometers.

Use real engine screenshots to evaluate appearance. Concept references are **not** evidence of in-game graphics.
