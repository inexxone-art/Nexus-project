# PROJECT NEXUS V2.1 — LEGACY & PLAYER AGENCY (ALPHA)

## Functional additions
- Persisted avatar identity, cosmetic preset and six career choices (these are **text/data presets**, not completed character mesh editing).
- Repeatable mission XP and level/skill-point progression; rewarded only on completed objectives and real repairs/discoveries, not repeated NPC conversations.
- Four contacts in the operations hub, recorded once per NPC in the relationship ledger.
- Vehicle-model upgrades: motor (speed/acceleration), tires (adhesion), brakes (deceleration), 3 ranks each and escalating prices. Applies to spawned vehicles and survives world saves. Does **not** replace arcade vehicle physics with a physical simulation.
- Persistent ownership registry for workshop, house and outpost; buildings remain representations in the registry, **not freely placeable furnished house interiors**.
- Spaceship module registry: scanner, cargo bay and medbay as persistent investments; full walkable spacecraft, flight physics and module interiors remain future work.
- Unique planetary discovery and decision APIs, 100-entry bounded chronicle.
- Touch-compatible profile/upgrade/chronicle panel; F2 on keyboard and on-screen button for mobile.
- Backward-compatible migration: old world saves without `legacy` initialize with defaults.

## 12-category status (NOT fully mature)
| Area | V2.1 present | Remaining to mature |
|---|---|---|
| Photorealistic rendering | Existing PBR prototypes and quality settings | Licensed AAA meshes, materials, authored lighting, performance budget and visual comparisons |
| Vehicle physics | Wet/snow grip + purchasable speed/grip/braking upgrades | Suspension, tire model, robust collisions, deformation and sound |
| Playable interiors | Operations hub | Populated buildings with streaming, NPC navigation and content |
| NPC behavior | 4 scheduled decorative NPCs + persisted introductions | Navmesh, agendas, systemic dialogue and memory |
| Combat & missions | Existing combat training and multi-step operations | Full tactical AI, polished weapons, cutscenes and narrative scripts |
| Damage & rebuilding | 3 repairable sites + paid construction | Building damage states, debris simulation and supply networks |
| Space & planets | Six prototype biomes + module ownership | Seamless travel, high-detail assets, planetary ecosystems |
| Animations | Basic character/vehicle procedural animation | Rigged hero actors, mocap-quality animation |
| Weather | Wet/snow vehicle modifiers, local FX | Regional weather model and environment simulation |
| Secrets | Persisted local/planetary discoveries and new API | Deep authored puzzles and multi-planet quest chains |
| Audio | Existing synthesized original audio FX | High-quality positional audio, licensed score and voice |
| Mobile, co-op and longevity | Touch profile panel, experimental LAN co-op, legacy progression | Tested iPhone performance and fully authoritative 4-player networking |

## Input and gameplay
- F2 or the new **KARRIERE / TUNING / CHRONIK** world button opens character, career, property, spacecraft, tuning, talent and chronicle tabs.
- Vehicle upgrades require an actual spawned catalog vehicle; tune via its ID in the panel after entering it. Existing seven starter vehicles are also eligible by category.
- Purchased ownership only unlocks persistent ownership state. Full 3D house construction and freely furnished interiors require subsequent art and gameplay.
- All purchases apply currency only on success and reject duplicates or insufficient funds.
- Save F5 / load F9 persists the complete new legacy state alongside prior V2.0 saves.

## Verification
- `python3 tests/validate_v21.py`
- `Godot --headless --path . --script res://tests/legacy_logic_smoke.gd`
- `Godot --headless --path . --script res://tests/legacy_world_smoke.gd`
- Existing V2.0 CI smoke and HTML5 export must also pass before the release is promoted from development branch.
