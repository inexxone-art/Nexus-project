extends Node3D
## PROJECT NEXUS - Living Universe V1.4: world simulation, cinematic polish, six planets
## An original, small-scale native 3D game foundation. No multiplayer or AAA claim.

const STORY_SCRIPT = preload("res://scripts/nexus_story.gd")
const LANDSCAPE_SCRIPT = preload("res://scripts/cinematic_landscape.gd")
const DIRECTOR_SCRIPT = preload("res://scripts/nexus_director.gd")
var story: NexusStory
var landscape: NexusCinematicLandscape
var nexus_director: NexusDirector
const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const VEHICLE_SCRIPT = preload("res://scripts/vehicle.gd")
const CATALOG_SCRIPT = preload("res://scripts/nexus_vehicle_catalog.gd")
const FLEET_MENU_SCRIPT = preload("res://scripts/nexus_fleet_menu.gd")
const SET_DRESSING_SCRIPT = preload("res://scripts/nexus_set_dressing.gd")
const WORLD_OPS_SCRIPT = preload("res://scripts/nexus_world_operations.gd")
const COOP_SCRIPT = preload("res://scripts/nexus_coop_preview.gd")
const LIVING_SCRIPT = preload("res://scripts/nexus_living_universe.gd")
const LIVING_PANEL_SCRIPT = preload("res://scripts/nexus_living_panel.gd")
const POLISH_SCRIPT = preload("res://scripts/nexus_cinematic_polish.gd")
const WEATHER_FX_SCRIPT = preload("res://scripts/nexus_weather_fx.gd")
var weather_fx: NexusWeatherFX
var living: NexusLivingUniverse
var living_panel: NexusLivingPanel
var visual_polish: NexusCinematicPolish
var coop: NexusCoopPreview
var fleet_menu: NexusFleetMenu
var world_operations: NexusWorldOperations
var fleet_spawn_count: int = 0
const SAVE_PATH = "user://nexus_alpine_v08.json" # Backwards-compatible with V0.8 saves
const DETAILS_SCRIPT = preload("res://scripts/world_details.gd")
const MISSIONS_SCRIPT = preload("res://scripts/missions.gd")
const DRONE_SCRIPT = preload("res://scripts/drone.gd")
const MAP_SCRIPT = preload("res://scripts/nexus_map.gd")
const WORLD_CLOCK_SCRIPT = preload("res://scripts/world_clock.gd")
var missions: NexusMissions
var world_clock: NexusWorldClock
var minimap: Control
var drone: NexusDrone
var drone_active: bool = false
var build_valid: bool = false
var crops: int = 0
var paper: int = 0
var refined_fuel: int = 0
var meteor: int = 0
var tech_level: int = 0
var completed_jobs: int = 0
var build_grid: float = 1.0
var build_height: float = 0.0

var player: NexusPlayer
var vehicle_in_use: NexusVehicle = null
var vehicles: Array[NexusVehicle] = []
var stations: Array = []
var trees: Array = []
var logs: Array = []
var constructions: Array = []
var chopped_ids: Array = []
var tow_log: Node3D = null
var mode_build: bool = false
var build_kind: int = 0
var build_rotation: float = 0.0
var coins: int = 3000
var wood: int = 12
var iron: int = 10
var oil: int = 0
var gold: int = 0
var sold_logs: int = 0
var resource_cooldown: float = 0.0
var notice: String = "Willkommen in PROJECT NEXUS."
var notice_time: float = 5.0
var hud: Label
var help: Label
var marker: MeshInstance3D
var root_objects: Node3D
var ground_body: StaticBody3D
var sky_light: DirectionalLight3D
var build_sizes = [Vector3(4, 0.28, 4), Vector3(4, 3, 0.26), Vector3(4, 0.28, 4), Vector3(2, 2.5, 2), Vector3(1.6, 3, 0.28), Vector3(4, 0.25, 0.75), Vector3(2, 3, 0.12), Vector3(4, 0.18, 6), Vector3(4, 0.6, 4), Vector3(0.35, 4, 0.35)]
var build_names = ["Fundament", "Wand", "Dach", "Industrieblock", "Tuerrahmen", "Traeger", "Glaswand", "Strasse", "Betonplatte", "Stuetze"]

func _ready() -> void:
    _make_environment()
    world_clock = WORLD_CLOCK_SCRIPT.new()
    world_clock.name = "Wetter und Tageszeit"
    add_child(world_clock)
    world_clock.configure(sky_light, get_node("WorldEnvironment"))
    root_objects = Node3D.new()
    root_objects.name = "Persistente Objekte"
    add_child(root_objects)
    _make_land()
    landscape = LANDSCAPE_SCRIPT.new()
    add_child(landscape)
    _make_roads()
    _make_village()
    _make_stations()
    var set_dressing = SET_DRESSING_SCRIPT.new()
    add_child(set_dressing)
    var details = DETAILS_SCRIPT.new()
    add_child(details)
    visual_polish = POLISH_SCRIPT.new()
    add_child(visual_polish)
    nexus_director = DIRECTOR_SCRIPT.new()
    nexus_director.event_started.connect(_on_director_event)
    add_child(nexus_director)
    missions = MISSIONS_SCRIPT.new()
    add_child(missions)
    _make_trees()
    story = STORY_SCRIPT.new()
    add_child(story)
    world_operations = WORLD_OPS_SCRIPT.new()
    add_child(world_operations)
    living = LIVING_SCRIPT.new()
    living.incident_opened.connect(_on_living_incident)
    add_child(living)
    _make_vehicles()
    drone = DRONE_SCRIPT.new()
    drone.global_position = Vector3(5, 3.0, 5)
    add_child(drone)
    player = PLAYER_SCRIPT.new()
    player.global_position = Vector3(4, 0.4, 7)
    add_child(player)
    weather_fx = WEATHER_FX_SCRIPT.new()
    add_child(weather_fx)
    weather_fx.bind_world(player, world_clock)
    coop = COOP_SCRIPT.new()
    add_child(coop)
    coop.set_actor(player)
    _make_hud()
    living_panel = LIVING_PANEL_SCRIPT.new()
    living_panel.decision_requested.connect(_on_living_decision)
    add_child(living_panel)
    living_panel.bind_simulation(living)
    _make_starmap_button()
    _make_living_button()
    _make_fleet_menu()
    _make_build_marker()
    _make_minimap()
    _update_hud()

