from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
checks={
    'scripts/world.gd':['const EPISODE_SCRIPT','episode_one.bind_player(player)','episode_one.try_interact(player.global_position)','episode_one.shoot(start,end','"episode_one": episode_one.get_data()','episode_one.restore_data(parsed.get("episode_one",{}))'],
    'scripts/nexus_episode_one.gd':['class_name NexusEpisodeOne','func try_interact','func shoot(','func _damage_enemy','func restore_data','func get_data'],
    'scripts/nexus_ship_walkthrough.gd':['class_name NexusShipWalkthrough','func try_interact','func restore_data'],
    'scripts/nexus_actor_rig.gd':['class_name NexusActorRig','func animate_motion'],
    'scripts/player.gd':['const ACTOR_RIG','func take_damage','func receive_medical_help'],
    'tests/episode_v22_smoke.gd':['func _run()','world.save_state()','world.load_state()'],
}
for path, needles in checks.items():
    source=(ROOT/path).read_text()
    for needle in needles:
        assert needle in source,(path,needle)
print('NEXUS V2.2 STATIC PASS: mission state machine, combat, character rig, persistence integration')
