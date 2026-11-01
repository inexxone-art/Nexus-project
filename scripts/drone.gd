extends CharacterBody3D
class_name NexusDrone
## FPV scouting drone. Arcade flight, not aviation-grade aerodynamics.
var controlled: bool = false
var battery: float = 100.0
var max_range: float = 165.0
var home: Vector3
var camera: Camera3D
var rotors: Array[Node3D] = []
var state_notice: String = ""

func _ready() -> void:
    name = "FPV_Drone"
    home = global_position
    var shape = CollisionShape3D.new()
    var sphere = SphereShape3D.new()
    sphere.radius = 0.38
    shape.shape = sphere
    add_child(shape)
    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color("344652")
    mat.metallic = 0.42
    var hull = MeshInstance3D.new()
    var mesh = BoxMesh.new()
    mesh.size = Vector3(0.8, 0.18, 0.65)
    hull.mesh = mesh
    hull.material_override = mat
    add_child(hull)
    for xx in [-0.7, 0.7]:
        for zz in [-0.7, 0.7]:
            var arm = MeshInstance3D.new()
            var beam = BoxMesh.new()
            beam.size = Vector3(0.85, 0.07, 0.10)
            arm.mesh = beam
            arm.position = Vector3(xx * 0.45, 0, zz * 0.45)
            arm.rotation.y = -atan2(zz, xx)
            arm.material_override = mat
            add_child(arm)
            var rotor = Node3D.new()
            rotor.position = Vector3(xx, 0.12, zz)
            add_child(rotor)
            var blades = MeshInstance3D.new()
            var blade_mesh = BoxMesh.new()
            blade_mesh.size = Vector3(0.85, 0.025, 0.075)
            blades.mesh = blade_mesh
            blades.material_override = mat
            rotor.add_child(blades)
            rotors.append(rotor)
    camera = Camera3D.new()
    camera.fov = 94.0
    camera.position = Vector3(0, 0.1, -0.43)
    add_child(camera)
    camera.current = false

func set_control(state: bool) -> void:
    controlled = state
    camera.current = state
    if state:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if controlled and event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        rotate_y(-event.relative.x * 0.0026)
        camera.rotation.x = clampf(camera.rotation.x - event.relative.y * 0.0026, -1.0, 1.0)

func _physics_process(delta: float) -> void:
    if controlled and battery > 0.0:
        var horizontal = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
        var direction = global_transform.basis * Vector3(horizontal.x, 0, horizontal.y)
        var vertical = (1.0 if Input.is_action_pressed("jump") else 0.0) - (1.0 if Input.is_action_pressed("sprint") else 0.0)
        velocity = Vector3(direction.x * 13.0, vertical * 8.0, direction.z * 13.0)
        move_and_slide()
        battery = maxf(0.0, battery - delta * (0.25 + velocity.length() * 0.025))
        if global_position.distance_to(home) > max_range:
            global_position = home + (global_position - home).normalized() * max_range
            velocity = Vector3.ZERO
            state_notice = "Maximale Reichweite erreicht"
        else:
            state_notice = ""
        if battery <= 0.0:
            state_notice = "Akku leer – Drohne kehrt zurück"
            global_position = home
            battery = 100.0
            set_control(false)
    else:
        velocity = Vector3.ZERO
    for rotor in rotors:
        rotor.rotate_y(delta * (23.0 if controlled else 0.5))