func surface_material(color: Color, texture_name: String = "", uv: float = 1.0, metallic: float = 0.0) -> StandardMaterial3D:
    var m = StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.88 if metallic <= 0.0 else 0.42
    m.metallic = metallic
    if texture_name != "":
        m.albedo_texture = load("res://assets/" + texture_name + ".png")
        m.uv1_scale = Vector3(uv, uv, 1.0)
        if texture_name.begins_with("nexus_pbr_"):
            m.normal_enabled = true
            m.normal_texture = load("res://assets/%s_normal.png" % texture_name)
            m.normal_scale = 0.6
    return m

func add_box(parent: Node3D, name_text: String, center: Vector3, size: Vector3, mat: Material, solid: bool = false) -> Node3D:
    var body: Node3D
    if solid:
        body = StaticBody3D.new()
        var collider = CollisionShape3D.new()
        var shape = BoxShape3D.new()
        shape.size = size
        collider.shape = shape
        body.add_child(collider)
    else:
        body = Node3D.new()
    body.name = name_text
    body.position = center
    parent.add_child(body)
    var visual = MeshInstance3D.new()
    var mesh = BoxMesh.new()
    mesh.size = size
    visual.mesh = mesh
    visual.material_override = mat
    body.add_child(visual)
    return body

func add_cylinder(parent: Node3D, pos: Vector3, bottom_radius: float, top_radius: float, height: float, mat: Material, solid: bool = false) -> Node3D:
    var node: Node3D = StaticBody3D.new() if solid else Node3D.new()
    node.position = pos
    parent.add_child(node)
    var visual = MeshInstance3D.new()
    var mesh = CylinderMesh.new()
    mesh.bottom_radius = bottom_radius
    mesh.top_radius = top_radius
    mesh.height = height
    mesh.radial_segments = 12
    visual.mesh = mesh
    visual.material_override = mat
    node.add_child(visual)
    if solid:
        var col = CollisionShape3D.new()
        var cyl = CylinderShape3D.new()
        cyl.radius = bottom_radius
        cyl.height = height
        col.shape = cyl
        node.add_child(col)
    return node

func _make_environment() -> void:
    var world_env = WorldEnvironment.new()
    var env = Environment.new()
    var s = Sky.new()
    var sky_mat = ProceduralSkyMaterial.new()
    sky_mat.sky_top_color = Color("4d7594")
    sky_mat.sky_horizon_color = Color("d8dee1")
    sky_mat.ground_bottom_color = Color("506a57")
    sky_mat.ground_horizon_color = Color("c4d0c8")
    s.sky_material = sky_mat
    env.background_mode = Environment.BG_SKY
    env.sky = s
    env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    env.reflected_light_source = Environment.REFLECTION_SOURCE_BG
    env.ssao_enabled = true
    env.ssao_radius = 2.5
    env.ssao_intensity = 1.55
    env.glow_enabled = true
    env.glow_intensity = 0.32
    env.volumetric_fog_enabled = true
    env.volumetric_fog_density = 0.008
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.fog_enabled = true
    env.fog_light_color = Color("c7d3d6")
    env.fog_density = 0.0025
    world_env.environment = env
    add_child(world_env)
    sky_light = DirectionalLight3D.new()
    sky_light.name = "Sonne"
    sky_light.rotation_degrees = Vector3(-49, -34, 0)
    sky_light.light_color = Color("fff2df")
    sky_light.light_energy = 1.35
    sky_light.shadow_enabled = true
    sky_light.directional_shadow_max_distance = 180.0
    add_child(sky_light)

func _make_land() -> void:
    ground_body = StaticBody3D.new()
    ground_body.name = "Boden"
    add_child(ground_body)
    var collision = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(460, 1, 460)
    collision.shape = shape
    collision.position.y = -0.5
    ground_body.add_child(collision)
    var plane = MeshInstance3D.new()
    var mesh = PlaneMesh.new()
    mesh.size = Vector2(460, 460)
    plane.mesh = mesh
    plane.material_override = surface_material(Color("a4b69a"), "nexus_pbr_forest", 75)
    ground_body.add_child(plane)
    # Scenic alpine mountains are now generated as continuous ridges by cinematic_landscape.gd.

func _make_roads() -> void:
    var road = surface_material(Color("8b8b85"), "nexus_pbr_wet_street", 16)
    add_box(self, "Forststrasse Ost-West", Vector3(0, 0.015, 0), Vector3(180, 0.025, 7.5), road)
    add_box(self, "Zufahrt zum Saegewerk", Vector3(-40, 0.019, -42), Vector3(7.5, 0.024, 85), road)
    add_box(self, "Zufahrt zur Stadt", Vector3(55, 0.019, 55), Vector3(7.5, 0.024, 110), road)

func _make_house(pos: Vector3, w: float, d: float, roof_color: Color, label_text: String) -> void:
    var plaster = surface_material(Color("e3d8c2"), "plaster", 1.5)
    var wood_mat = surface_material(Color("9c7751"), "wood", 2)
    var roof = surface_material(roof_color, "roof", 2)
    add_box(root_objects, label_text, pos + Vector3(0, 2.1, 0), Vector3(w, 4.2, d), plaster, true)
    add_box(root_objects, "Dach " + label_text, pos + Vector3(0, 4.45, 0), Vector3(w + 0.8, 0.55, d + 1.0), roof)
    add_box(root_objects, "Tuer", pos + Vector3(-w * 0.21, 1.13, d * 0.51), Vector3(1.1, 2.25, 0.12), wood_mat)
    for side in [-1, 1]:
        add_box(root_objects, "Fenster", pos + Vector3(side * w * 0.29, 2.7, d * 0.52), Vector3(1.0, 0.9, 0.09), surface_material(Color("719da6")))

