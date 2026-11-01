extends SceneTree
## Run with Godot 4.4.1 --headless --path . --script res://tests/quality_v20_smoke.gd
const QUALITY = preload("res://scripts/nexus_quality_suite.gd")
const DRIVE = preload("res://scripts/nexus_drive_model.gd")
const DISCOVERY = preload("res://scripts/nexus_planet_discoveries.gd")
const CAMPAIGN = preload("res://scripts/nexus_campaign.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(msg: String, code: int) -> void:
    push_error("NEXUS QUALITY V2.0: " + msg)
    quit(code)

func _run() -> void:
    if DRIVE.grip_factor("car",0) <= DRIVE.grip_factor("car",3):
        _fail("snow grip must be lower than dry grip",1)
        return
    if DRIVE.braking_distance(18.0,0.55) <= DRIVE.braking_distance(18.0,1.0):
        _fail("low grip must increase game braking distance",2)
        return
    var scene: PackedScene = load("res://scenes/main.tscn")
    if scene == null:
        _fail("main world not found",3)
        return
    var world: Node3D = scene.instantiate()
    root.add_child(world)
    await process_frame
    await process_frame
    if world.quality_suite == null or world.audio_director == null or world.performance_panel == null:
        _fail("quality, audio or quality panel missing",4)
        return
    var suite: NexusQualitySuite = world.quality_suite
    if suite.civilian_nodes.size() != 4 or suite.infrastructure.size() != 3 or suite.secrets.size() != 3:
        _fail("living world NPC/infrastructure/secrets missing",5)
        return
    var d: Dictionary = suite.try_interact(QUALITY.HUB + Vector3(0,0,5.9),3000)
    if not bool(d.get("handled",false)) or not suite.door_open:
        _fail("operations hub door interaction missing",6)
        return
    d = suite.try_interact(QUALITY.INFRA_POSITIONS[0],0)
    if int(d.get("money",0)) != 0 or int(suite.infrastructure[0]["condition"]) == 100:
        _fail("unaffordable repair should not be applied",7)
        return
    d = suite.try_interact(QUALITY.INFRA_POSITIONS[0],3000)
    if int(d.get("money",0)) != -75 or int(suite.infrastructure[0]["condition"]) != 100:
        _fail("infrastructure repair interaction broken",8)
        return
    d = suite.try_interact(QUALITY.SECRET_POSITIONS[0],3000)
    if not bool(d.get("handled",false)) or int(d.get("money",0)) != 115:
        _fail("world secret first discovery failed",9)
        return
    d = suite.try_interact(QUALITY.SECRET_POSITIONS[0],3000)
    if bool(d.get("handled",false)):
        _fail("hidden discovery can be duplicated",10)
        return
    var snapshot: Dictionary = suite.get_data()
    suite.restore_data({"conditions":[20,20,20],"found":[false,false,false],"score":0})
    suite.restore_data(snapshot)
    if not bool(suite.secrets[0]["found"]) or int(suite.infrastructure[0]["condition"]) != 100:
        _fail("world persistent state could not roundtrip",11)
        return
    world._on_graphics_profile(0)
    if world.performance_panel.mode != 0 or world.quality_suite.enabled_scenery:
        _fail("mobile performance quality profile failed",12)
        return
    world._on_graphics_profile(2)
    if not world.quality_suite.enabled_scenery:
        _fail("cinematic profile failed",13)
        return
    var parent := Node3D.new()
    root.add_child(parent)
    var planet_secrets: NexusPlanetDiscoveries = DISCOVERY.new()
    parent.add_child(planet_secrets)
    var explorer := Node3D.new()
    parent.add_child(explorer)
    var shared: Dictionary = CAMPAIGN.default_data()
    planet_secrets.bind_planet(explorer,"umbra",shared)
    planet_secrets._collect(0)
    if planet_secrets.remaining() != 2 or not shared.get("planet_discoveries",{}).get("umbra",[]).has(0):
        _fail("planet exploration did not persist discovery",14)
        return
    planet_secrets._collect(0)
    if int(shared.get("credits",0)) != 275:
        _fail("duplicate planet bonus",15)
        return
    print("NEXUS V2.0 QUALITY SMOKE PASS: world, interiors, citizen schedule, repairs, secrets, driving, audio, settings, planet persistence")
    world.queue_free()
    parent.queue_free()
    await process_frame
    quit(0)
