extends Node3D
class_name NexusAdlerklammDisaster
## Adlerklamm physical-event vertical slice. All geometry is original procedural
## placeholder art; never describe this as photogrammetry or AAA production art.
signal stage_changed(next_stage: String)

const BRIDGE_X := 175.0
const BRIDGE_Z := 168.0
const BRIDGE_LENGTH := 82.0
const PIECE_COUNT := 12
const SEGMENT_LENGTH := BRIDGE_LENGTH / float(PIECE_COUNT)
const REBUILD_WOOD := 10
const REBUILD_IRON := 6
const REBUILD_CEMENT := 4
const REBUILD_ASPHALT := 3
const PRODUCTION = preload("res://scripts/nexus_production_assets.gd")

var stage: String = "ready"
var rebuild_progress: int = 0
var elapsed: float = 0.0
var original_bridge: Array[Node] = []
var original_layers: Dictionary = {}
var pieces: Array[RigidBody3D] = []
var released: Dictionary = {}
var bus: RigidBody3D
var dust_nodes: Array[CPUParticles3D] = []
var asphalt: StandardMaterial3D
var concrete: StandardMaterial3D
var metal: StandardMaterial3D
var glass: StandardMaterial3D

func _ready() -> void:
    name = "Adlerklamm | Bus fall + rebuildable bridge"
    asphalt = _material(Color("41484b"),0.06,0.8)
    concrete = _material(Color("adaaa1"),0.0,0.92)
    metal = _material(Color("656a70"),0.72,0.45)
    glass = _material(Color("597a85"),0.2,0.18)
    _pbr(asphalt,"asphalt",0.38)
    _pbr(concrete,"concrete",0.62)
    _pbr(metal,"metal",0.3)
    _spawn_bus()
    set_process(true)

func configure_bridge(nodes: Array[Node]) -> void:
    original_bridge = nodes.duplicate()
    for node in original_bridge:
        if node is CollisionObject3D:
            original_layers[node.get_instance_id()] = [node.collision_layer,node.collision_mask]

func _material(tint: Color, metal_value: float, rough: float) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = tint
    mat.metallic = metal_value
    mat.roughness = rough
    return mat

func _pbr(mat: StandardMaterial3D, channel: String, normal_strength: float) -> void:
    var albedo: Texture2D = PRODUCTION.surface_texture(channel,"albedo")
    if albedo != null:
        mat.albedo_texture = albedo
        mat.uv1_triplanar = true
        mat.uv1_scale = Vector3(0.24,0.24,0.24)
    var normal: Texture2D = PRODUCTION.surface_texture(channel,"normal")
    if normal != null:
        mat.normal_enabled = true
        mat.normal_texture = normal
        mat.normal_scale = normal_strength
    var roughness: Texture2D = PRODUCTION.surface_texture(channel,"roughness")
    if roughness != null:
        mat.roughness_texture = roughness
        mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED

func _part(parent: Node3D, label: String, center: Vector3, dimensions: Vector3, mat: Material) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = label
    var mesh := BoxMesh.new()
    mesh.size = dimensions
    node.mesh = mesh
    node.material_override = mat
    node.position = center
    node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    parent.add_child(node)
    return node

func _spawn_bus() -> void:
    bus = RigidBody3D.new()
    bus.name = "Rescue bus | fully physical rigid body"
    bus.position = Vector3(BRIDGE_X,2.55,BRIDGE_Z-5.0)
    bus.mass = 9200.0
    bus.gravity_scale = 1.0
    bus.freeze = true
    bus.continuous_cd = true
    bus.linear_damp = 0.06
    bus.angular_damp = 0.12
    var body_shape := CollisionShape3D.new()
    var hull := BoxShape3D.new()
    hull.size = Vector3(2.6,3.25,10.5)
    body_shape.shape = hull
    bus.add_child(body_shape)
    _part(bus,"Bus body - structural shell",Vector3.ZERO,Vector3(2.65,3.2,10.5),_material(Color("d8dcdb"),0.2,0.55))
    _part(bus,"Bus lower blue stripe",Vector3(0,-1.18,0),Vector3(2.7,0.48,10.57),_material(Color("2d5874"),0.2,0.55))
    for side in [-1.0,1.0]:
        for i in range(7):
            _part(bus,"Passenger window",Vector3(float(side)*1.345,0.42,-3.5+float(i)*1.17),Vector3(0.035,1.1,0.96),glass)
        for z in [-3.55,3.55]:
            var wheel := MeshInstance3D.new()
            wheel.name = "Rubber wheel"
            var mesh := CylinderMesh.new()
            mesh.top_radius = 0.71
            mesh.bottom_radius = 0.71
            mesh.height = 0.38
            wheel.mesh = mesh
            wheel.rotation.z = PI*0.5
            wheel.position = Vector3(float(side)*1.31,-1.34,z)
            wheel.material_override = _material(Color("1a1b1a"),0.0,0.98)
            bus.add_child(wheel)
    _part(bus,"Windshield",Vector3(0,0.4,-5.29),Vector3(2.28,1.65,0.05),glass)
    for x in [-0.75,0.75]:
        _part(bus,"Headlamp",Vector3(x,-1.09,-5.33),Vector3(0.4,0.28,0.07),_material(Color("f8e6af"),0.0,0.25))
    add_child(bus)