func _make_village() -> void:
    for i in range(9):
        var col = i % 3
        var row = i / 3
        var p = Vector3(83 + col * 14, 0, -50 + int(row) * 17)
        _make_house(p, 7.0 + float(i % 2) * 1.4, 7.2, Color("a65d42"), "Alpendorf Haus " + str(i + 1))
    var stone = surface_material(Color("b9b4a7"), "rock", 3)
    add_box(root_objects, "Dorfkirche", Vector3(104, 6.5, 5), Vector3(13, 13, 11), stone, true)
    add_cylinder(root_objects, Vector3(104, 18, 5), 3.5, 0.15, 13.0, surface_material(Color("986544"), "roof", 3))
    var wall = surface_material(Color("92928e"), "rock", 3)
    for x in [-155.0, -115.0]:
        add_box(root_objects, "Burgmauer", Vector3(x, 5, -150), Vector3(10, 10, 12), wall)
    add_box(root_objects, "Burg", Vector3(-136, 7.5, -150), Vector3(45, 15, 15), wall)
    add_cylinder(root_objects, Vector3(-156, 15, -150), 5, 5, 18, wall)
    add_cylinder(root_objects, Vector3(-115, 15, -150), 5, 5, 18, wall)

func _station(title: String, kind: String, pos: Vector3, color: Color) -> void:
    var node = Node3D.new()
    node.name = title
    node.position = pos
    root_objects.add_child(node)
    var mat = surface_material(color, "metal", 2)
    add_box(node, "Basis", Vector3(0, 0.14, 0), Vector3(10, 0.28, 9), surface_material(Color("9c9588"), "rock", 2))
    add_box(node, "Halle hinten", Vector3(0, 3.3, -4.3), Vector3(10, 6.6, 0.4), mat, true)
    add_box(node, "Halle links", Vector3(-4.8, 3.3, 0), Vector3(0.4, 6.6, 9), mat, true)
    add_box(node, "Halle rechts", Vector3(4.8, 3.3, 0), Vector3(0.4, 6.6, 9), mat, true)
    add_box(node, "Hallendach", Vector3(0, 6.75, 0), Vector3(10.3, 0.35, 9.4), surface_material(Color("454c4e"), "roof", 2))
    stations.append({"name": title, "kind": kind, "node": node})

func _make_stations() -> void:
    _station("Saegwerk", "mill", Vector3(-45, 0, -28), Color("9c7e59"))
    _station("Werkstatt & Tankstelle", "garage", Vector3(17, 0, -10), Color("657c85"))
    _station("Oelfoerderung", "oil", Vector3(-96, 0, 35), Color("59616b"))
    _station("Goldmine", "mine", Vector3(-127, 0, -65), Color("867960"))
    _station("Bauernhof", "farm", Vector3(6, 0, 95), Color("81964c"))
    _station("Raffinerie", "refinery", Vector3(-99, 0, 65), Color("515b63"))
    _station("Papierfabrik", "paper", Vector3(-43, 0, -62), Color("b0a88b"))
    _station("Meteoritenforschung", "meteor", Vector3(-120, 0, 117), Color("566e80"))
    _station("Rettungsstation", "rescue", Vector3(47, 0, 32), Color("c5c8cb"))
    _station("Forschungsstation 31", "research", Vector3(117, 0, 114), Color("59646a"))
    add_cylinder(root_objects, Vector3(-97, 9, 38), 0.27, 0.27, 18.0, surface_material(Color("555b60"), "metal", 2))
    add_box(root_objects, "Oelpumpe", Vector3(-97, 13, 38), Vector3(12, 1.1, 1), surface_material(Color("454646"), "metal", 2))
    var crop_mat = surface_material(Color("679647"), "grass", 4)
    for ix in range(8):
        for iz in range(5):
            add_box(root_objects, "Saatreihe", Vector3(-18 + ix * 3, 0.22, 96 + iz * 2.5), Vector3(1.3, 0.42, 2.0), crop_mat)
    var crystal = surface_material(Color("7197bb"), "alpine_stone", 1, 0.38)
    for k in range(7):
        var xx = -137 + float(k % 4) * 3.8
        var zz = 137 + float(k / 4) * 4.0
        add_cylinder(root_objects, Vector3(xx, 1.2, zz), 1.25, 0.1, 2.4, crystal)
    for ix in range(4):
        add_cylinder(root_objects, Vector3(-111 + ix * 4, 3.0, 69), 0.44, 0.44, 5.0, surface_material(Color("9ba2a8"), "metal", 1, 0.6))

func _make_trees() -> void:
    var rng = RandomNumberGenerator.new()
    rng.seed = 72830
    for i in range(180):
        var x = rng.randf_range(-135, 135)
        var z = rng.randf_range(-135, 135)
        if abs(z) < 15.0 or abs(x - 55.0) < 10.0 or Vector2(x + 45, z + 28).length() < 17:
            continue
        if Vector2(x - 100, z + 30).length() < 55 or Vector2(x - 117, z - 114).length() < 18:
            continue
        _spawn_tree(i, Vector3(x, 0, z), rng.randf_range(6.0, 11.0))

func _spawn_tree(id: int, pos: Vector3, height: float) -> void:
    var node = Node3D.new()
    node.position = pos
    node.name = "Fichte_%03d" % id
    root_objects.add_child(node)
    var bark = surface_material(Color("8e7358"), "wood", 2)
    var green = surface_material(Color("577458"))
    add_cylinder(node, Vector3(0, height * 0.38, 0), 0.31, 0.24, height * 0.76, bark, true)
    add_cylinder(node, Vector3(0, height * 0.69, 0), height * 0.23, 0.01, height * 0.6, green)
    add_cylinder(node, Vector3(0, height * 0.95, 0), height * 0.17, 0.01, height * 0.48, green)
    trees.append({"id": id, "node": node, "h": height, "p": pos})

