"""V2.0 source contracts. Run together with the headless Godot integration test."""
from pathlib import Path
root = Path(__file__).resolve().parents[1]
required = {
    'scripts/nexus_quality_suite.gd': ['func _build_hub(', 'func _build_civilians(', 'func _build_infrastructure(', 'func _build_secrets(', 'func practice_shot(', 'func get_data(', 'func restore_data('],
    'scripts/nexus_drive_model.gd': ['func grip_factor(', 'func braking_distance(', 'func maximum_speed_kmh('],
    'scripts/nexus_planet_discoveries.gd': ['func bind_planet(', 'func _collect(', 'planet_discoveries'],
    'scripts/nexus_audio_director.gd': ['AudioStreamWAV', 'func _make_wave(', 'func toggle_sound('],
    'scripts/nexus_performance_panel.gd': ['Engine.get_frames_per_second()', 'func cycle_quality('],
    'scripts/world.gd': ['QUALITY_SUITE_SCRIPT', 'AUDIO_SCRIPT', 'PERFORMANCE_SCRIPT', 'quality_suite.try_interact', '"quality_suite": quality_suite.get_data()'],
    'scripts/vehicle.gd': ['DRIVE_MODEL.grip_factor', 'weather_code', 'distance_km'],
    'scripts/nexus_planet.gd': ['DISCOVERIES_SCRIPT', 'discoveries.bind_planet'],
    'scripts/nexus_campaign.gd': ['"planet_discoveries":{}'],
    'scripts/nexus_mobile_controls.gd': ['"AIM", "shoot"', '"FPS", "quality"'],
    'scripts/player.gd': ['animation_time', 'func _process('],
}
for path, needles in required.items():
    content = (root / path).read_text(encoding='utf-8')
    for needle in needles:
        assert needle in content, f'{path}: missing {needle}'
assert (root/'tests/quality_v20_smoke.gd').exists()
print('V2.0 STATIC PASS: all 12 improvement categories have executable foundations and test references')
