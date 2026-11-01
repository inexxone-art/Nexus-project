extends CharacterBody3D
class_name NexusPlayer
const ACTOR_RIG = preload("res://scripts/nexus_actor_rig.gd")

var active: bool = true
var first_person: bool = false
var walk_speed: float = 6.2
var run_speed: float = 10.8
var gravity: float = 18.0
var pivot: Node3D
var camera: Camera3D
var body_visual: MeshInstance3D
var health: float = 100.0
var rig: NexusActorRig
var invulnerable_time: float = 0.0
var animation_time: float = 0.0

func _ready() -> void:
    name = "Player"
    var shape := CollisionShape3D.new()
    var capsule := CapsuleShape3D.new()
    capsule.radius = 0.43
    capsule.height = 1.8
    shape.shape = capsule
    shape.position = Vector3(0, 0.95, 0)
    add_child(shape)

    body_visual = MeshInstance3D.new()
    var body_mesh := CapsuleMesh.new()
    body_mesh.radius = 0.42
    body_mesh.height = 1.7
    body_visual.mesh = body_mesh
    body_visual.position = Vector3(0, 0.92, 0)
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("d69b56")
    material.roughness = 0.8
    body_visual.material_override = material
    add_child(body_visual)
    body_visual.visible = false
    rig = ACTOR_RIG.new()
    add_child(rig)

    pivot = Node3D.new()
    pivot.name = "CameraPivot"
    pivot.position = Vector3(0, 1.63, 0)
    add_child(pivot)
    camera = Camera3D.new()
    camera.fov = 73.0
    camera.near = 0.08
    camera.position = Vector3(0, 0.48, 4.9)
    pivot.add_child(camera)
    camera.look_at(Vector3(0, 0.1, -8), Vector3.UP)
    camera.current = true
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if not active or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
        return
    if event is InputEventMouseMotion:
        rotate_y(-event.relative.x * 0.0022)
        pivot.rotation.x = clamp(pivot.rotation.x - event.relative.y * 0.0022, -0.94, 0.94)

func _process(delta: float) -> void:
    invulnerable_time = maxf(0.0, invulnerable_time-delta)
    if rig != null:
        rig.animate_motion(delta,Vector2(velocity.x,velocity.z).length() if active else 0.0, Input.is_action_pressed("sprint"))
    if body_visual != null and active and not first_person:
        var horizontal_speed: float = Vector2(velocity.x,velocity.z).length()
        animation_time += delta*horizontal_speed*1.8
        var amplitude: float = clampf(horizontal_speed/14.0,0.0,0.1)
        body_visual.position.y = 0.92 + sin(animation_time)*amplitude
        body_visual.rotation.z = sin(animation_time*0.5)*amplitude*0.23

func _physics_process(delta: float) -> void:
    if not active:
        velocity = Vector3.ZERO
        return
    if not is_on_floor():
        velocity.y -= gravity * delta
    elif Input.is_action_just_pressed("jump"):
        velocity.y = 7.0
    var axis := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    var desired := transform.basis * Vector3(axis.x, 0, axis.y)
    var max_speed := run_speed if Input.is_action_pressed("sprint") else walk_speed
    velocity.x = move_toward(velocity.x, desired.x * max_speed, delta * 24.0)
    velocity.z = move_toward(velocity.z, desired.z * max_speed, delta * 24.0)
    move_and_slide()

func set_driving(driving: bool) -> void:
    active = not driving
    visible = not driving
    if camera != null:
        camera.current = not driving

func switch_view() -> void:
    if camera == null:
        return
    first_person = not first_person
    body_visual.visible = false
    if rig != null:
        rig.visible = not first_person
    camera.position = Vector3(0, 0.02, 0.0) if first_person else Vector3(0, 0.48, 4.9)
    camera.rotation = Vector3.ZERO
    if not first_person:
        camera.look_at(Vector3(0, 0.1, -8), Vector3.UP)

func take_damage(amount: float) -> bool:
    if amount <= 0.0 or invulnerable_time > 0.0 or not active:
        return false
    health = maxf(0.0,health-amount)
    invulnerable_time = 0.65
    return true

func receive_medical_help(amount: float) -> void:
    health = clampf(health+maxf(0.0,amount),0.0,100.0)
