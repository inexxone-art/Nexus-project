# PROJECT NEXUS V2.0 — World Quality Slice (Alpha)

**Godot 4.4.1 / Forward+**. All twelve requested categories have *limited working prototypes*, not AAA production-complete systems.

Start with `project.godot`. Alpine: WASD/F/E/G/F6/F3/F4/J/F10. Touch: arrow/action buttons + AIM/FPS.
See [docs/V2_0_QUALITY_SLICE.md](docs/V2_0_QUALITY_SLICE.md) for the precise status of each area, interaction locations, test gates and missing assets.

- 123 *data profiles* across vehicle categories. Detailed original three hero prototypes, not 123 manually sculpted photorealistic vehicles.
- Persistent world incidents, six replayable multi-stage operations, workshop, exploration, simplified NPCs and interactable headquarters.
- Six planet prototypes with discoveries, not seamless atmospheric travel.
- Original procedural sound placeholders, three graphics profiles and an experimental browser preview.
- No claim of completed 48-hour campaign or production-ready four-player co-op.

```sh
python3 tests/validate_v20.py
# On a system with Godot 4.4.1:
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/quality_v20_smoke.gd
```

CI: `.github/workflows/godot-check.yml`. Echte FPS nur am Gerät prüfen; keine Behauptung einer garantierten Framerate.
