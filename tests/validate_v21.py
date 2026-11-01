from pathlib import Path

root = Path(__file__).resolve().parents[1]
world = (root/'scripts/world.gd').read_text()
vehicle = (root/'scripts/vehicle.gd').read_text()
legacy = (root/'scripts/nexus_legacy.gd').read_text()
ui = (root/'scripts/nexus_legacy_panel.gd').read_text()
assert 'const LEGACY_SCRIPT' in world and 'var legacy: NexusLegacy' in world
assert '"legacy": legacy.get_data()' in world and 'legacy.restore_data(parsed.get("legacy",{}))' in world
assert '"tune":' in world and '_apply_vehicle_tuning' in world
assert 'var tune_motor: int' in vehicle and 'tune_brakes' in vehicle
assert 'func upgrade_vehicle' in legacy and 'func restore_data' in legacy
assert 'func refresh' in ui and 'func toggle' in ui
for filename in ('tests/legacy_logic_smoke.gd','tests/legacy_world_smoke.gd'):
    assert (root/filename).is_file()
print('NEXUS V2.1 STATIC INTEGRATION PASS')
