extends Node3D
## V1.8: original mesh and PBR-detail pass for three showcase vehicles.
## Geometry is authored procedurally, so these remain prototypes (NOT scanned AAA assets).
## Deliberately avoids runtime asset downloads, licensed logos or copyrighted car bodies.

const FEATURE_IDS = ["CAR_041", "HELI_01", "EXC_02"]
var vehicle_id: String = ""
var parent_visual
var palette: Dictionary = {}
var sweep_seconds: float = 0.0
var rescue_searchlight: SpotLight3D
const CARBON_ALBEDO = preload("res://assets/hero_carbon_albedo.png")
const CARBON_NORMAL = preload("res://assets/hero_carbon_normal.png")
const BRUSHED_NORMAL = preload("res://assets/hero_brushed_metal_normal.png")
const PAINT_NORMAL = preload("res://assets/hero_painted_metal_normal.png")

func configure(record: Dictionary, visual: Node3D) -> void:
    vehicle_id = str(record.get("id", ""))
    parent_visual = visual

func _ready() -> void:
    name = "HERO DETAIL | original procedural craft"
    match vehicle_id:
        "CAR_041": _build_sportscar()
        "HELI_01": _build_mountain_rescue()
        "EXC_02": _build_medium_excavator()

func _material(tint: Color, metal: float = 0.0, rough: float = 0.5, luminous: bool = false) -> StandardMaterial3D:
    var key := "%s_%.2f_%.2f_%d" % [tint.to_html(), metal, rough, int(luminous)]
    if palette.has(key):
        return palette[key]
    var result := StandardMaterial3D.new()
    result.albedo_color = tint
    result.metallic = metal
    result.roughness = rough
    result.cull_mode = BaseMaterial3D.CULL_DISABLED
    if metal > 0.18:
        result.clearcoat_enabled = true
        result.clearcoat = 0.6
        result.clearcoat_roughness = 0.13
    if luminous:
        result.emission_enabled = true
        result.emission = tint
        result.emission_energy_multiplier = 2.0
    # Author-created, tiled microscopic surface detail; remains light enough for WebGL.
    if tint.to_html(false) == Color("171c22").to_html(false):
        result.albedo_texture = CARBON_ALBEDO
        result.normal_enabled = true
        result.normal_texture = CARBON_NORMAL
        result.normal_scale = 0.22
    elif metal > 0.65:
        result.normal_enabled = true
        result.normal_texture = BRUSHED_NORMAL
        result.normal_scale = 0.15
    elif metal >= 0.18 and rough < 0.46:
        result.normal_enabled = true
        result.normal_texture = PAINT_NORMAL
        result.normal_scale = 0.10
    palette[key] = result
    return result

