extends Node3D
## Interactive 3D star chart. Each destination loads a traversable level.
const CAMPAIGN = preload("res://scripts/nexus_campaign.gd")
const LORE = preload("res://scripts/nexus_lore.gd")
var planets: Array[Node3D] = []
var info: Label
var selected: int = 0
var campaign: Dictionary
var elapsed: float = 0.0
var star: MeshInstance3D

func _ready() -> void:
    campaign = CAMPAIGN.load_data()
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    _make_space()
    _make_orbits()
    _make_interface()
    _select_planet(0)

func _make_space() -> void:
    var camera = Camera3D.new()
    camera.position = Vector3(0, 76, 94)
    camera.rotation_degrees = Vector3(-40, 0, 0)
    camera.fov = 66
    camera.current = true
    add_child(camera)
    var world = WorldEnvironment.new()
    var env = Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("050912")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("7187a8")
    env.ambient_light_energy = 0.32
    env.glow_enabled = true
    env.glow_intensity = 0.9
    world.environment = env
    add_child(world)
    var sun_light = OmniLight3D.new()
    sun_light.light_color = Color("ffe2a5")
    sun_light.light_energy = 7.0
    sun_light.omni_range = 125
    sun_light.shadow_enabled = false
    add_child(sun_light)
    star = _sphere("NEXUS-Sonne", 5.6, Color("ffd18b"), true)
    var rng = RandomNumberGenerator.new()
    rng.seed = 82913
    var stars = MultiMesh.new()
    stars.transform_format = MultiMesh.TRANSFORM_3D
    stars.mesh = SphereMesh.new()
    stars.mesh.radius = 0.07
    stars.mesh.height = 0.14
    stars.instance_count = 700
    for i in range(stars.instance_count):
        var p = Vector3(rng.randf_range(-175,175),rng.randf_range(-72,85),rng.randf_range(-170,130))
        stars.set_instance_transform(i, Transform3D(Basis.IDENTITY, p))
    var stars_mesh = MultiMeshInstance3D.new()
    stars_mesh.multimesh = stars
    stars_mesh.material_override = _mat(Color("c3e1ff"), true)
    add_child(stars_mesh)

func _mat(color: Color, light_up: bool = false) -> StandardMaterial3D:
    var m = StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.75
    if light_up:
        m.emission_enabled = true
        m.emission = color
        m.emission_energy_multiplier = 1.8
    return m

func _sphere(label: String, radius: float, color: Color, light_up: bool = false) -> MeshInstance3D:
    var mesh = MeshInstance3D.new()
    mesh.name = label
    var shape = SphereMesh.new()
    shape.radius = radius
    shape.height = radius * 2.0
    shape.radial_segments = 48
    shape.rings = 24
    mesh.mesh = shape
    mesh.material_override = _mat(color, light_up)
    add_child(mesh)
    return mesh

func _make_orbits() -> void:
    for data in CAMPAIGN.PLANETS:
        var r: float = float(data["orbit"])
        var vertices = PackedVector3Array()
        for i in range(129):
            var angle = float(i) / 128.0 * TAU
            vertices.append(Vector3(cos(angle) * r, 0, sin(angle) * r))
        var lines = ImmediateMesh.new()
        lines.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, _mat(Color("37516b"), true))
        for pt in vertices:
            lines.surface_add_vertex(pt)
        lines.surface_end()
        var track = MeshInstance3D.new()
        track.mesh = lines
        add_child(track)
        var body = Node3D.new()
        add_child(body)
        var surface = SphereMesh.new()
        surface.radius = float(data["size"])
        surface.height = float(data["size"]) * 2.0
        surface.radial_segments = 32
        surface.rings = 18
        var planet_mesh = MeshInstance3D.new()
        planet_mesh.mesh = surface
        planet_mesh.material_override = _mat(data["color"])
        body.add_child(planet_mesh)
        var halo = OmniLight3D.new()
        halo.light_color = data["color"]
        halo.light_energy = 0.85
        halo.omni_range = 7.5
        body.add_child(halo)
        planets.append(body)

func _make_interface() -> void:
    var layer = CanvasLayer.new()
    add_child(layer)
    var panel = PanelContainer.new()
    panel.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
    panel.position = Vector2(20, 20)
    panel.custom_minimum_size = Vector2(410, 0)
    layer.add_child(panel)
    var column = VBoxContainer.new()
    column.add_theme_constant_override("separation", 9)
    panel.add_child(column)
    var heading = Label.new()
    heading.text = "NEXUS // STERNENKARTE"
    heading.add_theme_font_size_override("font_size", 24)
    column.add_child(heading)
    info = Label.new()
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    info.custom_minimum_size = Vector2(400, 85)
    column.add_child(info)
    for i in range(CAMPAIGN.PLANETS.size()):
        var idx: int = i
        var p: Dictionary = CAMPAIGN.PLANETS[i]
        var button = Button.new()
        button.text = "%d  %s  -  %s" % [i+1, p["name"], p["subtitle"]]
        button.custom_minimum_size.y = 35
        button.pressed.connect(func(): _select_planet(idx))
        column.add_child(button)
    var embark = Button.new()
    embark.text = "▶  LANDE AUF AUSGEWAEHLTEM PLANETEN"
    embark.custom_minimum_size.y = 44
    embark.pressed.connect(_land)
    column.add_child(embark)
    var back = Button.new()
    back.text = "↩  ZUR ALPINEN HEIMATWELT"
    back.pressed.connect(_back_home)
    column.add_child(back)

func _process(delta: float) -> void:
    elapsed += delta
    star.rotate_y(delta * 0.03)
    for i in range(planets.size()):
        var data = CAMPAIGN.PLANETS[i]
        var angle = float(i) * 1.8 + elapsed / float(data["period"]) * TAU
        var radius = float(data["orbit"])
        planets[i].position = Vector3(cos(angle) * radius, 0, sin(angle) * radius)
        planets[i].rotate_y(delta * 0.12)

func _select_planet(idx: int) -> void:
    selected = clampi(idx, 0, CAMPAIGN.PLANETS.size()-1)
    var p: Dictionary = CAMPAIGN.PLANETS[selected]
    var done: Array = campaign.get("completed", [])
    info.text = "%s\n%s\n%s\nStatus: %s  |  Datenfragmente: %d / 6" % [
        p["chapter"], p["subtitle"], p["objective"],
        "ABGESCHLOSSEN" if done.has(p["id"]) else "OFFEN", int(campaign.get("intel",0))]
    info.text += "\nFRAKTION: " + str(LORE.info(str(p["id"]))["faction"])

func _land() -> void:
    var p: Dictionary = CAMPAIGN.PLANETS[selected]
    campaign["planet"] = p["id"]
    CAMPAIGN.save_data(campaign)
    get_tree().change_scene_to_file("res://scenes/planet.tscn")

func _back_home() -> void:
    get_tree().change_scene_to_file("res://scenes/main.tscn")

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode >= KEY_1 and event.keycode <= KEY_6:
            _select_planet(event.keycode - KEY_1)
        elif event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
            _land()
        elif event.keycode == KEY_ESCAPE:
            _back_home()