func _make_vehicles() -> void:
    _add_vehicle("Traktor", Vector3(9, 0.12, 13))
    _add_vehicle("LKW", Vector3(16, 0.12, 14))
    _add_vehicle("Sportwagen", Vector3(23, 0.12, 14))
    _add_vehicle("Rettung", Vector3(43, 0.12, 40))
    _add_vehicle("Panzer", Vector3(-94, 0.12, -75))
    _add_vehicle("Bagger", Vector3(-45, 0.12, 104))
    _add_vehicle("Helikopter", Vector3(51, 0.12, 63))

func _add_vehicle(category: String, pos: Vector3) -> void:
    var v: NexusVehicle = VEHICLE_SCRIPT.new()
    v.category = category
    v.position = pos
    add_child(v)
    vehicles.append(v)

func _make_fleet_menu() -> void:
    fleet_menu = FLEET_MENU_SCRIPT.new()
    fleet_menu.spawn_requested.connect(_spawn_fleet_vehicle)
    add_child(fleet_menu)
    var button = Button.new()
    button.name = "Fahrzeughalle-Oeffnen"
    button.text = "FAHRZEUGE 123  /  F6"
    button.position = Vector2(28,344)
    button.custom_minimum_size = Vector2(285,42)
    button.pressed.connect(fleet_menu.toggle)
    get_node("HUD").add_child(button)

func _spawn_fleet_vehicle(record: Dictionary) -> void:
    if fleet_spawn_count >= 22:
        _say("Maximal 22 zusaetzliche Fahrzeuge gleichzeitig. Speichere oder nutze vorhandene Fahrzeuge.")
        return
    if vehicle_in_use != null:
        _toggle_vehicle()
    if drone_active:
        _toggle_drone()
    var new_vehicle: NexusVehicle = VEHICLE_SCRIPT.new()
    new_vehicle.configure(record)
    var heading = player.global_transform.basis
    var spawn = player.global_position + heading.x * 6.5 - heading.z * 6.0
    spawn.y = 0.2
    new_vehicle.position = spawn
    add_child(new_vehicle)
    vehicles.append(new_vehicle)
    fleet_spawn_count += 1
    _say("Fahrzeug bereit: %s | %d km/h | F einsteigen" % [record.get("name", "Unbekannt"), record.get("top_kmh", 0)])

func _make_hud() -> void:
    var overlay = CanvasLayer.new()
    overlay.name = "HUD"
    overlay.layer = 2
    add_child(overlay)
    var panel = ColorRect.new()
    panel.color = Color(0.025, 0.045, 0.06, 0.77)
    panel.position = Vector2(14, 12)
    panel.size = Vector2(610, 174)
    overlay.add_child(panel)
    hud = Label.new()
    hud.position = Vector2(27, 22)
    hud.add_theme_font_size_override("font_size", 18)
    overlay.add_child(hud)
    help = Label.new()
    help.position = Vector2(26, 200)
    help.add_theme_font_size_override("font_size", 15)
    overlay.add_child(help)
    var crosshair = Label.new()
    crosshair.text = "+"
    crosshair.set_anchors_preset(Control.PRESET_CENTER)
    crosshair.add_theme_font_size_override("font_size", 21)
    overlay.add_child(crosshair)

func _make_starmap_button() -> void:
    var button = Button.new()
    button.name = "Sternenkarte-Oeffnen"
    button.text = "🚀 STERNENSYSTEM / PLANETEN"
    button.position = Vector2(28, 291)
    button.custom_minimum_size = Vector2(285, 45)
    button.pressed.connect(_open_star_system)
    get_node("HUD").add_child(button)

func _make_living_button() -> void:
    var button := Button.new()
    button.name = "Einsatzleitung"
    button.text = "EINSATZLEITUNG / WELTLAGE (F8)"
    button.position = Vector2(28, 343)
    button.custom_minimum_size = Vector2(285, 45)
    button.pressed.connect(living_panel.toggle)
    get_node("HUD").add_child(button)

func _open_star_system() -> void:
    if vehicle_in_use != null:
        _toggle_vehicle()
    if drone_active:
        _toggle_drone()
    save_state()
    get_tree().change_scene_to_file("res://scenes/starmap.tscn")

func _make_minimap() -> void:
    minimap = MAP_SCRIPT.new()
    minimap.name = "Interaktive Minikarte"
    get_node("HUD").add_child(minimap)
    minimap.set_anchors_preset(Control.PRESET_TOP_RIGHT)
    minimap.position = Vector2(-268, 18)
    minimap.player = player
    minimap.drone = drone
    minimap.vehicles = vehicles
    minimap.stations = stations

func _make_build_marker() -> void:
    marker = MeshInstance3D.new()
    var mesh = BoxMesh.new()
    mesh.size = build_sizes[0]
    marker.mesh = mesh
    var m = StandardMaterial3D.new()
    m.albedo_color = Color(0.16, 0.9, 0.46, 0.38)
    m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    marker.material_override = m
    marker.visible = false
    add_child(marker)

func _process(delta: float) -> void:
    nexus_director.advance(delta, wood, iron)
    living.advance(delta)
    resource_cooldown = max(0.0, resource_cooldown - delta)
    if drone_active and not drone.controlled:
        drone_active = false
        player.set_driving(false)
        _say("Drohne gelandet – Steuerung zurueckgegeben")
    notice_time = max(0.0, notice_time - delta)
    if tow_log != null and is_instance_valid(tow_log) and vehicle_in_use != null:
        tow_log.global_position = vehicle_in_use.global_position + vehicle_in_use.global_transform.basis.z * 5 + Vector3(0, 0.7, 0)
    _update_hud()

func _on_director_event(description: String) -> void:
    story.trigger_alert(description)
    _say("NEXUS DIRECTOR: " + description)

func _on_living_incident(title: String) -> void:
    living_panel.refresh()
    _say("WELTALARM: " + title + " | Einsatzleitung mit F8")

