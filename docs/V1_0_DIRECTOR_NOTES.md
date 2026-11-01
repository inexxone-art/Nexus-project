# PROJECT NEXUS V1.0 – NEXUS DIRECTOR Prototype

Added a deterministic event scheduler with four event types, resource gating, cooldown, bounded event history, HUD notifications and save/load persistence. This is a prototype: events are narrative alerts, not completed interactive mission chains. No generative AI, network multiplayer, or new combat is claimed. Existing V0.9 content is preserved.

## Manual checks in Godot 4.3+
1. Import project.godot and start main scene.
2. Wait 180 seconds in-game: an event notice should appear.
3. Press F5, then F9; director event/history should restore.
4. Confirm pre-existing driving, missions and map still work.

Godot runtime is not installed in the editing environment; engine parsing and gameplay are unverified.
