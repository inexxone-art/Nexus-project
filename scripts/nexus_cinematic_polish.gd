extends Node3D
class_name NexusCinematicPolish
## High-detail procedural set dressing and renderer presets for the Alpine vertical slice.
## It deliberately does NOT claim photogrammetry or AAA-quality individual assets.

var quality_high: bool = true
var rng := RandomNumberGenerator.new()
var mats: Dictionary = {}
var time: float = 0.0
var beacon_lights: Array[OmniLight3D] = []

func _ready() -> void:
    name = "NEXUS V1.4 | Cinematic Lighting and Environmental Detail"
    rng.seed = 2026110104
    _road_markings()
    _roadside_furniture()
    _power_network()
    _industrial_details()
    _waterfall()
    _forest_floor()
    _emergency_beacons()
    set_graphics_quality(true)

func _mat(color: Color, metallic: float = 0.0, roughness: float = 0.78) -> StandardMaterial3D:
    var key := "%s_%0.2f_%0.2f" % [color.to_html(),metallic,roughness]
    if mats.has(key):
        return mats[key]
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = roughness
    m.metallic = metallic
    mats[key] = m
    return m

func _shape(p: Vector3, size: Vector3, mat: Material, angle: float = 0.0) -> MeshInstance3D:
    var visual := MeshInstance3D.new()
    var mesh := BoxMesh.new()
    mesh.size = size
    visual.mesh = mesh
    visual.material_override = mat
    visual.position = p
    visual.rotation.y = angle
    add_child(visual)
    return visual

func _stone(p: Vector3, size: Vector3) -> void:
    var rock := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radial_segments = 12
    sphere.rings = 6
    rock.mesh = sphere
    rock.position = p
    rock.rotation = Vector3(rng.randf_range(-0.2,0.2), rng.randf_range(0.0,TAU), rng.randf_range(-0.1,0.1))
    rock.scale = size
    rock.material_override = _mat(Color("777970") if rng.randi_range(0,3)>0 else Color("aba69b"))
    rock.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(rock)

func _road_markings() -> void:
    var bright := _mat(Color("dfd7b9"), 0.0, 0.89)
    var worn := _mat(Color("b2b0a0"), 0.0, 0.95)
    for x in range(-84,85,9):
        _shape(Vector3(float(x),0.039,0),Vector3(4.8,0.009,0.13),worn)
    for z in range(5,108,9):
        _shape(Vector3(55,0.041,float(z)),Vector3(0.12,0.009,4.5),bright)
    for z in range(-82,-3,9):
        _shape(Vector3(-40,0.041,float(z)),Vector3(0.12,0.009,4.4),worn)
    for x in [-89.5,89.5]:
        _shape(Vector3(x,0.052,0),Vector3(0.22,0.03,8),_mat(Color("e7e2d6")))
    # Zebra crossings at key intersections, stripes are purely visual.
    for i in range(7):
        _shape(Vector3(41.0+float(i)*1.1,0.049,0),Vector3(0.60,0.015,4.8),bright)

func _roadside_furniture() -> void:
    var metal := _mat(Color("7b858a"),0.68,0.36)
    var paint := _mat(Color("d9ded7"),0.14,0.43)
    # Guardrails and reflectors provide close-up scale cues along the forest road.
    for side in [-1.0,1.0]:
        for i in range(14):
            var x := -90.0 + i*12.5
            var z: float = float(side) * 5.6
            _shape(Vector3(x,0.74,z),Vector3(0.13,1.48,0.13),metal)
            _shape(Vector3(x+5.5,1.05,z),Vector3(11.5,0.23,0.09),paint)
            _shape(Vector3(x,1.18,z+side*0.06),Vector3(0.14,0.12,0.06),_mat(Color("ffc66e")))
    # Bus shelters and roadside signs are actual 3D shapes, not UI markers.
    for position in [Vector3(-32,0,8),Vector3(72,0,-8)]:
        _shape(position+Vector3(0,1.9,0),Vector3(5.0,0.18,2.6),metal)
        for dx in [-2.1,2.1]:
            _shape(position+Vector3(dx,0.95,0),Vector3(0.10,1.9,0.11),metal)
        _shape(position+Vector3(0,0.33,0.8),Vector3(3.5,0.14,0.64),paint)
    for i in range(18):
        var x := -84.0 + float(i)*9.7
        _shape(Vector3(x,0.58,-8.7),Vector3(0.1,1.16,0.1),metal)
        _shape(Vector3(x,1.18,-8.7),Vector3(0.52,0.55,0.09),_mat(Color("466052")))

func _power_network() -> void:
    var dark := _mat(Color("505960"),0.55,0.58)
    var wire := _mat(Color("343941"),0.65,0.53)
    for x in range(-70,81,25):
        var p := Vector3(float(x),0,-16)
        _shape(p+Vector3(0,6,0),Vector3(0.28,12.0,0.28),dark)
        _shape(p+Vector3(0,11.7,0),Vector3(3.5,0.17,0.2),dark)
        for z in [-1.3,0.0,1.3]:
            _shape(p+Vector3(0,11.0,z),Vector3(0.22,0.35,0.13),_mat(Color("aa9e83")))
    for x in range(-69,68,25):
        for z in [-17.3,-16.0,-14.7]:
            _shape(Vector3(float(x)+12.5,11.0,z),Vector3(24.8,0.036,0.036),wire)

