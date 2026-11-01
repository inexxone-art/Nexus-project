# PROJECT NEXUS V2.2 — Operation Berglicht

## What is implemented
- Original eight-phase first chapter: briefing, emergency power, mountain search, casualty care, drone encounter, data recovery, transmitter calibration and return to HQ.
- Two localized moving 3D drones with health, hit detection via physics ray casts, basic short-range attacks, and player respawn with bounded treatment charge.
- Payout is one-time only (950 game euros). World operation and character chronicle updates are connected to completion.
- Checkpoint / stage / drone HP / player health save and restore without corrupting existing V2.1 saves.
- Articulated procedural playable character rig: torso, head, left/right arms and legs with walk-run swing. This is NOT high-end skinned motion capture.
- Stationary **walkable spaceship interior** at `(72,0,84)` with airlock, cabin, cockpit and module display tied to purchased upgrades. Not a flyable spacecraft.
- Original playable mission props: power substation, rescue stretcher, field console and communications relay. Low-poly procedural art.
- Touch **AIM** button or left-click can hit the drones; E / touchscreen interaction progresses in-world objectives.

## Story objective order
1. HQ briefing at `(-17, 0, 31)`
2. Restore emergency power near `(8, 0, 41)`
3. Find a missing person in the canyon near `(77, 0, 75)`
4. Stabilize the casualty at the same site
5. Disable two defensive drones near `(117, 0, 109)` using combat input
6. Recover the data carrier at the same site
7. Calibrate spaceport signal at `(55, 0, 66)`
8. Return to HQ for debrief, then continue free roam

## Test/quality boundaries
- This is a **vertical slice**. It is not the promised 48-hour fully produced campaign.
- Drone movement and attack are basic and locally simulated; not a production-grade tactical AI.
- Production-quality character animations, photorealistic scanned car meshes/city interiors, complex physics destruction and authoritative networked multiplayer remain missing.
- Automated Godot headless tests verify scenes, state and mechanics but cannot verify visual photorealism, art direction or performance on a real iPhone.
- `tests/episode_v22_smoke.gd` exercises sequence, collision actors, one-time payout, save/load, and rig presence.
