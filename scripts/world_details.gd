extends Node3D
## PROJECT NEXUS V0.8: four authored sandbox districts (procedural placeholder geometry).
## No claim of AAA fidelity. Coordinates share native Godot project's physical world.

var stone: StandardMaterial3D
var mortar: StandardMaterial3D
var tar: StandardMaterial3D
var glass_mat: StandardMaterial3D
var wood_mat: StandardMaterial3D
var white: StandardMaterial3D
var orange: StandardMaterial3D
var steel: StandardMaterial3D
var danger: StandardMaterial3D
var emissive_blue: StandardMaterial3D
var yellow: StandardMaterial3D

func _ready() -> void:
    name = "NEXUS – four detailed districts"
    stone = _mat(Color("a1a3a0"), "alpine_stone", 1.0)
    mortar = _mat(Color("dadbd4"), "city_concrete", 1.0)
    tar = _mat(Color("6b7279"), "wet_street", 1.0)
    glass_mat = _mat(Color("7a9cae"), "", 0.28, 0.12)
    wood_mat = _mat(Color("9f8060"), "wood", 0.95)
    white = _mat(Color("e7e9e4"))
    orange = _mat(Color("d85a22"))
    steel = _mat(Color("626b73"), "metal", 0.55, 0.55)
    danger = _mat(Color("ae493c"), "military_rust", 0.78)
    emissive_blue = _mat(Color("59beff"), "", 0.18, 0.0, true)
    yellow = _mat(Color("e9c568"))
    _roads_and_signage()
    _medieval_district()
    _rescue_district()
    _quarantine_district()
    _front_district()
    _construction_district()
    # Distant cliffs now use a connected mountain mesh in cinematic_landscape.gd.

func _mat(color: Color, texture: String = "", rough: float = 0.82, metallic: float = 0.0, glowing: bool = false) -> StandardMaterial3D:
    var m = StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = rough
    m.metallic = metallic
    if texture != "":
        m.albedo_texture = load("res://assets/" + texture + ".png")
    if glowing:
        m.emission_enabled = true
        m.emission = color
        m.emission_energy_multiplier = 1.8
    return m

func _box(label: String, pos: Vector3, size: Vector3, mat: Material, solid: bool = false) -> Node3D:
    var n: Node3D = StaticBody3D.new() if solid else Node3D.new()
    n.name = label
    n.position = pos
    add_child(n)
    var vi = MeshInstance3D.new()
    var mesh = BoxMesh.new()
    mesh.size = size
    vi.mesh = mesh
    vi.material_override = mat
    n.add_child(vi)
    if solid:
        var cs = CollisionShape3D.new()
        var sh = BoxShape3D.new()
        sh.size = size
        cs.shape = sh
        n.add_child(cs)
    return n

func _cylinder(label: String, pos: Vector3, r: float, height: float, mat: Material, top_radius: float = -1.0) -> Node3D:
    var n = Node3D.new()
    n.name = label
    n.position = pos
    add_child(n)
    var vi = MeshInstance3D.new()
    var mesh = CylinderMesh.new()
    mesh.bottom_radius = r
    mesh.top_radius = r if top_radius < 0 else top_radius
    mesh.height = height
    mesh.radial_segments = 12
    vi.mesh = mesh
    vi.material_override = mat
    n.add_child(vi)
    return n

func _sphere(label: String, pos: Vector3, radius: float, mat: Material) -> void:
    var vi = MeshInstance3D.new()
    vi.name = label
    var mesh = SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    mesh.radial_segments = 12
    mesh.rings = 8
    vi.mesh = mesh
    vi.position = pos
    vi.material_override = mat
    add_child(vi)

func _sign(title: String, pos: Vector3, size: int = 40, color: Color = Color.WHITE) -> void:
    var l = Label3D.new()
    l.name = "Schild " + title
    l.text = title
    l.position = pos
    l.font_size = size
    l.pixel_size = 0.006
    l.modulate = color
    l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    l.no_depth_test = false
    add_child(l)