func _on_living_decision(option: int) -> void:
    var result: Dictionary = living.resolve(option, coins)
    if bool(result.get("ok", false)):
        coins += int(result.get("money", 0))
        completed_jobs += 1
        story.trigger_alert(str(result.get("message", "Weltereignis abgeschlossen")))
    living_panel.show_feedback(result)
    _say(str(result.get("message", "Entscheidung nicht moeglich")))

func _physics_process(_delta: float) -> void:
    if mode_build:
        _update_build_marker()

func _update_hud() -> void:
    if hud == null:
        return
    var status = "ZU FUSS" if vehicle_in_use == null else "%s | %d km/h | Diesel %d%%" % [vehicle_in_use.category, roundi(abs(vehicle_in_use.speed) * 3.6), roundi(vehicle_in_use.fuel)]
    if drone_active:
        status = "FPV-DROHNE | Akku %d%% | %s" % [roundi(drone.battery), drone.state_notice]
    hud.text = "PROJECT NEXUS | LIVING UNIVERSE V1.4\n%s | Geld: %d EUR | %s\nHolz %d  Eisen %d  Oel %d  Gold %d  Ernte %d\nTreibstoff %d  Papier %d  Meteorit %d | Forschung %d\nBaumstaemme: %d | Auftraege: %d" % [status, coins, world_clock.describe(), wood, iron, oil, gold, crops, refined_fuel, paper, meteor, tech_level, sold_logs, completed_jobs]
    var tip = "WASD bewegen/fahren | F Fahrzeug | V FPV-Drohne | E arbeiten | N Karte | Y Zeit | F5/F9 speichern/laden | G Sternensystem | F6 Fahrzeughalle | F7 LAN-Koop (Preview) | ESC Maus"
    if nexus_director.active_event != "":
        tip += "\nWELTEREIGNIS: " + nexus_director.active_event
    if drone_active:
        tip += "\nDRONE: WASD fliegen | Leertaste steigen | Shift sinken | V aussteigen"
    elif vehicle_in_use != null:
        tip += "\nQ: Baumstamm mit dem Traktor ziehen / abhaengen"
    else:
        tip += "\nB: Baumodus | Linksklick: Bauteil setzen | Q: Bauteil wechseln | R: drehen"
    if mode_build:
        tip += "\nBAUMODUS: %s (20 EUR, 2 Holz + 1 Eisen) – %s" % [build_names[build_kind], "FREI" if build_valid else "BLOCKIERT"]
    if notice_time > 0.0:
        tip += "\n" + notice
    if missions != null:
        tip += "\nMISSION: " + missions.objective
    if world_operations != null:
        tip += "\nNEXUS OPS: " + world_operations.objective()
    if mode_build:
        tip += " | Raster: %.2f m | Hoehe: %.1f m (G / Bild auf / Bild ab)" % [build_grid, build_height]
    if story != null:
        hud.text += "\nSTORY: %s | %d m | Ruf %d" % [story.current_objective(), story.target_distance(player.global_position), story.reputation]
    if living != null:
        tip += "\n" + living.get_summary() + " | F8 Einsatzleitung | F4 Grafik"
    help.text = tip

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if fleet_menu != null and fleet_menu.visible:
            if event.keycode == KEY_F6 or event.keycode == KEY_ESCAPE:
                fleet_menu.toggle()
            return
        if event.keycode == KEY_V:
            _toggle_drone()
            return
        if drone_active and event.keycode != KEY_ESCAPE:
            return
        if event.keycode == KEY_ESCAPE:
            Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
        elif event.keycode == KEY_F:
            _toggle_vehicle()
        elif event.keycode == KEY_F6 and fleet_menu != null:
            fleet_menu.toggle()
        elif event.keycode == KEY_F4 and visual_polish != null:
            visual_polish.set_graphics_quality(not visual_polish.quality_high)
            weather_fx.set_graphics_quality(visual_polish.quality_high)
            _say("Grafikprofil: %s" % ("CINEMATIC" if visual_polish.quality_high else "PERFORMANCE"))
        elif event.keycode == KEY_E:
            _interact()
        elif event.keycode == KEY_C:
            if vehicle_in_use != null:
                vehicle_in_use.switch_view()
            else:
                player.switch_view()
        elif event.keycode == KEY_B and vehicle_in_use == null:
            mode_build = not mode_build
            marker.visible = mode_build
        elif event.keycode == KEY_Q:
            if vehicle_in_use != null:
                _toggle_tow()
            elif mode_build:
                build_kind = (build_kind + 1) % build_names.size()
        elif event.keycode == KEY_R and mode_build:
            build_rotation = fposmod(build_rotation + PI / 12.0, TAU)
        elif event.keycode == KEY_G and not mode_build:
            _open_star_system()
        elif event.keycode == KEY_G and mode_build:
            build_grid = 0.5 if build_grid == 2.0 else (1.0 if build_grid == 0.5 else 2.0)
        elif event.keycode == KEY_PAGEUP and mode_build:
            build_height += 0.5
        elif event.keycode == KEY_PAGEDOWN and mode_build:
            build_height = maxf(0.0, build_height - 0.5)
        elif event.keycode == KEY_N:
            minimap.visible = not minimap.visible
        elif event.keycode == KEY_Y:
            world_clock.skip_hours(2.0)
        elif event.keycode == KEY_1 and story != null:
            _say(story.decide(1))
        elif event.keycode == KEY_2 and story != null:
            _say(story.decide(2))
        elif event.keycode == KEY_M:
            _say("Auftraege: Wanderer (74,72), Labor (117,109), Front (-101,-111), Baustelle (-59,87)")
        elif event.keycode == KEY_F5:
            save_state()
        elif event.keycode == KEY_F9:
            load_state()
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and mode_build:
        _build()

func _toggle_drone() -> void:
    if drone_active:
        drone_active = false
        drone.set_control(false)
        player.set_driving(false)
        _say("FPV-Drohne verlassen")
        return
    if vehicle_in_use != null:
        _say("Steige zuerst aus dem Fahrzeug")
        return
    if mode_build:
        mode_build = false
        marker.visible = false
    if drone.battery <= 0.0:
        drone.battery = 100.0
    drone_active = true
    player.set_driving(true)
    drone.set_control(true)
    _say("FPV-Drohne gestartet")