func _industrial_details() -> void:
    var steel := _mat(Color("69747a"),0.74,0.32)
    var concrete := _mat(Color("99968d"),0.05,0.95)
    var cargo := _mat(Color("b37849"),0.5,0.65)
    # Distinctive stacked containers and pallets at reconstruction yard.
    for j in range(3):
        for i in range(4):
            var p := Vector3(-84.0+i*5.4, 1.0+j*2.12,108.0)
            _shape(p,Vector3(4.6,1.9,2.45),cargo if (i+j)%2==0 else steel)
            for seam in [-1.4,-0.45,0.45,1.4]:
                _shape(p+Vector3(seam,0.0,1.25),Vector3(0.07,1.6,0.045),concrete)
    # A few recognizable residential facade details on the preexisting blocks.
    for x in [83.0,97.0,111.0]:
        for z in [-50.0,-33.0,-16.0]:
            for dx in [-2.6,2.6]:
                _shape(Vector3(x+dx,2.7,z+3.65),Vector3(1.25,1.3,0.08),_mat(Color("7ba0aa"),0.18,0.22))
                _shape(Vector3(x+dx,2.7,z+3.76),Vector3(0.05,1.35,0.07),concrete)
            _shape(Vector3(x,0.24,z+4.3),Vector3(2.2,0.2,1.0),concrete)

func _waterfall() -> void:
    # An atmospheric distant waterfall alongside the existing alpine lake.
    var rock := _mat(Color("656c68"),0.05,0.95)
    var water := _mat(Color(0.55,0.79,0.85,0.83),0.14,0.17)
    water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    for i in range(12):
        var x := -196.0 + float(i)*3.2
        _stone(Vector3(x,6.0,20.5),Vector3(3.0,9.0,2.6))
    for i in range(5):
        _shape(Vector3(-186.0 + i*1.9,7.5,21),Vector3(1.25,15.0,0.11),water)
    for i in range(20):
        _stone(Vector3(-187+rng.randf_range(-10,9),0.2,23+rng.randf_range(-2,3)),Vector3(0.5,0.25,0.55))

func _forest_floor() -> void:
    # Instanced clumps of stones with low draw-call cost; no added collisions.
    var boulder := SphereMesh.new()
    boulder.radial_segments = 6
    boulder.rings = 4
    var mm := MultiMesh.new()
    mm.transform_format = MultiMesh.TRANSFORM_3D
    mm.use_colors = true
    mm.mesh = boulder
    mm.instance_count = 650
    for i in range(mm.instance_count):
        var x := rng.randf_range(-142,143)
        var z := rng.randf_range(-140,143)
        var scale_value := rng.randf_range(0.12,0.52)
        mm.set_instance_transform(i,Transform3D(Basis.from_scale(Vector3(scale_value,scale_value*0.36,scale_value*0.78)),Vector3(x,0.15,z)))
        mm.set_instance_color(i,Color.from_hsv(rng.randf_range(0.12,0.25),0.08,rng.randf_range(0.36,0.66)))
    var props := MultiMeshInstance3D.new()
    props.name = "650 instanzierte Waldsteine"
    props.multimesh = mm
    var material := StandardMaterial3D.new()
    material.vertex_color_use_as_albedo = true
    material.roughness = 0.98
    props.material_override = material
    props.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(props)

func _emergency_beacons() -> void:
    for pos in [Vector3(47,7.6,32),Vector3(-60,8.2,60),Vector3(116,8.5,-11)]:
        var red := OmniLight3D.new()
        red.position = pos
        red.light_color = Color("f13a43")
        red.light_energy = 0.0
        red.omni_range = 11.0
        red.shadow_enabled = false
        add_child(red)
        beacon_lights.append(red)
        var blue := OmniLight3D.new()
        blue.position = pos+Vector3(1.2,0,0)
        blue.light_color = Color("317aff")
        blue.light_energy = 0.0
        blue.omni_range = 11.0
        blue.shadow_enabled = false
        add_child(blue)
        beacon_lights.append(blue)

func _process(delta: float) -> void:
    time += delta
    for i in range(beacon_lights.size()):
        var on := sin(time*7.0 + (PI if i%2==1 else 0.0)) > 0.6
        beacon_lights[i].light_energy = 0.68 if on and quality_high else 0.0

func set_graphics_quality(high: bool) -> void:
    quality_high = high
    var world_env := get_parent().get_node_or_null("WorldEnvironment") as WorldEnvironment
    if world_env == null or world_env.environment == null:
        return
    var env := world_env.environment
    env.ssao_enabled = high
    env.ssil_enabled = high
    env.glow_enabled = high
    env.volumetric_fog_enabled = high
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.adjustment_enabled = true
    env.adjustment_contrast = 1.06 if high else 1.0
    env.adjustment_saturation = 1.07 if high else 1.0
