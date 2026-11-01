extends Node3D
## REAL GODOT V3.7 CAPTURE — 10 seconds at 20 fps.
## The camera is scripted. All geometry, lighting, physics and HUD originate
## in the running game engine. This is NOT footage from the concept image.
const GAME_WORLD = preload("res://scripts/world.gd")
const MAX_SECONDS := 10.0
var elapsed := 0.0
var started := false
var game: Node3D
var bridge: NexusAdlerklammDisaster
var camera: Camera3D
var capture_ui: Label

func _ready() -> void:
    game = GAME_WORLD.new()
    game.name = "NEXUS V3.7 — original in-engine capture"
    add_child(game)
    bridge = game.mega_map.canyon_disaster
    if game.player != null:
        game.player.active = false
        game.player.camera.current = false
    if game.reference_hud != null:
        game.reference_hud.visible = true
    # Hide only legacy debug UI panels. The real V3.6 tactical HUD stays.
    if game.has_node("HUD"):
        game.get_node("HUD").hide()
    camera = Camera3D.new()
    camera.name = "Recording perspective — live game camera"
    camera.fov = 55.0
    camera.near = 0.1
    camera.far = 900.0
    add_child(camera)
    camera.current = true
    var layer := CanvasLayer.new()
    layer.layer = 95
    add_child(layer)
    capture_ui = Label.new()
    capture_ui.position = Vector2(20,12)
    capture_ui.add_theme_font_size_override("font_size",14)
    capture_ui.add_theme_color_override("font_color",Color("e9e7e0"))
    layer.add_child(capture_ui)
    print("NEXUS V3.7 ACTUAL IN-ENGINE GAME FOOTAGE READY")

func _process(delta: float) -> void:
    elapsed += delta
    if camera == null or bridge == null:
        get_tree().quit(2)
        return
    if elapsed > 1.70 and not started:
        started = true
        # Trigger the SAME scene/physics method as the live game mission.
        # It is a scripted replay for filming, not actual player input.
        bridge.start_disaster()
        game.nexus_v35.rescue.trigger()
        game.notice = "HINTER DIR! BUS ABGESTUERZT — BERGUNG BEGINNT"
        game.notice_time = 5.0
    if elapsed > 5.0 and game.nexus_v35.rescue.phase == "choice":
        game.nexus_v35._select_role("pilot")
    if elapsed < 1.7:
        var t := clampf(elapsed/1.7,0.0,1.0)
        camera.global_position = Vector3(150.0,13.0,230.0).lerp(Vector3(153.0,9.0,209.0),t)
        camera.look_at(Vector3(175.0,-3.0,166.0),Vector3.UP)
    elif elapsed < 5.6:
        var t := clampf((elapsed-1.7)/3.9,0.0,1.0)
        camera.global_position = Vector3(153.0,9.0,209.0).lerp(Vector3(162.0,4.8,194.0),t)
        camera.look_at(Vector3(175.0,-9.0,163.0),Vector3.UP)
    else:
        var t := clampf((elapsed-5.6)/4.4,0.0,1.0)
        camera.global_position = Vector3(162.0,4.8,194.0).lerp(Vector3(184.0,8.0,199.0),t)
        camera.look_at(Vector3(175.0,-12.0,169.0),Vector3.UP)
    capture_ui.text = "ORIGINAL GODOT V3.7 GAMEPLAY  |  PHYSIK / ADLERKLAMM  |  KEIN KI-VIDEO"
    if elapsed >= MAX_SECONDS:
        print("NEXUS CAPTURE 10s COMPLETE")
        get_tree().quit()
