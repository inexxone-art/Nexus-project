extends Node3D
## GENUINE PROJECT NEXUS GODOT V2.2 GAMEPLAY: deterministic in-engine cinematic camera.
## No synthetic video generation, replacement footage or external screenshots.
const GAME_WORLD = preload("res://scripts/world.gd")
var game: Node3D
var camera: Camera3D
var car: Node3D
var elapsed: float = 0.0
var caption: Label

func _ready() -> void:
    game = GAME_WORLD.new()
    game.name = "Original PROJECT NEXUS V2.2 World"
    add_child(game)
    if game.player != null:
        game.player.active = false
        game.player.camera.current = false
    for panel in game.find_children("*", "CanvasLayer", true, false):
        panel.visible = false
    if game.vehicles.size() >= 3:
        car = game.vehicles[2]
        car.global_position = Vector3(-64.0, 0.2, 0)
        car.rotation.y = -PI / 2.0
        car.set_control(true)
        car.camera.current = false
    camera = Camera3D.new()
    camera.fov = 67.0
    camera.near = 0.08
    add_child(camera)
    camera.current = true
    var ui := CanvasLayer.new()
    ui.layer = 90
    add_child(ui)
    caption = Label.new()
    caption.position = Vector2(26, 18)
    caption.text = "PROJECT NEXUS | REAL GODOT GAMEPLAY | V2.2 ALPHA"
    caption.add_theme_font_size_override("font_size", 22)
    caption.add_theme_color_override("font_color", Color("dcf5e6"))
    caption.add_theme_color_override("font_shadow_color", Color.BLACK)
    caption.add_theme_constant_override("shadow_offset_x", 2)
    caption.add_theme_constant_override("shadow_offset_y", 2)
    ui.add_child(caption)
    print("NEXUS_CAPTURE_READY: world and camera initialised")

func _process(delta: float) -> void:
    elapsed += delta
    if car != null:
        if elapsed >= 3.6 and elapsed < 8.4:
            Input.action_press("move_forward")
        else:
            Input.action_release("move_forward")
    var pos: Vector3
    var target: Vector3
    if elapsed < 3.6:
        var a := clampf(elapsed / 3.6, 0.0, 1.0)
        pos = Vector3(5, 34, 127).lerp(Vector3(95, 29, 84), a)
        target = Vector3(76, 2, -19)
        caption.text = "PROJECT NEXUS | ALPENWELT | V2.2 ALPHA"
        camera.fov = 67.0
    elif elapsed < 8.4 and car != null:
        var f: Vector3 = -car.global_transform.basis.z
        pos = car.global_position - f * 10.0 + Vector3(-1, 4.3, 4)
        target = car.global_position + f * 12.0 + Vector3.UP * 1.7
        caption.text = "PROJECT NEXUS | SPORTWAGEN-FAHRT | ORIGINAL GAMEPLAY"
        camera.fov = 71.0
    elif elapsed < 10.9:
        var b := clampf((elapsed - 8.4) / 2.5, 0.0, 1.0)
        pos = Vector3(30, 13, 73).lerp(Vector3(72, 11, 55), b)
        target = Vector3(49, 1.7, 62)
        caption.text = "PROJECT NEXUS | BERGRETTUNG | ORIGINAL GAMEPLAY"
        camera.fov = 58.0
    else:
        var c := clampf((elapsed - 10.9) / 2.1, 0.0, 1.0)
        pos = Vector3(46, 8.5, 49).lerp(Vector3(55, 6.5, 33), c)
        target = Vector3(47, 2.4, 31)
        caption.text = "PROJECT NEXUS | OPERATION BERGLICHT | V2.2 ALPHA"
        camera.fov = 58.0
    camera.global_position = pos
    camera.look_at(target, Vector3.UP)
    if elapsed >= 13.0:
        Input.action_release("move_forward")
        get_tree().quit()
