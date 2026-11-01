extends Node3D
class_name NexusPhotoMode
## In-engine free camera for making HONEST trailer captures from the running game.
## F10 toggles photo mode, F11 saves the current viewport to user://nexus_shots.
signal photo_saved(path: String, success: bool)

const CAMERA_SPEED: float = 13.0
const FAST_MULTIPLIER: float = 3.0
const MOUSE_SENSITIVITY: float = 0.0020

var active: bool = false
var photo_camera: Camera3D
var previous_camera: Camera3D
var actor: NexusPlayer
var actor_was_active: bool = true
var ui_states: Array[Dictionary] = []
var photo_count: int = 0

func _ready() -> void:
    name = "NEXUS | In-Engine Kameramodus"
    photo_camera = Camera3D.new()
    photo_camera.name = "CinematicCaptureCamera"
    photo_camera.current = false
    photo_camera.fov = 66.0
    add_child(photo_camera)
    set_process(false)
    set_process_unhandled_input(false)

func enter(source: Camera3D, controlled_actor: NexusPlayer, ui_elements: Array) -> bool:
    if active or source == null or controlled_actor == null:
        return false
    actor = controlled_actor
    actor_was_active = actor.active
    previous_camera = source
    photo_camera.global_transform = source.global_transform
    photo_camera.fov = source.fov
    photo_camera.near = source.near
    photo_camera.far = source.far
    ui_states.clear()
    for element in ui_elements:
        if element is CanvasItem:
            ui_states.append({"node":element,"visible":element.visible})
            element.visible = false
    actor.active = false
    previous_camera.current = false
    photo_camera.current = true
    active = true
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    set_process(true)
    set_process_unhandled_input(true)
    return true

func exit() -> void:
    if not active:
        return
    active = false
    set_process(false)
    set_process_unhandled_input(false)
    photo_camera.current = false
    if is_instance_valid(previous_camera):
        previous_camera.current = true
    if is_instance_valid(actor):
        actor.active = actor_was_active
    for state in ui_states:
        var element: CanvasItem = state["node"]
        if is_instance_valid(element):
            element.visible = bool(state["visible"])
    ui_states.clear()
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
    if not active:
        return
    var axis := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    var direction := photo_camera.global_transform.basis * Vector3(axis.x, 0.0, axis.y)
    if Input.is_key_pressed(KEY_Q):
        direction += Vector3.DOWN
    if Input.is_key_pressed(KEY_E):
        direction += Vector3.UP
    var speed := CAMERA_SPEED * (FAST_MULTIPLIER if Input.is_action_pressed("sprint") else 1.0)
    if direction.length_squared() > 0.0:
        photo_camera.global_position += direction.normalized() * speed * delta

func _unhandled_input(event: InputEvent) -> void:
    if not active or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
        return
    if event is InputEventMouseMotion:
        photo_camera.rotation.y -= event.relative.x * MOUSE_SENSITIVITY
        photo_camera.rotation.x = clampf(photo_camera.rotation.x - event.relative.y * MOUSE_SENSITIVITY, -1.53, 1.53)

func capture() -> void:
    if not active:
        return
    var directory := "user://nexus_shots"
    var err := DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(directory))
    if err != OK:
        photo_saved.emit(directory, false)
        return
    await RenderingServer.frame_post_draw
    var image := get_viewport().get_texture().get_image()
    photo_count += 1
    var path := "%s/nexus_%04d.png" % [directory, photo_count]
    var result := image.save_png(path)
    photo_saved.emit(path, result == OK)