func _box(part_name: String, size: Vector3, pos: Vector3, surface: Material, parent: Node3D = null, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
    var result := MeshInstance3D.new()
    result.name = part_name
    var geometry := BoxMesh.new()
    geometry.size = size
    result.mesh = geometry
    result.material_override = surface
    result.position = pos
    result.rotation = rot
    var target: Node3D = self if parent == null else parent
    target.add_child(result)
    return result

func _cylinder(part_name: String, radius: float, height: float, pos: Vector3, surface: Material, parent: Node3D = null, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
    var result := MeshInstance3D.new()
    result.name = part_name
    var geometry := CylinderMesh.new()
    geometry.top_radius = radius
    geometry.bottom_radius = radius
    geometry.height = height
    geometry.radial_segments = 24
    result.mesh = geometry
    result.material_override = surface
    result.position = pos
    result.rotation = rot
    var target: Node3D = self if parent == null else parent
    target.add_child(result)
    return result

func _sphere(part_name: String, radius: float, pos: Vector3, surface: Material, parent: Node3D = null) -> MeshInstance3D:
    var result := MeshInstance3D.new()
    result.name = part_name
    var geometry := SphereMesh.new()
    geometry.radius = radius
    geometry.height = 2.0 * radius
    geometry.radial_segments = 16
    geometry.rings = 8
    result.mesh = geometry
    result.material_override = surface
    result.position = pos
    var target: Node3D = self if parent == null else parent
    target.add_child(result)
    return result

func _fin(part_name: String, vertices: PackedVector3Array, surface: Material, parent: Node3D = null) -> MeshInstance3D:
    # A welded original panel, back-face visible; no overly bright transparent decals.
    var mesh := ArrayMesh.new()
    var surface_arrays: Array = []
    surface_arrays.resize(Mesh.ARRAY_MAX)
    surface_arrays[Mesh.ARRAY_VERTEX] = vertices
    var normals := PackedVector3Array()
    for i in range(0, vertices.size(), 3):
        var normal := (vertices[i+1]-vertices[i]).cross(vertices[i+2]-vertices[i]).normalized()
        for _n in range(3):
            normals.append(normal)
    surface_arrays[Mesh.ARRAY_NORMAL] = normals
    mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_arrays)
    var node := MeshInstance3D.new()
    node.name = part_name
    node.mesh = mesh
    node.material_override = surface
    var target: Node3D = self if parent == null else parent
    target.add_child(node)
    return node

func _build_sportscar() -> void:
    # Nero Vortex prototype: racing accents, brakes, ducts, rear diffuser and detailed cabin.
    # Axes: front = -Z; wheel ground = ~0.12m; body height ~1.3m.
    var carbon := _material(Color("171c22"), 0.18, 0.32)
    var forged := _material(Color("69747d"), 0.80, 0.23)
    var rubber := _material(Color("202124"), 0.0, 0.97)
    var teal := _material(Color("1bbecb"), 0.28, 0.25)
    var red := _material(Color("a31f1a"), 0.35, 0.36)
    var white := _material(Color("e3f2e8"), 0.05, 0.16, true)
    var dark_glass := _material(Color("132c39"), 0.12, 0.08)
    var width: float = maxf(1.7, float(parent_visual.width))
    var length: float = maxf(4.4, float(parent_visual.length))
    var nose := -length * 0.5
    var tail := length * 0.5
    # Twin air channels and stepped splitter, separate from generic body.
    _box("HERO | Multi-element front splitter",Vector3(width * 0.97,0.055,0.30),Vector3(0,0.68,nose+0.05),carbon)
    for s in [-1.0,1.0]:
        _fin("HERO | sculpted headlight eyebrow",PackedVector3Array([
            Vector3(s*0.26,1.35,nose+0.13),Vector3(s*0.85,1.33,nose+0.09),Vector3(s*0.77,1.22,nose-0.01)
        ]),white)
        _box("HERO | horizontal front intake",Vector3(0.43,0.14,0.045),Vector3(s*width*0.32,0.97,nose-0.07),carbon)
        _box("HERO | sculpted sill",Vector3(0.13,0.085,length*0.47),Vector3(s*width*0.46,0.72,0.12),carbon)
        _box("HERO | side radiator intake",Vector3(0.055,0.33,0.75),Vector3(s*width*0.50,1.19,0.77),carbon,self,Vector3(0,0,s*0.16))
        _box("HERO | mirror indicator",Vector3(0.16,0.025,0.06),Vector3(s*(width*0.52+0.14),1.74,-0.67),teal)
        _box("HERO | rear brake-light strip",Vector3(0.55,0.055,0.06),Vector3(s*width*0.23,1.29,tail+0.11),red)
        _box("HERO | aerodynamic rear bumper vane",Vector3(0.055,0.26,0.55),Vector3(s*width*0.34,0.79,tail+0.08),carbon)
        _cylinder("HERO | twin exhaust",0.11,0.25,Vector3(s*width*0.17,0.84,tail+0.18),forged,self,Vector3(PI/2,0,0))
        # The owner animates actual wheels; brake-disc components are static in each wheel well.
        for z in [nose+length*0.24,tail-length*0.21]:
            _cylinder("HERO | ventilated brake rotor",0.30,0.02,Vector3(s*(width*0.49-0.05),0.56,z),forged,self,Vector3(0,0,PI/2))
            _box("HERO | performance brake caliper",Vector3(0.12,0.16,0.15),Vector3(s*(width*0.49+0.03),0.67,z-0.18),teal)
    _box("HERO | central hood sculpt",Vector3(width*0.41,0.045,1.01),Vector3(0,1.46,nose+1.01),carbon,self,Vector3(-0.05,0,0))
    for s in [-1.0,1.0]:
        for i in range(4):
            _box("HERO | recessed hood louvre",Vector3(0.065,0.019,0.18),Vector3(s*0.35,1.48,nose+1.30+i*0.15),carbon)
    _box("HERO | panoramic upper glass",Vector3(width*0.68,0.022,1.36),Vector3(0,1.86,-0.15),dark_glass)
    _box("HERO | rear carbon wing",Vector3(width*0.85,0.07,0.38),Vector3(0,1.76,tail-0.25),carbon,self,Vector3(-0.10,0,0))
    for s in [-1.0,1.0]:
        _box("HERO | wing support",Vector3(0.075,0.27,0.10),Vector3(s*0.57,1.58,tail-0.23),forged)
    # Details visible from outside if the camera passes through glazing.
    _box("HERO | dashboard display",Vector3(0.53,0.15,0.025),Vector3(-0.16,1.62,-0.71),teal,self,Vector3(-0.19,0,0))
    _box("HERO | seatbelt driver",Vector3(0.06,0.60,0.04),Vector3(-0.45,1.62,0.45),red,self,Vector3(0,0,-0.23))
    _box("HERO | seatbelt passenger",Vector3(0.06,0.60,0.04),Vector3(0.45,1.62,0.45),red,self,Vector3(0,0,0.23))
    _box("HERO | engine-view mesh behind seats",Vector3(width*0.58,0.10,0.74),Vector3(0,1.67,1.03),carbon)
    for j in range(6):
        _box("HERO | engine vent slat",Vector3(width*0.56,0.024,0.027),Vector3(0,1.73,0.78+j*0.11),forged)
    _box("HERO | tail centre accent",Vector3(0.50,0.03,0.035),Vector3(0,1.37,tail+0.17),teal)
    _box("HERO | original NEXUS emblem",Vector3(0.22,0.15,0.015),Vector3(0,1.49,tail+0.08),forged)
    _box("HERO | clean underbody",Vector3(width*0.80,0.07,length*0.72),Vector3(0,0.62,0),rubber)

func _build_mountain_rescue() -> void:
    var rescue_red := _material(Color("d62d32"),0.22,0.31)
    var signal_orange := _material(Color("f5ae38"),0.11,0.44)
    var anodized := _material(Color("9eaeb5"),0.72,0.31)
    var black := _material(Color("222a31"),0.25,0.6)
    var cream := _material(Color("e8efe8"),0.08,0.36)
    var glass := _material(Color("153c55"),0.18,0.14)
    var length: float = maxf(7.5,float(parent_visual.length))
    var width: float = maxf(1.8,float(parent_visual.width))
    for side in [-1.0,1.0]:
        # Original rescue livery with no third-party brand.
        _box("HERO | rescue cabin side stripe",Vector3(0.045,0.19,2.35),Vector3(side*width*0.443,1.76,0),rescue_red)
        _box("HERO | high visibility stripe",Vector3(0.05,0.075,2.28),Vector3(side*width*0.448,1.92,0.02),signal_orange)
        _box("HERO | door track",Vector3(0.04,0.045,1.16),Vector3(side*width*0.456,2.88,0.26),anodized)
        _box("HERO | service step",Vector3(0.43,0.08,1.29),Vector3(side*(width*0.49+0.13),1.06,0.30),black)
        _box("HERO | skid reinforcement",Vector3(0.12,0.08,length*0.62),Vector3(side*width*0.44,0.32,0.09),anodized)
        for i in range(3):
            _box("HERO | skid foot",Vector3(0.29,0.095,0.24),Vector3(side*width*0.44,0.29,-1.70+i*1.69),black)
    # Search-and-rescue cargo in visible open rear section.
    _box("HERO | removable rescue stretcher",Vector3(0.62,0.09,1.75),Vector3(0.33,1.34,0.34),signal_orange)
    _box("HERO | restraint base",Vector3(0.70,0.065,1.86),Vector3(0.33,1.19,0.34),black)
    _box("HERO | stretcher mattress",Vector3(0.54,0.07,1.51),Vector3(0.33,1.42,0.34),cream)
    for z in [-0.32,0.80]:
        _box("HERO | medical restraint",Vector3(0.58,0.024,0.06),Vector3(0.33,1.47,z),black)
    _box("HERO | rescue first-aid cabinet",Vector3(0.38,0.53,0.64),Vector3(-0.44,1.65,0.76),cream)
    _box("HERO | emergency medical marking",Vector3(0.26,0.06,0.02),Vector3(-0.44,1.72,0.429),rescue_red)
    _box("HERO | emergency medical marking vertical",Vector3(0.06,0.24,0.02),Vector3(-0.44,1.72,0.423),rescue_red)
    _box("HERO | avionics shelf",Vector3(width*0.61,0.11,0.48),Vector3(0,1.90,-1.60),black)
    for i in range(3):
        _box("HERO | cockpit instrumentation",Vector3(0.24,0.11,0.018),Vector3((i-1)*0.28,1.98,-1.86),glass)
    # Hoist and rescue winch on the right-hand side.
    _box("HERO | overhead rescue winch bracket",Vector3(0.55,0.14,0.20),Vector3(width*0.53,3.08,-0.46),anodized)
    _cylinder("HERO | winch drum",0.18,0.39,Vector3(width*0.66,3.05,-0.46),black,self,Vector3(0,0,PI/2))
    _box("HERO | dangling rescue wire",Vector3(0.022,1.10,0.022),Vector3(width*0.67,2.46,-0.46),anodized)
    _sphere("HERO | hoist anchor",0.10,Vector3(width*0.67,1.90,-0.46),signal_orange)
    # Fine tail and engine details.
    for i in range(8):
        _box("HERO | turbine intake grill",Vector3(0.034,0.19,0.043),Vector3(width*0.25,3.07,-0.89+i*0.12),black)
    for s in [-1.0,1.0]:
        _box("HERO | tail position light",Vector3(0.085,0.08,0.10),Vector3(s*0.15,2.82,length*0.76),signal_orange)
    # Light deliberately capped in preview performance settings.
    rescue_searchlight = SpotLight3D.new()
    rescue_searchlight.name = "HERO | rescue searchlight"
    rescue_searchlight.spot_range = 21.0
    rescue_searchlight.spot_angle = 33.0
    rescue_searchlight.shadow_enabled = false
    rescue_searchlight.light_color = Color("fff4df")
    rescue_searchlight.light_energy = 0.0
    rescue_searchlight.position = Vector3(-width*0.40,1.53,-1.84)
    rescue_searchlight.rotation_degrees.x = -40.0
    add_child(rescue_searchlight)
    _sphere("HERO | searchlight housing",0.19,rescue_searchlight.position,anodized)

func _build_medium_excavator() -> void:
    var paint := _material(Color("db9e21"),0.31,0.43)
    var steel := _material(Color("515b61"),0.68,0.54)
    var deep := _material(Color("1c242b"),0.12,0.87)
    var cabin := _material(Color("2b5669"),0.22,0.15)
    var warning := _material(Color("f4d857"),0.12,0.4)
    var width := maxf(1.8, float(parent_visual.width))
    var length := maxf(5.2, float(parent_visual.length))
    _box("HERO | weighted counterbalance",Vector3(width*0.78,0.43,0.68),Vector3(0,1.79,length*0.32),paint)
    _box("HERO | radiator protective grill",Vector3(width*0.67,0.34,0.04),Vector3(0,1.82,length*0.37+0.33),deep)
    for i in range(8):
        _box("HERO | cooling grill fin",Vector3(width*0.62,0.019,0.052),Vector3(0,1.68+i*0.042,length*0.37+0.37),steel)
    # FOPS/ROPS frame with cab glass and inner operating equipment.
    for x in [-width*0.39,-0.03]:
        for z in [-length*0.065,length*0.21]:
            _box("HERO | safety cab cage vertical",Vector3(0.055,1.33,0.056),Vector3(x,2.58,z),deep)
    _box("HERO | cab sun visor",Vector3(width*0.47,0.09,length*0.33),Vector3(-width*0.21,3.36,0.17),deep)
    _box("HERO | sloped side window",Vector3(0.03,0.94,0.72),Vector3(-width*0.44,2.67,0.14),cabin)
    _box("HERO | operator seat",Vector3(0.38,0.20,0.35),Vector3(-width*0.21,2.20,0.20),deep)
    _box("HERO | operator seat back",Vector3(0.38,0.66,0.10),Vector3(-width*0.21,2.55,0.36),deep)
    for s in [-1.0,1.0]:
        _box("HERO | joystick",Vector3(0.045,0.27,0.045),Vector3(-width*0.21+s*0.32,2.39,-0.08),deep)
        _sphere("HERO | joystick head",0.075,Vector3(-width*0.21+s*0.32,2.54,-0.08),steel)
        _box("HERO | tracked step tread",Vector3(0.17,0.055,0.61),Vector3(s*width*0.44,1.14,-0.46),steel)
        for i in range(5):
            _box("HERO | reflective stripe",Vector3(0.08,0.03,0.09),Vector3(s*width*0.47,1.45,-0.95+i*0.21),warning)
    if parent_visual.boom_pivot != null:
        var boom := parent_visual.boom_pivot
        # Details are children of the articulated arm: they follow the existing controls.
        _box("HERO | main boom wear strip",Vector3(0.31,0.08,1.88),Vector3(0,1.18,-0.78),steel,boom,Vector3(-0.56,0,0))
        _cylinder("HERO | hydraulic piston rod",0.044,1.13,Vector3(0,0.99,-0.90),_material(Color("c9d1d5"),0.91,0.19),boom,Vector3(-0.48,0,0))
        _box("HERO | routed hydraulic hose",Vector3(0.035,0.035,2.1),Vector3(0.21,1.35,-0.72),deep,boom,Vector3(-0.54,0,0))
        for i in range(3):
            _cylinder("HERO | articulated hose clamp",0.052,0.07,Vector3(0.20,0.74+i*0.34,-0.42-i*0.33),steel,boom,Vector3(0,0,PI/2))
    if parent_visual.bucket_pivot != null:
        var bucket := parent_visual.bucket_pivot
        _box("HERO | hardened bucket lip",Vector3(1.15,0.06,0.15),Vector3(0,-0.29,-0.43),steel,bucket)
        for i in range(5):
            _box("HERO | additional cutting edge tooth",Vector3(0.08,0.08,0.21),Vector3((i-2)*0.24,-0.32,-0.55),deep,bucket)

func animate_hero(delta: float, speed: float, steering: float, controlled: bool) -> void:
    sweep_seconds += delta
    if rescue_searchlight != null:
        rescue_searchlight.light_energy = 1.6 if controlled else 0.0
        rescue_searchlight.rotation_degrees.y = 8.0 * sin(sweep_seconds * 0.35)