func _lamp(pos: Vector3, color: Color, brightness: float = 1.6) -> void:
    _cylinder("Laternenmast", pos + Vector3(0, 3.4, 0), 0.08, 6.8, steel)
    _box("Lampe", pos + Vector3(0, 6.8, 0), Vector3(0.85, 0.22, 0.7), white)
    var light = OmniLight3D.new()
    light.position = pos + Vector3(0, 6.5, 0)
    light.light_color = color
    light.light_energy = brightness
    light.omni_range = 14.0
    light.shadow_enabled = false
    add_child(light)

func _roads_and_signage() -> void:
    # Road paint and roadside posts make the otherwise flat arena easier to navigate.
    for i in range(-16, 17):
        _box("Fahrbahnmarkierung", Vector3(float(i) * 5.0, 0.041, 0), Vector3(2.4, 0.018, 0.11), yellow)
    for i in range(-9, 10):
        _box("Fahrbahnmarkierung Quer", Vector3(55, 0.047, float(i) * 5.0), Vector3(0.13, 0.015, 2.4), yellow)
    for i in range(11):
        var z = -70.0 + float(i) * 13.0
        _box("Leitpfosten", Vector3(-9.0, 0.7, z), Vector3(0.2, 1.4, 0.18), white)
    _sign("NEXUS / ALPINE  ·  ARBEIT  ·  ERKUNDUNG", Vector3(12, 4.1, 4), 47)

func _timber_frame_house(p: Vector3, w: float, length: float, name_tag: String) -> void:
    _box(name_tag + " Sockel", p + Vector3(0, 0.24, 0), Vector3(w + 0.5, 0.48, length + 0.5), stone)
    _box(name_tag + " Fassade", p + Vector3(0, 2.6, 0), Vector3(w, 4.8, length), mortar, true)
    for x in [-w * 0.43, w * 0.43]:
        for z in [-length * 0.43, length * 0.43]:
            _box("Fachwerkpfosten", p + Vector3(x, 2.6, z), Vector3(0.20, 5.0, 0.2), wood_mat)
    for z in [-length * 0.51, length * 0.51]:
        _box("Fachwerk-Riegel", p + Vector3(0, 3.1, z), Vector3(w, 0.25, 0.20), wood_mat)
        _box("Fenster", p + Vector3(w * 0.24, 3.2, z), Vector3(1.1, 1.2, 0.06), glass_mat)
        _box("Fenster", p + Vector3(-w * 0.24, 3.2, z), Vector3(1.1, 1.2, 0.06), glass_mat)
    for slope in [-1.0, 1.0]:
        var roof = _box("Giebeldach", p + Vector3(slope * w * 0.25, 5.42, 0), Vector3(w * 0.64, 0.24, length + 0.9), danger)
        roof.rotation.z = slope * 0.45

func _medieval_district() -> void:
    _sign("ELDORIA  ·  ALTES KOENIGREICH", Vector3(99, 5.8, -63), 45)
    for i in range(7):
        var x = 73.0 + float(i % 4) * 13.0
        var z = -75.0 + float(i / 4) * 25.0
        _timber_frame_house(Vector3(x, 0, z), 7.5, 8.2, "Mittelalterhaus")
    _cylinder("Dorfbrunnen", Vector3(107, 0.65, -17), 2.2, 1.3, stone)
    _cylinder("Brunnenwasser", Vector3(107, 1.37, -17), 1.75, 0.08, glass_mat)
    _cylinder("Brunnendach", Vector3(107, 3.9, -17), 2.3, 0.65, danger, 0.01)
    for x in range(6):
        _box("Marktstand", Vector3(78 + x * 7, 0.8, -8), Vector3(4.4, 1.6, 2.0), wood_mat)
        roof_for_stall(Vector3(78 + x * 7, 2.5, -8))
    for x in range(6):
        _box("Burgzinnen", Vector3(-159 + x * 8.2, 16.2, -150), Vector3(3.0, 2.0, 1.5), stone)
    for x in range(5):
        _box("Burgfenster", Vector3(-154 + x * 9.0, 11.0, -142.1), Vector3(1, 2.0, 0.2), glass_mat)

