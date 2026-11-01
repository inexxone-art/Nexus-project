extends CharacterBody3D
class_name NexusVehicle

var category: String = "Traktor"
var definition: Dictionary = {}
var model_name: String = ""
var excavator_arm: Node3D = null
var flash_beacon: OmniLight3D = null
var flash_timer: float = 0.0

func configure(record: Dictionary) -> void:
    definition = record.duplicate(true)
    model_name = str(definition.get("name", ""))
    match str(definition.get("kind", "")):
        "tank": category = "Panzer"
        "helicopter": category = "Helikopter"
        "excavator": category = "Bagger"
        "utility":
            var family = str(definition.get("family", ""))
            category = "Rettung" if family in ["ambulance","firetruck","police","rescue"] else ("Traktor" if family in ["tractor","harvester"] else "LKW")
        "car":
            var family = str(definition.get("family", ""))
            category = "Rettung" if family == "emergency" else ("Sportwagen" if family in ["coupe","supercar"] else "Auto")

var controlled: bool = false
var speed: float = 0.0
var fuel: float = 85.0
var condition: float = 100.0
var steer_angle: float = 0.0
var wheel_nodes: Array[Node3D] = []
var rotor: Node3D
var camera: Camera3D
var chase_view: bool = true
var rotor_pivot: Node3D = null
var rotor_speed: float = 0.0