func _toggle_vehicle() -> void:
    if vehicle_in_use != null:
        var old = vehicle_in_use
        old.set_control(false)
        vehicle_in_use = null
        player.set_driving(false)
        player.global_position = old.global_position + old.global_transform.basis.x * 3.1 + Vector3(0, 0.2, 0)
        _say("Fahrzeug verlassen")
        return
    var nearest = null
    var dist = 5.0
    for v in vehicles:
        var d = player.global_position.distance_to(v.global_position)
        if d < dist:
            dist = d
            nearest = v
    if nearest != null:
        vehicle_in_use = nearest
        player.set_driving(true)
        nearest.set_control(true)
        _say("%s gestartet" % nearest.category)
    else:
        _say("Kein Fahrzeug in Reichweite")

func _interact() -> void:
    if vehicle_in_use != null:
        if _nearest_station_kind("garage", vehicle_in_use.global_position, 12.0) != null:
            if refined_fuel >= 1:
                refined_fuel -= 1
                vehicle_in_use.fuel = 100.0
                vehicle_in_use.condition = 100.0
                _say("Mit eigenem Treibstoff getankt und repariert")
            elif coins >= 50:
                coins -= 50
                vehicle_in_use.fuel = 100.0
                vehicle_in_use.condition = 100.0
                _say("Fahrzeug fuer 50 EUR getankt und repariert")
            else:
                _say("Kein Treibstoff und zu wenig Geld")
        elif _nearest_station_kind("mill", vehicle_in_use.global_position, 12.0) != null:
            _sell_logs()
        else:
            _say("Steige aus, um zu arbeiten, oder fahre zur Werkstatt / zum Saegewerk")
        return
    if story != null:
        var story_outcome: Dictionary = story.interact(player.global_position)
        if bool(story_outcome.get("handled", false)):
            coins += int(story_outcome.get("money", 0))
            if int(story_outcome.get("money", 0)) > 0:
                completed_jobs += 1
            _say(str(story_outcome.get("message", "Story aktualisiert")))
            return
    if world_operations != null:
        var op: Dictionary = world_operations.try_interact(player.global_position)
        if bool(op.get("handled", false)):
            coins += int(op.get("money",0))
            completed_jobs += 1
            story.trigger_alert(str(op.get("message", "Einsatz erledigt")))
            _say(str(op.get("message", "Einsatz erledigt")))
            return
    if missions != null:
        var outcome: Dictionary = missions.interact_at(player.global_position, wood, iron)
        if bool(outcome.get("handled", false)):
            coins += int(outcome.get("money", 0))
            wood += int(outcome.get("wood", 0))
            iron += int(outcome.get("iron", 0))
            if int(outcome.get("money", 0)) > 0:
                completed_jobs += 1
            _say(str(outcome.get("message", "Mission aktualisiert")))
            return
    if _nearest_station_kind("farm", player.global_position, 11.0) != null:
        if resource_cooldown <= 0.0:
            crops += 3
            resource_cooldown = 4.0
            _say("Feld geerntet: +3 Erntegut")
        else:
            _say("Feld braucht Zeit zum Nachwachsen")
        return
    if _nearest_station_kind("refinery", player.global_position, 11.0) != null:
        if oil >= 3:
            oil -= 3
            refined_fuel += 2
            _say("3 Rohoel zu 2 Treibstoffkanistern verarbeitet")
        else:
            _say("Raffinerie benoetigt 3 Rohoel")
        return
    if _nearest_station_kind("paper", player.global_position, 11.0) != null:
        if wood >= 4:
            wood -= 4
            paper += 3
            coins += 60
            completed_jobs += 1
            _say("Papierfabrik: 4 Holz zu 3 Papier, +60 EUR")
        else:
            _say("Papierfabrik benoetigt 4 Holz")
        return
    if _nearest_station_kind("meteor", player.global_position, 11.0) != null:
        if meteor < 3 and resource_cooldown <= 0.0:
            meteor += 1
            resource_cooldown = 3.0
            _say("Meteoritenmaterial geborgen: +1")
        elif meteor >= 2 and gold >= 1:
            meteor -= 2
            gold -= 1
            tech_level += 1
            _say("Forschung abgeschlossen: Technologiestufe +1")
        else:
            _say("Forschung braucht 2 Meteoriten und 1 Gold")
        return
    if _nearest_station_kind("mill", player.global_position, 11.0) != null:
        _sell_logs()
        return
    if _nearest_station_kind("oil", player.global_position, 11.0) != null:
        if resource_cooldown <= 0:
            oil += 2
            resource_cooldown = 1.0
            _say("2 Einheiten Rohoel gefoerdert")
        return
    if _nearest_station_kind("mine", player.global_position, 11.0) != null:
        if resource_cooldown <= 0:
            gold += 1
            iron += 1
            resource_cooldown = 1.0
            _say("Gold und Eisenerz abgebaut")
        return
    if _nearest_station_kind("garage", player.global_position, 11.0) != null:
        _say("Werkstatt: Fahrzeug heranfahren, einsteigen und E druecken")
        return
    for i in range(logs.size() - 1, -1, -1):
        var log_info = logs[i]
        if is_instance_valid(log_info["node"]) and player.global_position.distance_to(log_info["node"].global_position) < 3.5 and log_info["node"] != tow_log:
            wood += 2
            log_info["node"].queue_free()
            logs.remove_at(i)
            _say("Baumstamm verarbeitet: +2 Holz")
            return
    var nearest_index = -1
    var nearest_dist = 3.7
    for i in range(trees.size()):
        var obj = trees[i]
        if is_instance_valid(obj["node"]):
            var d = player.global_position.distance_to(obj["node"].global_position)
            if d < nearest_dist:
                nearest_dist = d
                nearest_index = i
    if nearest_index >= 0:
        var tree = trees[nearest_index]
        chopped_ids.append(tree["id"])
        _spawn_log(tree["p"] + Vector3(0, 0.65, 0))
        tree["node"].queue_free()
        trees.remove_at(nearest_index)
        _say("Baum gefaellt. Stamm mit Q am Traktor ziehen oder E aufsammeln.")
    else:
        _say("Gehe an einen Baum oder eine Arbeitsstation heran")

