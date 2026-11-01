extends Node3D
class_name NexusSetDressing
## Landmark props improve readability and set composition; NOT photorealistic scanned assets.
var rng := RandomNumberGenerator.new()
var materials: Dictionary = {}

func _ready() -> void:
    rng.seed = 190922
    name = "NEXUS CINEMATIC SET DRESSING - ALPEN / STADT / SEKTOREN"
    _make_rescue_zone()
    _make_quarantine_zone()
    _make_city_response()
    _make_reconstruction_site()
    _make_forest_stops()

func _material(tint: Color, emissive: bool = false) -> StandardMaterial3D:
    var key = str(tint.to_html()) + ("_e" if emissive else "")
    if materials.has(key):
        return materials[key]
    var material = StandardMaterial3D.new()
    material.albedo_color = tint
    material.metallic = 0.25
    material.roughness = 0.73
    if emissive:
        material.emission_enabled = true
        material.emission = tint
        material.emission_energy_multiplier = 2.0
    materials[key] = material
    return material

func _box(pos: Vector3, size: Vector3, color: Color, angle: float = 0.0, collision: bool = false) -> Node3D:
    var group: Node3D = StaticBody3D.new() if collision else Node3D.new()
    group.position = pos
    group.rotation.y = angle
    add_child(group)
    var mesh = MeshInstance3D.new()
    var cube = BoxMesh.new()
    cube.size = size
    mesh.mesh = cube
    mesh.material_override = _material(color)
    group.add_child(mesh)
    if collision:
        var hit = CollisionShape3D.new()
        var shape = BoxShape3D.new()
        shape.size = size
        hit.shape = shape
        group.add_child(hit)
    return group

func _lamp(pos: Vector3, color: Color, power: float, range_value: float) -> void:
    var light = OmniLight3D.new()
    light.position = pos
    light.light_color = color
    light.light_energy = power
    light.omni_range = range_value
    light.shadow_enabled = false
    add_child(light)

func _sign(pos: Vector3, text_value: String, tint: Color, scale_value: float = 0.006) -> void:
    var sign = Label3D.new()
    sign.text = text_value
    sign.position = pos
    sign.font_size = 34
    sign.pixel_size = scale_value
    sign.modulate = tint
    sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    add_child(sign)

func _make_rescue_zone() -> void:
    # High-contrast helipad + signaling; rescue point centered near existing rescue district.
    var center = Vector3(50, 0.11, 61)
    _box(center,Vector3(15,0.15,15),Color("394349"))
    for angle in range(24):
        var a = TAU * angle / 24.0
        _box(center+Vector3(cos(a)*6.5,0.11,sin(a)*6.5),Vector3(0.45,0.05,1.15),Color("e5dacc"),-a)
    _sign(center+Vector3(0,4.5,0),"H  //  BERGRETTUNG",Color("e9f5f6"))
    for side in [-1,1]:
        var base = center + Vector3(side*11,0,8)
        _box(base+Vector3(0,2.2,0),Vector3(0.25,4.4,0.25),Color("66737c"))
        _box(base+Vector3(0,4.5,0),Vector3(2.8,0.18,0.8),Color("e7eee7"))
        _lamp(base+Vector3(0,4.2,0),Color("d9e6ff"),1.4,16)
    for i in range(15):
        var r = rng.randf_range(16,24)
        var a = rng.randf_range(0,TAU)
        _box(center+Vector3(cos(a)*r,0.18,sin(a)*r),Vector3(0.7,0.4,rng.randf_range(0.8,1.8)),Color("6d7779"),rng.randf_range(0,TAU))

