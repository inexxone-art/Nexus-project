extends Node3D
## Actual V2.2 Godot gameplay capture. The scene is recorded by the engine's own MovieMaker.
## The camera is scripted, but everything visible is rendered from PROJECT NEXUS assets/code.
const GAME_WORLD = preload("res://scripts/world.gd")
const LENGTH_SECONDS: float = 13.0
var elapsed: float = 0.0
var game: Node3D
var camera: Camera3D
var sports: Node3D
var heli: Node3D
var overlay: Label
var stage_label: Label

func _ready() -> void:
    game = GAME_WORLD.new()
    game.name = "PROJECT NEXUS V2.2 - Original Gameplay"
    add_child(game)
    if game.player != null:
        game.player.active = false
        game.player.camera.current = false
    # Only cinematic HUD is recorded, never fake gameplay elements.
    for node in game.find_children("*", "CanvasLayer", true, false):
        node.visible = false
    if game.vehicles.size() >= 7:
        sports = game.vehicles[2]
        sports.global_position = Vector3(-64, 0.14, 0)
        sports.rotation.y = -PI/2.0
        sports.set_control(true)
        sports.camera.current = false
        heli = game.vehicles[6]
    camera = Camera3D.new()
    camera.fov = 63.0
    camera.near = 0.08
    add_child(camera)
    camera.current = true
    _make_overlay()
    print("NEXUS_CAPTURE_READY: Original V2.2 game world loaded")

func _make_overlay() -> void:
    var ui := CanvasLayer.new()
    ui.layer = 90
    ui.name = "Source-Capture Overlay"
    add_child(ui)
    overlay = Label.new()
    overlay.text = "PROJECT NEXUS   /   ORIGINAL GODOT GAMEPLAY   /   V2.2 ALPHA"
    overlay.position = Vector2(28, 20)
    overlay.add_theme_color_override("font_color", Color("dffaf5"))
    overlay.add_theme_color_override("font_shadow_color", Color.BLACK)
    overlay.add_theme_constant_override("shadow_offset_x", 2)
    overlay.add_theme_constant_override("shadow_offset_y", 2)
    overlay.add_theme_font_size_override("font_size", 21)
    ui.add_child(overlay)
    stage_label = Label.new()
    stage_label.position = Vector2(30, 65)
    stage_label.add_theme_color_override("font_color", Color("e5d9a2"))
    stage_label.add_theme_font_size_override("font_size", 17)
    ui.add_child(stage_label)
    var footer := Label.new()
    footer.text = "UNBEARBEITETE GODOT-3D-WELT  •  ENTWICKLUNGSPROTOTYP  •  KEIN AAA-RENDER"
    footer.position = Vector2(30, 480)
    footer.add_theme_color_override("font_color", Color("e4ebe9"))
    footer.add_theme_font_size_override("font_size", 14)
    ui.add_child(footer)

func _process(delta: float) -> void:
    elapsed += delta
    if sports != null and is_instance_valid(sports):
        if elapsed >= 3.6 and elapsed < 8.4:
            Input.action_press("move_forward")
        else:
            Input.action_release("move_forward")
    var pos: Vector3
    var target: Vector3
    if elapsed < 3.6:
        var a := clampf(elapsed/3.6,0.0,1.0)
        pos = Vector3(5.0, 34.0, 127.0).lerp(Vector3(95.0, 29.0, 84.0),a)
        target = Vector3(76, 2, -19)
        stage_label.text = "ALPENWELT  /  WETTER  /  OFFENE SPIELREGION"
        camera.fov = 67
    elif elapsed < 8.4 and sports != null:
        var car_pos: Vector3 = sports.global_position
        var fwd: Vector3 = -sports.global_transform.basis.z
        pos = car_pos - fwd*10.0 + Vector3(-1.0, 4.3, 4.0)
        target = car_pos + fwd*12.0 + Vector3.UP*1.7
        stage_label.text = "FAHRZEUGSYSTEM  /  SPORTWAGEN IN BEWEGUNG"
        camera.fov = 71
    elif elapsed < 10.9:
        var b := clampf((elapsed-8.4)/2.5,0.0,1.0)
        pos = Vector3(30.0, 13.0, 73.0).lerp(Vector3(72.0, 11.0, 55.0),b)
        target = Vector3(49.0, 1.7, 62.0)
        stage_label.text = "RETTUNGSEINSATZ  /  HELIKOPTER  /  ALPEN"
        camera.fov = 58
    else:
        var c := clampf((elapsed-10.9)/2.1,0.0,1.0)
        pos = Vector3(46.0, 8.5, 49.0).lerp(Vector3(55.0, 6.5, 33.0),c)
        target = Vector3(47.0, 2.4, 31.0)
        stage_label.text = "OPERATION BERGLICHT  /  ORIGINALER SPIELSTAND"
        camera.fov = 58
    camera.global_position = pos
    camera.look_at(target, Vector3.UP)
    if elapsed >= LENGTH_SECONDS:
        Input.action_release("move_forward")
        get_tree().quit()