func _nearest_station_kind(kind: String, pos: Vector3, radius: float):
    for station in stations:
        if station["kind"] == kind and pos.distance_to(station["node"].global_position) <= radius:
            return station
    return null

func _spawn_log(pos: Vector3) -> void:
    var obj = Node3D.new()
    obj.position = pos
    obj.name = "Baumstamm"
    root_objects.add_child(obj)
    var visual = MeshInstance3D.new()
    var mesh = CylinderMesh.new()
    mesh.top_radius = 0.42
    mesh.bottom_radius = 0.42
    mesh.height = 5.5
    mesh.radial_segments = 14
    visual.mesh = mesh
    visual.rotation.x = PI / 2
    visual.material_override = surface_material(Color("b49a70"), "wood", 3)
    obj.add_child(visual)
    logs.append({"node": obj})

func _toggle_tow() -> void:
    if tow_log != null:
        _say("Seilwinde geloest")
        tow_log = null
        return
    if vehicle_in_use == null or (vehicle_in_use.category != "Traktor" and vehicle_in_use.category != "LKW"):
        _say("Seilwinde nur bei Traktor und LKW")
        return
    for log_info in logs:
        if is_instance_valid(log_info["node"]) and vehicle_in_use.global_position.distance_to(log_info["node"].global_position) < 11.0:
            tow_log = log_info["node"]
            _say("Baumstamm an Seilwinde befestigt")
            return
    _say("Kein Baumstamm in 11 m Umkreis")

func _sell_logs() -> void:
    var count = 0
    for i in range(logs.size() - 1, -1, -1):
        var obj = logs[i]["node"]
        if is_instance_valid(obj) and obj.global_position.distance_to(Vector3(-45, 0, -28)) < 17.0:
            if obj == tow_log:
                tow_log = null
            obj.queue_free()
            logs.remove_at(i)
            count += 1
    if count > 0:
        coins += count * 135
        wood += count * 4
        sold_logs += count
        _say("%d Staemme verkauft: +%d € und +%d Bretter" % [count, count * 135, count * 4])
    else:
        _say("Keine Baumstaemme an der Holzannahme")

func _get_build_position() -> Vector3:
    var cam = player.camera
    var from_pos = cam.global_position
    var end_pos = from_pos - cam.global_transform.basis.z * 12.0
    var query = PhysicsRayQueryParameters3D.create(from_pos, end_pos)
    query.exclude = [player.get_rid()]
    var hit = get_world_3d().direct_space_state.intersect_ray(query)
    var point = Vector3(hit["position"].x, 0.0, hit["position"].z) if not hit.is_empty() else (player.global_position - player.global_transform.basis.z * 7.0)
    return Vector3(roundf(point.x / build_grid) * build_grid, build_height, roundf(point.z / build_grid) * build_grid)

func _can_build(pos: Vector3, kind: int, rot: float) -> bool:
    if absf(pos.x) > 215.0 or absf(pos.z) > 215.0:
        return false
    if coins < 20 or wood < 2 or iron < 1:
        return false
    var size: Vector3 = build_sizes[kind]
    var check_shape = BoxShape3D.new()
    check_shape.size = Vector3(size.x * 0.96, size.y * 0.92, size.z * 0.96)
    var params = PhysicsShapeQueryParameters3D.new()
    params.shape = check_shape
    params.transform = Transform3D(Basis(Vector3.UP, rot), pos + Vector3(0, size.y / 2.0, 0))
    params.exclude = [player.get_rid()]
    var hits = get_world_3d().direct_space_state.intersect_shape(params, 8)
    for h in hits:
        if h.get("collider") != ground_body:
            return false
    # Also reject a new build directly on top of an existing saved component.
    for construction in constructions:
        var p: Vector3 = construction["p"]
        if pos.distance_to(p) < 0.4:
            return false
    return true

func _update_build_marker() -> void:
    marker.position = _get_build_position() + Vector3(0, build_sizes[build_kind].y / 2.0, 0)
    marker.rotation.y = build_rotation
    build_valid = _can_build(_get_build_position(), build_kind, build_rotation)
    var ghost_mat = marker.material_override as StandardMaterial3D
    ghost_mat.albedo_color = Color(0.14, 0.9, 0.5, 0.35) if build_valid else Color(0.96, 0.18, 0.12, 0.5)
    var mesh = BoxMesh.new()
    mesh.size = build_sizes[build_kind]
    marker.mesh = mesh

func _build() -> void:
    if coins < 20 or wood < 2 or iron < 1:
        _say("Bauen benoetigt 20 €, 2 Holz und 1 Eisen")
        return
    var pos = _get_build_position()
    var size = build_sizes[build_kind]
    if not _can_build(pos, build_kind, build_rotation):
        _say("Bauplatz ist blockiert. Drehe, verschiebe oder erhoehe das Bauteil.")
        return
    coins -= 20
    wood -= 2
    iron -= 1
    _spawn_build(build_kind, pos, build_rotation)
    _say("%s gebaut" % build_names[build_kind])

func _spawn_build(kind: int, pos: Vector3, rotation_y: float) -> void:
    var size = build_sizes[kind]
    var mats = [surface_material(Color("b8b5ac"), "rock", 2), surface_material(Color("d9bea0"), "wood", 2), surface_material(Color("a15d4a"), "roof", 2), surface_material(Color("788991"), "metal", 2, 0.6), surface_material(Color("9a7958"), "wood", 2), surface_material(Color("a5a6a2"), "metal", 1, 0.5), surface_material(Color("6a9faf")), surface_material(Color("757b80"), "road", 1.5), surface_material(Color("b9b8b2"), "city_concrete", 1.5), surface_material(Color("a4a5a2"), "metal", 1.0)]
    var body = add_box(root_objects, build_names[kind], pos + Vector3(0, size.y / 2, 0), size, mats[kind], true)
    body.rotation.y = rotation_y
    constructions.append({"node": body, "kind": kind, "p": pos, "r": rotation_y})

