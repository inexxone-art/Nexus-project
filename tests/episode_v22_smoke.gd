extends SceneTree
## Replays the story as an actual Godot scene and exercises save/restore.
const EP = preload("res://scripts/nexus_episode_one.gd")
func _initialize() -> void:
    call_deferred("_run")

func _fail(msg: String) -> void:
    push_error("BERGLICHT SMOKE: " + msg)
    quit(1)

func _run() -> void:
    var scene: PackedScene = load("res://scenes/main.tscn")
    if scene == null:
        _fail("No Alpine scene")
        return
    var world: Node3D = scene.instantiate()
    root.add_child(world)
    await process_frame
    await process_frame
    var ep: NexusEpisodeOne = world.episode_one
    if ep == null or ep.enemies.size() != 2:
        _fail("Episode or 3D drone actors missing")
        return
    if ep.stage != 0 or ep.try_interact(Vector3(200,0,200)).get("handled",false):
        _fail("Mission must only interact near target")
        return
    for phase in range(4):
        var result: Dictionary = ep.try_interact(EP.WAYPOINTS[phase])
        if not result.get("handled",false) or ep.stage != phase+1:
            _fail("Mission progression broken at %d"%phase)
            return
    if ep.try_interact(EP.TRANSMITTER).get("handled",false):
        _fail("Combat stage skipped by interaction")
        return
    for i in range(2):
        var drone: StaticBody3D = ep.enemies[i]
        if not drone.visible or drone.collision_layer == 0:
            _fail("Active combat drone has no visibility or collision")
            return
        for hit in range(3):
            ep._damage_enemy(i)
    if ep.stage != 5 or ep.enemy_hp != [0,0]:
        _fail("Combat stage did not complete")
        return
    var money: int = world.coins
    for phase in range(5,8):
        world.player.global_position = EP.WAYPOINTS[phase]
        world._interact()
        if ep.stage != phase+1:
            _fail("Mission did not reach stage %d"%(phase+1))
            return
    if world.coins != money+EP.REWARD or world.completed_jobs < 1:
        _fail("Completion reward and job count mismatch")
        return
    world._interact()
    if world.coins != money+EP.REWARD:
        _fail("Duplicate chapter completion payout")
        return
    world.player.health = 24.0
    world.player.invulnerable_time = 0.0
    world._on_episode_damage(8.0)
    if world.player.health != 16.0:
        _fail("Combat damage not applied")
        return
    world._on_episode_damage(8.0)
    if world.player.health != 16.0:
        _fail("Damage invulnerability window missing")
        return
    world.player.invulnerable_time = 0.0
    world._on_episode_damage(100.0)
    if world.player.health != 100.0 or world.coins < 0:
        _fail("Player recovery after defeat missing")
        return
    var snapshot: Dictionary = ep.get_data()
    ep.restore_data({})
    if ep.completed or ep.stage != 0:
        _fail("Empty / legacy restore did not initialize mission")
        return
    ep.restore_data(snapshot)
    if not ep.completed or ep.stage != 8 or ep.enemies[0].visible:
        _fail("Completed chapter restore lost state")
        return
    var ship: NexusShipWalkthrough = world.ship_walkthrough
    if ship == null:
        _fail("Spacecraft interior not integrated")
        return
    world.player.global_position = NexusShipWalkthrough.BOARDING + Vector3(0,1,0)
    var boarding: Dictionary = ship.try_interact(world.player,{"scanner":true})
    if not boarding.get("handled",false) or not ship.crew_aboard:
        _fail("Boarding ship from physical airlock failed")
        return
    world.player.global_position = NexusShipWalkthrough.CONSOLE + Vector3(0,1.2,0)
    var cockpit: Dictionary = ship.try_interact(world.player,{"scanner":true})
    if not cockpit.get("handled",false) or not str(cockpit.get("message", "")).contains("SCANNER"):
        _fail("Walkable cockpit does not reflect purchased ship modules")
        return
    world.player.global_position = NexusShipWalkthrough.DOCK + Vector3(0,1.2,6.1)
    var departure: Dictionary = ship.try_interact(world.player,{"scanner":true})
    if not departure.get("handled",false) or ship.crew_aboard:
        _fail("Spacecraft exit failed")
        return
    if world.player.rig == null or world.player.rig.legs.size() != 2:
        _fail("Character articulated rig missing")
        return
    world.player.global_position = NexusShipWalkthrough.BOARDING + Vector3(0,1.0,0)
    ship.try_interact(world.player,{})
    world.save_state()
    ep.restore_data({})
    ship.restore_data({})
    world.load_state()
    if not ep.completed or world.coins != maxi(0,money+EP.REWARD-50) or not ship.crew_aboard:
        _fail("Full save/load lost episode or payout")
        return
    print("NEXUS V2.2 BERGLICHT PASS: 8 phases, two drones, progression, rig, payouts, persistence")
    world.queue_free()
    await process_frame
    quit(0)
