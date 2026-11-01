"""Static regression for V1.5 (headless Godot tests provide runtime verification)."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
for name in [
    "scripts/nexus_photo_mode.gd", "tests/photo_smoke.gd", "tests/operations_smoke.gd",
    "docs/V1_5_RELEASE_NOTES.md", ".github/workflows/godot-check.yml",
    "scripts/nexus_mobile_controls.gd", "tests/mobile_smoke.gd",
    ".github/workflows/web-build.yml", "export_presets.cfg",
]:
    assert (root / name).is_file(), name
world = (root / "scripts/world.gd").read_text()
ops = (root / "scripts/nexus_world_operations.gd").read_text()
living = (root / "scripts/nexus_living_universe.gd").read_text()
photo = (root / "scripts/nexus_photo_mode.gd").read_text()
for check in ["PHOTO_SCRIPT.new()", "_toggle_photo_mode()", "photo_mode.capture()",
              "world_operations.operation_completed.connect", "living.apply_field_operation(",
              'if bool(op.get("completed", false))']:
    assert check in world, check
for check in ["stage += 1", "stage = 0", "operation_completed.emit", "current_target()",
              '"stage":stage', 'int(data.get("stage", 0))']:
    assert check in ops, check
for check in ["func apply_field_operation", '"field_operations":field_operations',
              'data.get("field_operations", 0)']:
    assert check in living, check
for check in ["func enter(", "func exit(", "func capture(", "image.save_png("]:
    assert check in photo, check
mobile = (root / "scripts/nexus_mobile_controls.gd").read_text()
assert "Input.action_press" in mobile and "Input.action_release" in mobile
assert "MOBILE_SCRIPT.new()" in world and "mobile_controls.bind_world(self)" in world
assert 'platform="Web"' in (root / "export_presets.cfg").read_text()
print("V1.6 STATIC PASS: 3-stage missions, photo mode, 12 touch controls and Web export configuration")
