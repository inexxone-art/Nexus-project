extends CanvasLayer
class_name NexusMobileControls
## Minimal touch controls for an experimental browser/mobile preview.
## The mobile controls do not claim native iOS packaging or full mobile optimization.

var world: Node3D
var controls: Dictionary = {}
var camera_area_start: float = 0.46

func _ready() -> void:
    name = "NEXUS | Touch Controls"
    layer = 25
    _direction("▲", "move_forward", "up")
    _direction("◀", "move_left", "left")
    _direction("▼", "move_backward", "down")
    _direction("▶", "move_right", "right")
    _direction("SPR", "sprint", "sprint")
    _direction("JUMP", "jump", "jump")
    _action("E", "interact")
    _action("F", "vehicle")
    _action("MAP", "map")
    _action("SPACE", "space")
    _action("SAVE", "save")
    _action("OPS", "ops")
    _action("AIM", "shoot")
    _action("FPS", "quality")
    get_viewport().size_changed.connect(_layout)
    _layout()
    visible = DisplayServer.is_touchscreen_available()

func bind_world(source: Node3D) -> void:
    world = source

func _button(text: String, key: String, size: Vector2 = Vector2(72, 66)) -> Button:
    var button := Button.new()
    button.name = "Touch " + key
    button.text = text
    button.focus_mode = Control.FOCUS_NONE
    button.custom_minimum_size = size
    button.size = size
    button.mouse_filter = Control.MOUSE_FILTER_STOP
    var surface := StyleBoxFlat.new()
    surface.bg_color = Color(0.04,0.08,0.12,0.68)
    surface.border_color = Color(0.34,0.65,0.8,0.75)
    surface.set_border_width_all(2)
    surface.set_corner_radius_all(14)
    button.add_theme_stylebox_override("normal",surface)
    var pressed_style := surface.duplicate() as StyleBoxFlat
    pressed_style.bg_color = Color(0.15,0.42,0.58,0.92)
    button.add_theme_stylebox_override("pressed",pressed_style)
    button.add_theme_font_size_override("font_size",19)
    add_child(button)
    controls[key] = button
    return button

func _direction(text: String, action: String, key: String) -> void:
    var button := _button(text,key)
    button.button_down.connect(func(): Input.action_press(action))
    button.button_up.connect(func(): Input.action_release(action))
    button.visibility_changed.connect(func():
        if not button.visible:
            Input.action_release(action)
    )

func _action(text: String, key: String) -> void:
    var button := _button(text,key,Vector2(77,64))
    button.pressed.connect(func(): _dispatch(key))

func _layout() -> void:
    var size := get_viewport().get_visible_rect().size
    var bottom := size.y - 100.0
    var sx := 24.0
    var entries := {
        "up":Vector2(sx+78,bottom-165), "left":Vector2(sx,bottom-89),
        "down":Vector2(sx+78,bottom-89), "right":Vector2(sx+156,bottom-89),
        "sprint":Vector2(sx+10,bottom-170), "jump":Vector2(size.x-94,bottom-242),
        "interact":Vector2(size.x-94,bottom-165), "vehicle":Vector2(size.x-94,bottom-89),
        "map":Vector2(size.x-181,bottom-89), "space":Vector2(size.x-181,bottom-165),
        "save":Vector2(size.x-94,24), "ops":Vector2(size.x-181,24),
        "shoot":Vector2(size.x-270,bottom-165), "quality":Vector2(size.x-268,24),
    }
    for key in entries.keys():
        var button: Button = controls.get(key)
        if button != null:
            button.position = entries[key].clamp(Vector2.ZERO, Vector2(maxf(0.0,size.x-80),maxf(0.0,size.y-80)))

func _dispatch(key: String) -> void:
    if not is_instance_valid(world):
        return
    match key:
        "interact": world._interact()
        "vehicle": world._toggle_vehicle()
        "map": world.minimap.visible = not world.minimap.visible
        "space": world._open_star_system()
        "save": world.save_state()
        "ops": world.living_panel.toggle()
        "shoot": world.shoot_training()
        "quality": world.performance_panel.toggle()

func _unhandled_input(event: InputEvent) -> void:
    if not visible or not is_instance_valid(world):
        return
    if event is InputEventScreenDrag:
        var width := get_viewport().get_visible_rect().size.x
        if event.position.x < width * camera_area_start:
            return
        if world.player == null or not world.player.active:
            return
        world.player.rotate_y(-event.relative.x * 0.004)
        world.player.pivot.rotation.x = clampf(world.player.pivot.rotation.x - event.relative.y * 0.004,-1.2,1.2)