func roof_for_stall(p: Vector3) -> void:
    _box("Marktdach", p, Vector3(4.6, 0.15, 3.0), danger)

func _helicopter_prop(p: Vector3) -> void:
    _box("Hubschrauber Rumpf", p + Vector3(0, 2.15, 0), Vector3(2.35, 1.65, 4.2), orange)
    _box("Kanzel", p + Vector3(0, 2.25, -1.6), Vector3(1.9, 1.0, 0.12), glass_mat)
    _box("Heckausleger", p + Vector3(0, 2.22, 4.0), Vector3(0.54, 0.44, 4.4), orange)
    _box("Hauptrotor", p + Vector3(0, 3.12, 0), Vector3(9.4, 0.09, 0.22), steel)
    _box("Heckrotor", p + Vector3(0, 3.0, 6.2), Vector3(0.1, 2.1, 0.12), steel)
    for x in [-1.1, 1.1]:
        _box("Landekufe", p + Vector3(x, 0.72, 0), Vector3(0.13, 0.14, 4.5), steel)

func _rescue_district() -> void:
    var p = Vector3(66, 0, 43)
    _cylinder("Landeplatz", p + Vector3(0, 0.09, 0), 9.6, 0.18, tar)
    _box("Helipad H Mitte", p + Vector3(0, 0.19, 0), Vector3(0.7, 0.04, 7.0), white)
    _box("Helipad H Balken", p + Vector3(0, 0.19, 0), Vector3(5.0, 0.04, 0.7), white)
    _helicopter_prop(p + Vector3(0, 0.18, 0))
    _sign("BERGRETTUNG  ·  112", Vector3(49, 6.4, 24), 46, Color("ddf4ff"))
    for i in range(5):
        _cylinder("Fels", Vector3(78 + i * 4.1, 1.3, 78), 2.2, 2.6, stone)
    _box("Verletzter Wanderer – Missionsziel", Vector3(74, 0.62, 72), Vector3(0.67, 1.23, 0.4), orange)
    _sign("RETTUNG: E BEI WANDERER", Vector3(74, 3.1, 72), 30, Color("fbeebe"))
    _lamp(Vector3(55, 0, 19), Color("b8e9ff"), 1.3)

func _watch_tower(p: Vector3) -> void:
    for dx in [-1.5, 1.5]:
        for dz in [-1.5, 1.5]:
            _box("Wachturm Stuetzen", p + Vector3(dx, 4.3, dz), Vector3(0.3, 8.6, 0.3), steel)
    _box("Wachturm Plattform", p + Vector3(0, 8.8, 0), Vector3(4.8, 0.4, 4.8), tar)
    _box("Wachturm Kabine", p + Vector3(0, 10.1, 0), Vector3(3.5, 2.1, 3.5), glass_mat)
    _box("Wachturm Dach", p + Vector3(0, 11.4, 0), Vector3(4.9, 0.42, 4.8), steel)

func _quarantine_district() -> void:
    var p = Vector3(117, 0, 114)
    _box("Sektor 31 Hof", p + Vector3(0, 0.04, 0), Vector3(59, 0.09, 55), tar)
    for x in [-28.0, 28.0]:
        _box("Sektor 31 Sicherheitsmauer", p + Vector3(x, 3.2, 0), Vector3(0.65, 6.4, 55), stone, true)
    for z in [-27.0, 27.0]:
        _box("Sektor 31 Mauer", p + Vector3(0, 3.2, z), Vector3(58, 6.4, 0.65), stone, true)
    _watch_tower(p + Vector3(-25, 0, -24))
    _watch_tower(p + Vector3(25, 0, 24))
    for i in range(6):
        _box("Quarantaene Container", p + Vector3(-17 + (i % 3) * 13, 1.6, -10 + int(i / 3) * 16), Vector3(9.0, 3.1, 6.4), steel)
    _box("Notfall Beacon", p + Vector3(0, 5.9, 0), Vector3(0.7, 0.8, 0.7), emissive_blue)
    _sign("SEKTOR 31  ·  QUARANTAENE", p + Vector3(0, 7.5, -28), 45, Color("ffbbb0"))
    _box("Forschungsprobe", p + Vector3(0, 1.2, -5), Vector3(1.0, 2.4, 1.0), emissive_blue)
    for q in [Vector3(92, 0, 95), Vector3(131, 0, 96), Vector3(118, 0, 139)]:
        _lamp(q, Color("c2e4ff"), 1.8)