func _spawn_segment(index: int) -> void:
    var piece := RigidBody3D.new()
    piece.name = "Collapsing bridge span %02d" % index
    piece.position = Vector3(BRIDGE_X,-0.05,BRIDGE_Z-BRIDGE_LENGTH*0.5+(float(index)+0.5)*SEGMENT_LENGTH)
    piece.mass = 48000.0
    piece.freeze = true
    piece.continuous_cd = true
    piece.linear_damp = 0.05
    piece.angular_damp = 0.12
    var collision := CollisionShape3D.new()
    var shape := BoxShape3D.new()
    shape.size = Vector3(10.0,0.66,SEGMENT_LENGTH-0.06)
    collision.shape = shape
    piece.add_child(collision)
    _part(piece,"Broken concrete structural slab",Vector3.ZERO,shape.size,concrete)
    _part(piece,"Asphalt wearing surface",Vector3(0,0.352,0),Vector3(9.4,0.065,SEGMENT_LENGTH-0.12),asphalt)
    for side in [-1.0,1.0]:
        _part(piece,"Jagged edge parapet",Vector3(float(side)*4.7,0.78,0),Vector3(0.36,0.9,SEGMENT_LENGTH-0.16),concrete)
        _part(piece,"Exposed steel",Vector3(float(side)*2.8,-0.33,0),Vector3(0.12,0.14,SEGMENT_LENGTH+0.16),metal)
    add_child(piece)
    pieces.append(piece)

func _dust(at: Vector3) -> void:
    var puff := CPUParticles3D.new()
    puff.name = "Concrete dust and debris plume"
    puff.position = at
    puff.amount = 90
    puff.lifetime = 1.8
    puff.one_shot = true
    puff.explosiveness = 0.95
    puff.direction = Vector3.UP
    puff.spread = 85.0
    puff.initial_velocity_min = 2.0
    puff.initial_velocity_max = 11.0
    puff.gravity = Vector3(0,-4,0)
    puff.color = Color(0.60,0.57,0.52,0.68)
    var mesh := SphereMesh.new()
    mesh.radius = 0.22
    mesh.height = 0.44
    puff.mesh = mesh
    add_child(puff)
    puff.emitting = true
    dust_nodes.append(puff)

func _hide_old_bridge(hide_parts: bool) -> void:
    for node in original_bridge:
        if not is_instance_valid(node):
            continue
        if node is Node3D:
            (node as Node3D).visible = not hide_parts
        if node is CollisionObject3D:
            var collider := node as CollisionObject3D
            if hide_parts:
                collider.collision_layer = 0
                collider.collision_mask = 0
            else:
                var pair: Array = original_layers.get(node.get_instance_id(),[1,1])
                collider.collision_layer = int(pair[0])
                collider.collision_mask = int(pair[1])

func start_disaster() -> bool:
    if stage != "ready":
        return false
    _hide_old_bridge(true)
    for i in range(PIECE_COUNT):
        _spawn_segment(i)
    elapsed = 0.0
    rebuild_progress = 0
    released.clear()
    stage = "fracturing"
    stage_changed.emit(stage)
    return true

func _release_segment(index: int) -> void:
    if released.has(index):
        return
    var piece := pieces[index]
    piece.freeze = false
    piece.sleeping = false
    piece.apply_central_impulse(Vector3(float(index%3-1)*16000.0,-31000.0,4000.0))
    piece.apply_torque_impulse(Vector3(16000.0*float(index%2*2-1),9000.0,7000.0))
    released[index] = true
    if index % 2 == 0:
        _dust(piece.global_position)

func _process(delta: float) -> void:
    if stage != "fracturing":
        return
    elapsed += delta
    for i in range(PIECE_COUNT):
        if elapsed >= 0.55 + float(i)*0.095:
            _release_segment(i)
    if elapsed >= 0.85 and bus != null and bus.freeze:
        bus.freeze = false
        bus.sleeping = false
        bus.apply_central_impulse(Vector3(16000.0,0.0,-6500.0))
        bus.apply_torque_impulse(Vector3(76000.0,0.0,53000.0))
    if elapsed >= 9.0:
        stage = "aftermath"
        stage_changed.emit(stage)

func rebuild_bridge() -> bool:
    if stage != "aftermath":
        return false
    for item in pieces:
        if is_instance_valid(item):
            item.queue_free()
    pieces.clear()
    for item in dust_nodes:
        if is_instance_valid(item):
            item.queue_free()
    dust_nodes.clear()
    if bus != null and is_instance_valid(bus):
        bus.queue_free()
    _hide_old_bridge(false)
    stage = "ready"
    rebuild_progress = 0
    elapsed = 0.0
    released.clear()
    _spawn_bus()
    stage_changed.emit(stage)
    return true

func get_data() -> Dictionary:
    return {"bridge_destroyed":stage != "ready","phase":stage,"rebuild_progress":rebuild_progress}

func restore_data(value: Dictionary) -> void:
    if bool(value.get("bridge_destroyed",false)):
        if stage == "ready":
            start_disaster()
        for i in range(PIECE_COUNT):
            _release_segment(i)
        if bus != null:
            bus.freeze = false
        elapsed = 9.0
        stage = "aftermath"
        rebuild_progress = clampi(int(value.get("rebuild_progress",0)),0,3)
        stage_changed.emit(stage)
    elif stage == "aftermath":
        rebuild_bridge()

func status_text() -> String:
    if stage == "ready":
        return "Adlerklamm: Bruecke offen | Einsturz erfolgt automatisch hinter dem fahrenden Spieler"
    if stage == "fracturing":
        return "ADLERKLAMM: BRUECKENEINSTURZ! Bus und Fahrbahn stuerzen ab"
    return "Adlerklamm: Strecke gesperrt | E: Bauphase %d/4 | Eisen, Zement und Asphalt herstellen" % (rebuild_progress+1)
