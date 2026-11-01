# PROJECT NEXUS V3.4 – Adlerklamm physics slice

## Playable features
- Original V2.7 Megamap, story, six fictional planets, assets and mission data remain intact.
- A 82 m Alpine road bridge can enter an interactive collapse state near Adlerklamm (world center X=175, Z=168).
- Press **F7** when within 100 m of the bridge to start the disaster.
- The initial static bridge is hidden and its collision disabled. Twelve rigid bridge sections replace it; the pieces separate with staggered impulses.
- A procedural rescue bus is a RigidBody3D with physical collision, wheel meshes, passenger windows, windscreen, stripes and lamps. It tumbles into the canyon, with CPU-based dust plumes.
- After approximately 9 seconds, **F7** can rebuild the bridge for **10 wood + 6 iron**. A successful build pays **420 in-game credits**.
- The destroyed/rebuilt status is written to the existing Alpine savegame in the adlerklamm key and restored.
- The skyline beyond Adlerklamm includes six modular industrial highrises with facade glazing instances, setbacks, roof plant, cranes and stacks. These are **scenic models only**.

## Verification
GitHub Actions: existing Godot 4.4.1 import and game regressions plus tests/adlerklamm_v34_smoke.gd for bridge startup, 12 physical parts, bus release, rebuilding, persistence and skyline geometry.

## Quality limitations
This is a physics and architecture **prototype** built from engine primitives. It is **not** photorealistic scan geometry, an engineered structural-failure solver, professional animation, a fully scripted rescue campaign, online networked physics, or the AAA-quality reference provided by the user. Collision and physics require testing in real graphics mode before judging visual fidelity or frame rate. The game has not acquired professional 3D/character/audio assets in this change.

## Future improvements
Replace placeholders with licensed, independently modeled rock faces, buildings and buses; add level-of-detail for scenic towers, bespoke crash animation/deformation, procedural surface decals, terrain-integrated road closure, NPC rescue triggers and client-host state synchronization. A staged rebuild with cranes, construction NPCs and logistics is pending.