func save_state() -> void:
    var v_data = []
    for v in vehicles:
        v_data.append({"pos": [v.global_position.x, v.global_position.y, v.global_position.z], "fuel": v.fuel, "condition": v.condition, "catalog_id": str(v.definition.get("id", "")), "rotation": v.rotation.y})
    var b_data = []
    for built in constructions:
        var p = built["p"]
        b_data.append({"kind": built["kind"], "pos": [p.x, p.y, p.z], "rot": built["r"]})
    var l_data = []
    for info in logs:
        if is_instance_valid(info["node"]):
            var p = info["node"].global_position
            l_data.append([p.x, p.y, p.z])
    var p = player.global_position if vehicle_in_use == null else vehicle_in_use.global_position
    var data = {"money": coins, "wood": wood, "iron": iron, "oil": oil, "gold": gold, "sold": sold_logs, "position": [p.x, p.y, p.z], "vehicles": v_data, "world_ops": world_operations.get_data(), "living_universe": living.get_data(), "buildings": b_data, "chopped": chopped_ids, "logs": l_data, "mission": missions.get_data() if missions != null else {}, "build_grid": build_grid, "build_height": build_height, "crops": crops, "paper": paper, "refined_fuel": refined_fuel, "meteor": meteor, "tech_level": tech_level, "completed_jobs": completed_jobs, "world_clock": world_clock.get_data(), "director": nexus_director.get_data(), "story": story.get_data()}
    var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f == null:
        _say("Fehler beim Speichern")
        return
    f.store_string(JSON.stringify(data, "  "))
    _say("Welt gespeichert")

func load_state() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        _say("Noch kein Spielstand gespeichert")
        return
    var raw = FileAccess.get_file_as_string(SAVE_PATH)
    var parsed = JSON.parse_string(raw)
    if typeof(parsed) != TYPE_DICTIONARY:
        _say("Spielstand konnte nicht gelesen werden")
        return
    if vehicle_in_use != null:
        _toggle_vehicle()
    coins = int(parsed.get("money", 3000))
    wood = int(parsed.get("wood", 12))
    iron = int(parsed.get("iron", 10))
    oil = int(parsed.get("oil", 0))
    gold = int(parsed.get("gold", 0))
    sold_logs = int(parsed.get("sold", 0))
    crops = int(parsed.get("crops", 0))
    paper = int(parsed.get("paper", 0))
    refined_fuel = int(parsed.get("refined_fuel", 0))
    meteor = int(parsed.get("meteor", 0))
    tech_level = int(parsed.get("tech_level", 0))
    completed_jobs = int(parsed.get("completed_jobs", 0))
    world_clock.restore_data(parsed.get("world_clock", {}))
    nexus_director.restore_data(parsed.get("director", {}))
    story.restore_data(parsed.get("story", {}))
    world_operations.restore_data(parsed.get("world_ops", {}))
    living.restore_data(parsed.get("living_universe", {}))
    living_panel.refresh()
    build_grid = float(parsed.get("build_grid", 1.0))
    build_height = float(parsed.get("build_height", 0.0))
    if missions != null:
        missions.restore_data(parsed.get("mission", {}))
    for b in constructions:
        if is_instance_valid(b["node"]):
            b["node"].queue_free()
    constructions.clear()
    for l in logs:
        if is_instance_valid(l["node"]):
            l["node"].queue_free()
    logs.clear()
    tow_log = null
    for t in trees:
        if is_instance_valid(t["node"]):
            t["node"].queue_free()
    trees.clear()
    chopped_ids.clear()
    _make_trees()
    for raw_id in parsed.get("chopped", []):
        var id = int(raw_id)
        for i in range(trees.size() - 1, -1, -1):
            if trees[i]["id"] == id:
                trees[i]["node"].queue_free()
                trees.remove_at(i)
                break
        chopped_ids.append(id)
    for record in parsed.get("buildings", []):
        var pp = record.get("pos", [0, 0, 0])
        _spawn_build(clampi(int(record.get("kind", 0)), 0, build_names.size() - 1), Vector3(float(pp[0]), float(pp[1]), float(pp[2])), float(record.get("rot", 0)))
    for pp in parsed.get("logs", []):
        _spawn_log(Vector3(float(pp[0]), float(pp[1]), float(pp[2])))
    var vehicle_records = parsed.get("vehicles", [])
    for j in range(vehicles.size() - 1, 6, -1):
        vehicles[j].queue_free()
        vehicles.remove_at(j)
    fleet_spawn_count = 0
    for i in range(7, mini(vehicle_records.size(), 29)):
        var catalog_id = str(vehicle_records[i].get("catalog_id", ""))
        var definition = CATALOG_SCRIPT.by_id(catalog_id)
        if not definition.is_empty():
            var new_vehicle: NexusVehicle = VEHICLE_SCRIPT.new()
            new_vehicle.configure(definition)
            add_child(new_vehicle)
            vehicles.append(new_vehicle)
            fleet_spawn_count += 1
    for i in range(mini(vehicle_records.size(), vehicles.size())):
        var record = vehicle_records[i]
        var pp = record.get("pos", [0, 0, 0])
        vehicles[i].global_position = Vector3(float(pp[0]), float(pp[1]), float(pp[2]))
        vehicles[i].fuel = float(record.get("fuel", 100))
        vehicles[i].condition = float(record.get("condition", 100))
        vehicles[i].rotation.y = float(record.get("rotation", vehicles[i].rotation.y))
    var place = parsed.get("position", [4, 0.4, 7])
    player.global_position = Vector3(float(place[0]), float(place[1]), float(place[2]))
    _say("Welt erfolgreich geladen")

func _say(msg: String) -> void:
    notice = msg
    notice_time = 4.0