func material(color: Color, metal: float = 0.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = metal
    m.roughness = 0.58
    return m

func part(parent: Node3D, size: Vector3, offset: Vector3, color: Color, metallic: float = 0.0) -> MeshInstance3D:
    var mi := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    mi.mesh = mesh
    mi.position = offset
    mi.material_override = material(color, metallic)
    parent.add_child(mi)
    return mi

func wheel(offset: Vector3, radius: float, thickness: float = 0.24) -> void:
    var socket := Node3D.new()
    socket.position = offset
    add_child(socket)
    var tire := MeshInstance3D.new()
    var cylinder := CylinderMesh.new()
    cylinder.top_radius = radius
    cylinder.bottom_radius = radius
    cylinder.height = thickness
    cylinder.radial_segments = 20
    tire.mesh = cylinder
    tire.rotation.z = PI * 0.5
    tire.material_override = material(Color("1c2428"))
    socket.add_child(tire)
    var rim := MeshInstance3D.new()
    var center := CylinderMesh.new()
    center.top_radius = radius * 0.43
    center.bottom_radius = radius * 0.43
    center.height = thickness + 0.025
    rim.mesh = center
    rim.rotation.z = PI * 0.5
    rim.material_override = material(Color("909a9f"), 0.8)
    socket.add_child(rim)
    wheel_nodes.append(socket)

func _ready() -> void:
    name = model_name if model_name != "" else category
    var collision := CollisionShape3D.new()
    var box := BoxShape3D.new()
    box.size = Vector3(2.3, 2.1, 4.5)
    collision.shape = box
    collision.position.y = 1.25
    add_child(collision)
    var base_color := Color("2e6045")
    if category == "LKW": base_color = Color("b88b51")
    if category == "Rettung": base_color = Color("b5c4cc")
    if category == "Sportwagen": base_color = Color("b73932")
    if category == "Panzer": base_color = Color("67735e")
    if category == "Bagger": base_color = Color("dfb84b")
    if category == "Helikopter": base_color = Color("d46b29")
    if definition.has("color"): base_color = Color(str(definition["color"]))
    part(self, Vector3(2.28, 0.65, 4.5), Vector3(0, 1.02, 0), Color("282d2e"), 0.4)
    part(self, Vector3(2.05, 0.92, 2.35), Vector3(0, 1.6, -0.9), base_color, 0.45)
    part(self, Vector3(1.99, 0.86, 1.4), Vector3(0, 2.04, 0.6), base_color, 0.4)
    part(self, Vector3(1.83, 0.62, 0.045), Vector3(0, 2.1, -0.13), Color("749cab"), 0.18)
    part(self, Vector3(2.25, 0.23, 0.26), Vector3(0, 1.08, -2.22), Color("1b1d20"), 0.45)
    part(self, Vector3(0.52, 0.18, 0.08), Vector3(-0.69, 1.39, -2.28), Color("f4ebc0"))
    part(self, Vector3(0.52, 0.18, 0.08), Vector3(0.69, 1.39, -2.28), Color("f4ebc0"))
    for x in [-1.1, 1.1]:
        wheel(Vector3(x, 0.68, -1.35), 0.72 if category == "Traktor" else 0.58)
        wheel(Vector3(x, 0.68, 1.4), 0.86 if category == "Traktor" else 0.58)
    if category == "Panzer":
        part(self, Vector3(2.25, 0.7, 3.7), Vector3(0, 2.16, 0.0), Color("5f6a54"), 0.5)
        part(self, Vector3(0.45, 0.36, 3.9), Vector3(0, 2.42, -2.0), Color("46523c"), 0.5)
        for xx in [-1.22, 1.22]:
            part(self, Vector3(0.43, 1.1, 4.3), Vector3(xx, 0.72, 0), Color("262d25"))
    elif category == "Bagger":
        part(self, Vector3(1.8, 1.7, 2.0), Vector3(0, 2.5, 0.5), Color("e3b63c"))
        var arm = Node3D.new()
        arm.position = Vector3(0.9, 2.5, -1.2)
        arm.name = "Baggerarm"
        excavator_arm = arm
        add_child(arm)
        part(arm, Vector3(0.32, 0.45, 3.2), Vector3(0, 0.9, -1.0), Color("d6a836"))
        part(arm, Vector3(1.4, 0.7, 1.0), Vector3(0, 1.5, -2.8), Color("6e6959"))
    elif category == "Helikopter":
        part(self, Vector3(1.7, 0.7, 3.0), Vector3(0, 2.4, 0.1), Color("da7137"))
        part(self, Vector3(0.55, 0.45, 5.0), Vector3(0, 2.1, 2.5), Color("da7137"))
        for xx in [-1.1, 1.1]:
            part(self, Vector3(0.18, 0.15, 4.2), Vector3(xx, 0.43, 0.1), Color("35404a"))
        rotor_pivot = Node3D.new()
        rotor_pivot.position = Vector3(0, 3.7, 0)
        add_child(rotor_pivot)
        part(rotor_pivot, Vector3(10.5, 0.1, 0.22), Vector3.ZERO, Color("353c44"))
        part(rotor_pivot, Vector3(0.22, 0.1, 10.5), Vector3.ZERO, Color("353c44"))
    if category == "LKW":
        part(self, Vector3(2.10, 1.25, 1.85), Vector3(0, 1.82, 1.18), Color("6f5842"))
    elif category == "Rettung":
        part(self, Vector3(1.8, 0.15, 0.22), Vector3(0, 2.56, 0.78), Color("245dca"), 0.2)
    elif category == "Traktor":
        part(self, Vector3(1.9, 0.16, 1.65), Vector3(0, 2.63, 0.68), Color("1e302a"))
        part(self, Vector3(0.13, 1.25, 0.13), Vector3(0.87, 2.25, -0.8), Color("373b3a"))
    if not definition.is_empty():
        _make_variant_geometry(base_color)
    camera = Camera3D.new()
    camera.position = Vector3(0, 3.6, 7.8)
    camera.fov = 75.0
    add_child(camera)
    camera.look_at(Vector3(0, 1.4, -4.0), Vector3.UP)
    camera.current = false

func _physics_process(delta: float) -> void:
    flash_timer += delta
    if flash_beacon != null:
        flash_beacon.light_energy = 3.5 if int(flash_timer * 4.0) % 2 == 0 else 0.1
    if excavator_arm != null and controlled:
        var arm_input = Input.get_axis("build_next", "build_rotate")
        excavator_arm.rotation.x = clampf(excavator_arm.rotation.x + arm_input * delta * 0.6, -0.5, 0.5)
    if rotor_pivot != null:
        rotor_speed = move_toward(rotor_speed, 20.0 if controlled and fuel > 0 else 0.0, delta * 3.0)
        rotor_pivot.rotate_y(delta * rotor_speed)
    if controlled and fuel > 0.0:
        var throttle := Input.get_axis("move_backward", "move_forward")
        var steering := Input.get_axis("move_left", "move_right")
        var max_speed: float = 26.0 if category == "Sportwagen" else (15.0 if category == "LKW" else (18.0 if category == "Helikopter" else 13.0))
        var acceleration: float = 7.0
        var handling: float = 0.82
        if not definition.is_empty():
            max_speed = float(definition.get("top_kmh", 85)) / 3.6
            acceleration = float(definition.get("acceleration", 6.0))
            handling = float(definition.get("handling", 0.72))
        speed = move_toward(speed, throttle * max_speed, delta * acceleration)
        if Input.is_action_pressed("jump") and category != "Helikopter":
            speed = move_toward(speed, 0.0, delta * 22.0)
        if abs(speed) > 0.25:
            rotate_y(-steering * delta * handling * sign(speed) * min(1.0, abs(speed) / 4.0))
        fuel = max(0.0, fuel - abs(speed) * delta * 0.006)
    else:
        speed = move_toward(speed, 0.0, delta * 8.0)
    if category == "Helikopter" and controlled and fuel > 0:
        var lift = (1.0 if Input.is_action_pressed("jump") else 0.0) - (1.0 if Input.is_action_pressed("sprint") else 0.0)
        velocity.y = move_toward(velocity.y, lift * 7.0, delta * 8.0)
    elif not is_on_floor():
        velocity.y -= 18.0 * delta
    else:
        velocity.y = -0.3
    var forward := -global_transform.basis.z
    velocity.x = forward.x * speed
    velocity.z = forward.z * speed
    move_and_slide()
    for w in wheel_nodes:
        w.rotation.x -= speed * delta * 1.35

func set_control(value: bool) -> void:
    controlled = value
    camera.current = value

func switch_view() -> void:
    chase_view = not chase_view
    camera.position = Vector3(0.0, 2.22, 0.7) if not chase_view else Vector3(0, 3.6, 7.8)
    camera.rotation = Vector3.ZERO
    camera.look_at(Vector3(0, 2.2, -7.0) if not chase_view else Vector3(0, 1.4, -4.0), Vector3.UP)


func _make_variant_geometry(base_color: Color) -> void:
    # Light-weight procedural silhouettes. This is a placeholder until licensed high-poly assets are imported.
    var family: String = str(definition.get("family", "sedan"))
    var length: float = float(definition.get("length", 4.5))
    var width: float = float(definition.get("width", 2.0))
    var body = Node3D.new()
    body.name = "Modellspezifische Karosserie und Anbauteile"
    add_child(body)
    var delta_length: float = (length - 4.5) * 0.45
    part(body, Vector3(width * 0.98, 0.12, maxi(2.6, length)), Vector3(0, 0.91, 0), base_color, 0.35)
    for side in [-1.0, 1.0]:
        part(body, Vector3(0.035, 0.34, maxi(1.8, length * 0.65)), Vector3(side * width * 0.49, 1.4, 0), base_color, 0.35)
    if family in ["suv", "offroad", "pickup", "van", "wagon", "minibus", "firetruck", "ambulance", "truck", "tipper", "mixer"]:
        part(body, Vector3(width * 0.88, 0.58, 2.0 + delta_length), Vector3(0, 2.4, 0.68), base_color, 0.3)
        part(body, Vector3(width * 0.78, 0.46, 0.12), Vector3(0, 2.39, -0.42), Color("5c8298"), 0.2)
    if family in ["coupe", "supercar", "electric", "roadster"]:
        part(body, Vector3(width * 0.9, 0.20, 2.2), Vector3(0, 1.05, -0.8), base_color, 0.4)
        part(body, Vector3(width * 0.86, 0.15, 0.25), Vector3(0, 2.25, 2.13), Color("161e23"), 0.3)
    if family in ["offroad", "pickup", "suv"]:
        part(body, Vector3(width + 0.08, 0.2, 0.23), Vector3(0, 1.10, -2.24), Color("242829"), 0.4)
        part(body, Vector3(width * 0.75, 0.15, 1.6), Vector3(0, 2.71, 0.58), Color("333b3d"), 0.3)
    if family in ["emergency", "police", "ambulance", "rescue", "firetruck"]:
        part(body, Vector3(1.5, 0.16, 0.22), Vector3(0, 2.93, 0.4), Color("255cd4"), 0.35)
        flash_beacon = OmniLight3D.new()
        flash_beacon.light_color = Color("2084ff")
        flash_beacon.omni_range = 13.0
        flash_beacon.shadow_enabled = false
        flash_beacon.position = Vector3(0, 3.0, 0.4)
        body.add_child(flash_beacon)
    if category == "Panzer":
        var family_scale: float = float(definition.get("mass", 19.0)) / 36.0
        part(body, Vector3(width * 0.87, 0.42 + family_scale * 0.28, length * 0.47), Vector3(0, 2.42, 0.0), base_color.darkened(0.12), 0.65)
        part(body, Vector3(0.30, 0.29, 2.4 + family_scale * 1.8), Vector3(0, 2.6, -2.2), base_color.darkened(0.32), 0.7)
        if family in ["Heavy", "MBT", "Artillery", "Missile"]:
            for side in [-1.0, 1.0]:
                part(body, Vector3(0.6, 0.35, 2.2), Vector3(side * 1.05, 2.5, 0.2), base_color.darkened(0.22), 0.5)
    elif category == "Helikopter":
        part(body, Vector3(width * 0.82, 0.48, length * 0.49), Vector3(0, 2.75, 0.0), base_color, 0.4)
        part(body, Vector3(width * 0.54, 0.7, 0.8), Vector3(0, 2.92, -1.4), Color("446c82"), 0.35)
        var tail = Node3D.new()
        tail.position = Vector3(0, 2.5, length * 0.53)
        tail.rotation.z = PI * 0.5
        body.add_child(tail)
        part(tail, Vector3(2.0, 0.09, 0.13), Vector3.ZERO, Color("333d43"), 0.5)
    elif category == "Bagger":
        var size_factor: float = length / 5.6
        part(body, Vector3(width * 0.75, 0.6 * size_factor, 2.0 * size_factor), Vector3(0, 2.9, 0.4), base_color, 0.35)
        for side in [-1.0, 1.0]:
            part(body, Vector3(0.52 * size_factor, 0.85 * size_factor, 3.4 * size_factor), Vector3(side * width * 0.45, 0.6, 0), Color("24282b"), 0.4)
    elif category == "LKW":
        part(body, Vector3(width * 0.94, 0.62, maxi(1.4, length - 3.0)), Vector3(0, 2.25, 1.0), base_color.darkened(0.15), 0.32)
    var badge = Label3D.new()
    badge.text = str(definition.get("id", ""))
    badge.font_size = 30
    badge.pixel_size = 0.004
    badge.position = Vector3(0, 3.1, 0)
    badge.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    body.add_child(badge)