func _front_district() -> void:
    var p = Vector3(-101, 0, -111)
    var dust = _mat(Color("a59b82"), "alpine_mud")
    for i in range(12):
        var x = -146.0 + float(i % 4) * 26.0
        var z = -132.0 + float(i / 4) * 22.0
        _box("Ruine Wand", Vector3(x, 3.1, z), Vector3(7.8, 6.2, 0.8), stone, true)
        _box("Ruine Seitenmauer", Vector3(x-3.3, 1.8, z+3.2), Vector3(0.7, 3.6, 7.0), stone)
        _box("Gebaeudereste", Vector3(x+3.0, 0.9, z-2.2), Vector3(3.8, 1.8, 4.2), dust)
        for j in range(5):
            _box("Truemmer", Vector3(x - 2 + float(j)*0.95, 0.3, z + 4.5), Vector3(0.8, 0.6, 0.6), stone)
    for i in range(9):
        _box("Schuetzengraben Barrikade", Vector3(-146 + 6.3 * i, 0.95, -84), Vector3(4.0, 1.9, 1.2), wood_mat)
    _sign("VARGOS  ·  HISTORISCHE FRONT 1945", p + Vector3(0, 6.0, -4), 45)
    _box("Flaggenmast", p + Vector3(0, 5.0, 0), Vector3(0.15, 10, 0.15), steel)
    _box("Fahne Missionsziel", p + Vector3(1.8, 8.2, 0), Vector3(3.5, 1.5, 0.1), danger)

func _construction_district() -> void:
    var p = Vector3(-59, 0, 87)
    _box("Baustellen Grund", p + Vector3(0, 0.05, 0), Vector3(52, 0.1, 46), _mat(Color("a39c88"), "alpine_mud"))
    for x in range(4):
        for z in range(3):
            _cylinder("Rohbau Saeule", p + Vector3(-15 + x*10, 4.5, -13 + z*10), 0.4, 9, stone)
    for level in [3.0, 7.0]:
        _box("Betondecke", p + Vector3(0, level, 0), Vector3(34, 0.55, 28), mortar)
    _cylinder("Kran Mast", p + Vector3(22, 17, 0), 0.6, 34, yellow)
    _box("Kran Ausleger", p + Vector3(8, 33, 0), Vector3(46, 0.7, 1.0), yellow)
    _box("Kran Gegengewicht", p + Vector3(26, 33, 0), Vector3(8, 2.0, 2), steel)
    _box("Kran Seil", p + Vector3(-10, 27, 0), Vector3(0.13, 13, 0.13), steel)
    _box("Kran Haken", p + Vector3(-10, 20, 0), Vector3(1.2, 0.7, 1.2), orange)
    _sign("WIEDERAUFBAU – BAUSTELLE", p + Vector3(-2, 6, -28), 42)

func _distant_cliffs() -> void:
    var rockmat = _mat(Color("b2b3b0"), "alpine_stone")
    var snowmat = _mat(Color("f3f5f4"), "rescue_snow")
    for i in range(40):
        var angle = float(i) / 40.0 * TAU
        var radius = 204.0 + 21.0 * sin(float(i) * 4.71)
        var height = 45.0 + float((i * 71) % 84)
        var p = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
        _cylinder("Gebirgskamm", p + Vector3(0, height * 0.45, 0), 27.0, height * 0.9, rockmat, 0.1)
        _cylinder("Schneegipfel", p + Vector3(0, height - 9, 0), 7.8, 19, snowmat, 0.1)