func _make_quarantine_zone() -> void:
    var center = Vector3(116,0,-11)
    var steel = Color("4e5a60")
    for dx in [-19.0, 19.0]:
        for i in range(9):
            var z = -18.0 + i*4.5
            _box(center+Vector3(dx,2.2,z),Vector3(0.14,4.4,0.16),steel,0,true)
            _box(center+Vector3(dx,2.5,z+2.05),Vector3(0.05,3.3,4.05),Color(0.32,0.37,0.38,0.45))
    for dz in [-18.0,18.0]:
        for i in range(10):
            var x = -19.0+i*4.2
            _box(center+Vector3(x,2.4,dz),Vector3(0.13,4.8,0.15),steel,0,true)
            _box(center+Vector3(x+2.0,2.1,dz),Vector3(3.8,3.0,0.05),Color("434b50"))
    for side in [-1.0,1.0]:
        var tower = center + Vector3(side*16,0,-16)
        _box(tower+Vector3(0,4,0),Vector3(3.0,8,3.0),steel,0,true)
        _box(tower+Vector3(0,8.1,0),Vector3(5,1.0,5),Color("282f36"))
        _box(tower+Vector3(0,6.9,-2.0),Vector3(2.8,0.95,0.08),Color("99afbc"))
        _lamp(tower+Vector3(0,7.2,-2.3),Color("cddcff"),1.5,27)
    _sign(center+Vector3(0,6,-20),"SEKTOR 31  //  QUARANTAENE",Color("f2e5d1"),0.009)
    _box(center+Vector3(0,0.12,-19),Vector3(10,0.25,1.3),Color("a28d42"))
    for j in range(12):
        _box(center+Vector3(rng.randf_range(-15,15),0.4,rng.randf_range(-14,14)),Vector3(1.3,0.8,1.0),Color("525a55"),rng.randf_range(-1,1))

func _make_city_response() -> void:
    var center = Vector3(-62,0,59)
    for i in range(14):
        var side = -1.0 if i%2==0 else 1.0
        var z = -34 + i*5.5
        var building = center+Vector3(side*20,0,z)
        var floors = rng.randi_range(3,7)
        _box(building+Vector3(0,floors*2,0),Vector3(10.0,floors*4.0,9.5),Color("6a7379") if i%3 else Color("807a72"),0,true)
        for floor in range(floors):
            for lane in range(3):
                var win = building + Vector3(-3.5+lane*3.3,1.8+floor*3.45,(-4.8 if side>0 else 4.8))
                _box(win,Vector3(1.65,1.4,0.08),Color("829da9") if floor%3 else Color("c5b78a"))
    for i in range(9):
        var z = -35 + i*10
        _box(center+Vector3(-9.2,3.7,z),Vector3(0.23,7.4,0.25),Color("58626a"))
        _lamp(center+Vector3(-9.2,7.2,z),Color("ffd2a0"),1.0,14.0)
    for i in range(15):
        var z = -36 + i*5.0
        _box(center+Vector3(-3.8,0.23,z),Vector3(0.15,0.025,2.8),Color("e3d5b5"))
    _sign(center+Vector3(0,6,-30),"NEXUS CITY   //   LEITSTELLE",Color("d1e7f5"))

func _make_reconstruction_site() -> void:
    var center = Vector3(-55,0,107)
    _sign(center+Vector3(0,6,-10),"WIEDERAUFBAU  //  BAUABSCHNITT 7",Color("f9e7bd"))
    for i in range(5):
        var pos = center+Vector3(-24 + i*11,0,12+(i%2)*15)
        var height = 5.0 + rng.randi_range(0,3)*3
        _box(pos+Vector3(0,height/2,0),Vector3(8,height,7),Color("868780"),0,true)
        for j in range(3):
            _box(pos+Vector3(-3.8+j*3.3,height+0.2,-3.1),Vector3(0.18,3.0,0.18),Color("60676a"))
        _box(pos+Vector3(0,height+0.7,0),Vector3(9.0,0.3,8),Color("c6ad8f"))
    for i in range(2):
        var c = center+Vector3(-16 + i*26,0,-18)
        _box(c+Vector3(0,12,0),Vector3(1.3,24,1.3),Color("bb9a3e"))
        _box(c+Vector3(12,24,0),Vector3(26,0.75,0.7),Color("bb9a3e"))
        _box(c+Vector3(19,15.5,0),Vector3(0.13,16,0.13),Color("57595a"))
        _box(c+Vector3(19,7.5,0),Vector3(1.5,1.5,2.0),Color("6c6760"))
    for i in range(30):
        var pos = center+Vector3(rng.randf_range(-30,28),0.6,rng.randf_range(-15,25))
        _box(pos,Vector3(rng.randf_range(0.35,1.1),rng.randf_range(0.3,1.2),rng.randf_range(0.4,1.3)),Color("7e756a"),rng.randf_range(0,TAU))

func _make_forest_stops() -> void:
    for x in range(-3,4):
        var p = Vector3(-10+x*3,0,-37)
        _box(p+Vector3(0,0.2,0),Vector3(2.7,0.35,1.2),Color("4c4d49"))
    _sign(Vector3(-10,4,-38),"WALDBRAND- & FORSTEINSATZ",Color("dce6cb"))
