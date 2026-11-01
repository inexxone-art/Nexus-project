extends Node3D
## Six traversable prototype biomes, mission objectives, enemies and campaign memory.
## Procedural primitives are placeholders for licensed photorealistic AAA assets.
const CAMPAIGN = preload("res://scripts/nexus_campaign.gd")
const PLAYER_SCRIPT = preload("res://scripts/player.gd")
const LORE = preload("res://scripts/nexus_lore.gd")

var campaign: Dictionary
var planet: Dictionary
var pid: String
var biome: String
var noise: FastNoiseLite
var detail_noise: FastNoiseLite
var player: NexusPlayer
var enemies: Array[Dictionary] = []
var objective_marker: Node3D
var objective_label: Label3D
var hud: Label
var message_label: Label
var mission_stage: int = 0
var final_choice: int = 0
var kills: int = 0
var ammo: int = 48
var hp: float = 100.0
var time_elapsed: float = 0.0
var last_event: int = 0
var weapon_cooldown: float = 0.0
var enemy_attack_cooldown: float = 1.0
var message_time: float = 0.0
var ambush_spawned: bool = false
var rng = RandomNumberGenerator.new()
const SCAN_POINT = Vector2(-70, -50)
const CORE_POINT = Vector2(77, -66)
const EXIT_POINT = Vector2(0, 40)

func _ready() -> void:
    campaign = CAMPAIGN.load_data()
    pid = str(campaign.get("planet", "terra"))
    planet = CAMPAIGN.get_planet(pid)
    biome = str(planet["biome"])
    rng.seed = int(planet["seed"])
    noise = FastNoiseLite.new()
    noise.seed = int(planet["seed"])
    noise.frequency = 0.016
    noise.fractal_type = FastNoiseLite.FRACTAL_FBM
    noise.fractal_octaves = 4
    detail_noise = FastNoiseLite.new()
    detail_noise.seed = int(planet["seed"]) + 97
    detail_noise.frequency = 0.065
    _make_atmosphere()
    _make_terrain()
    _make_distant_landmarks()
    _make_vegetation()
    _make_ruins()
    _make_objective()
    _make_shuttle()
    _make_player()
    _restore_visit()
    _make_hud()
    _refresh_objective()
    _notice("%s // %s" % [planet["name"],LORE.info(pid)["arrival"]])

func _biome_color() -> Color:
    match biome:
        "desert": return Color("b9a07d")
        "ice": return Color("d0e1e9")
        "jungle": return Color("426e51")
        "volcanic": return Color("49464c")
        "alien": return Color("77739a")
        _: return Color("71916c")

func _mat(color: Color, texture_name: String = "", metal: float = 0.0, glowing: bool = false) -> StandardMaterial3D:
    var m = StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.83 if metal == 0.0 else 0.36
    m.metallic = metal
    if texture_name != "":
        m.albedo_texture = load("res://assets/%s.png" % texture_name)
        m.uv1_scale = Vector3(18,18,1)
        if texture_name.begins_with("nexus_pbr_"):
            m.normal_enabled = true
            m.normal_texture = load("res://assets/%s_normal.png" % texture_name)
            m.normal_scale = 0.55
    if glowing:
        m.emission_enabled = true
        m.emission = color
        m.emission_energy_multiplier = 1.9
    return m

func _make_atmosphere() -> void:
    var env_node = WorldEnvironment.new()
    var env = Environment.new()
    var sky = Sky.new()
    var procedural = ProceduralSkyMaterial.new()
    match biome:
        "desert":
            procedural.sky_top_color = Color("796f70")
            procedural.sky_horizon_color = Color("f0b88b")
        "ice":
            procedural.sky_top_color = Color("365879")
            procedural.sky_horizon_color = Color("a7c5cf")
        "jungle":
            procedural.sky_top_color = Color("174448")
            procedural.sky_horizon_color = Color("789e8d")
        "volcanic":
            procedural.sky_top_color = Color("281b27")
            procedural.sky_horizon_color = Color("ba5840")
        "alien":
            procedural.sky_top_color = Color("241a4b")
            procedural.sky_horizon_color = Color("8770ae")
        _:
            procedural.sky_top_color = Color("477ba9")
            procedural.sky_horizon_color = Color("c4d4d6")
    procedural.ground_bottom_color = _biome_color().darkened(0.65)
    procedural.ground_horizon_color = _biome_color()
    sky.sky_material = procedural
    env.sky = sky
    env.background_mode = Environment.BG_SKY
    env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    env.reflected_light_source = Environment.REFLECTION_SOURCE_BG
    env.ambient_light_energy = 0.62
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    env.ssao_enabled = true
    env.ssao_radius = 2.1
    env.ssao_intensity = 1.25
    env.glow_enabled = true
    env.glow_intensity = 0.28
    env.fog_enabled = true
    env.fog_light_color = procedural.sky_horizon_color
    env.fog_density = 0.007 if biome in ["ice", "desert", "volcanic"] else 0.0035
    env.volumetric_fog_enabled = true
    env.volumetric_fog_density = 0.013 if biome == "jungle" else 0.006
    env_node.environment = env
    add_child(env_node)
    var sunlight = DirectionalLight3D.new()
    sunlight.name = "Lokale Sonne"
    sunlight.rotation_degrees = Vector3(-42,-25,0)
    sunlight.light_color = Color("ffb88a") if biome in ["desert","volcanic"] else Color("e7f0ff")
    sunlight.light_energy = 1.45
    sunlight.shadow_enabled = true
    sunlight.directional_shadow_max_distance = 145.0
    add_child(sunlight)

func height_at(x: float, z: float) -> float:
    var h = noise.get_noise_2d(x,z) * 12.5 + detail_noise.get_noise_2d(x,z) * 2.3
    var xz = Vector2(x,z)
    for landing in [Vector2(0,0), SCAN_POINT, CORE_POINT, EXIT_POINT]:
        var distance = xz.distance_to(landing)
        var weight = smoothstep(6.0, 21.0, distance)
        h *= weight
    return h

func _make_terrain() -> void:
    var st = SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    var segments: int = 88
    var extent: float = 170.0
    for z in range(segments):
        for x in range(segments):
            var x0 = -extent + float(x) * 2.0 * extent / segments
            var x1 = -extent + float(x + 1) * 2.0 * extent / segments
            var z0 = -extent + float(z) * 2.0 * extent / segments
            var z1 = -extent + float(z + 1) * 2.0 * extent / segments
            _triangle(st, Vector3(x0,height_at(x0,z0),z0),Vector3(x0,height_at(x0,z1),z1),Vector3(x1,height_at(x1,z0),z0))
            _triangle(st, Vector3(x1,height_at(x1,z0),z0),Vector3(x0,height_at(x0,z1),z1),Vector3(x1,height_at(x1,z1),z1))
    st.generate_normals()
    var mesh = st.commit()
    var ground = StaticBody3D.new()
    ground.name = "Planetenterrain - Kollision"
    add_child(ground)
    var shape = CollisionShape3D.new()
    shape.shape = mesh.create_trimesh_shape()
    ground.add_child(shape)
    var visual = MeshInstance3D.new()
    visual.mesh = mesh
    var texture = "nexus_pbr_alpine"
    match biome:
        "desert": texture = "nexus_pbr_sand"
        "ice": texture = "nexus_pbr_ice"
        "jungle": texture = "nexus_pbr_forest"
        "volcanic": texture = "nexus_pbr_lava"
        "alien": texture = "nexus_pbr_umbra"
    visual.material_override = _mat(_biome_color(), texture)
    ground.add_child(visual)
    if biome in ["alpine", "ice"]:
        var water = MeshInstance3D.new()
        var plane = PlaneMesh.new()
        plane.size = Vector2(335,335)
        water.mesh = plane
        water.position.y = -5.0
        var wm = _mat(Color("3e7586"))
        wm.roughness = 0.13
        wm.metallic = 0.2
        water.material_override = wm
        add_child(water)

func _triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
    for v in [a,b,c]:
        st.set_uv(Vector2(v.x / 10.0,v.z / 10.0))
        st.add_vertex(v)

func _box(parent: Node3D, label: String, pos: Vector3, size: Vector3, color: Color, texture: String = "", metal: float = 0.0) -> MeshInstance3D:
    var instance = MeshInstance3D.new()
    instance.name = label
    var mesh = BoxMesh.new()
    mesh.size = size
    instance.mesh = mesh
    instance.position = pos
    instance.material_override = _mat(color,texture,metal)
    parent.add_child(instance)
    return instance

func _cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color) -> MeshInstance3D:
    var item = MeshInstance3D.new()
    var shape = CylinderMesh.new()
    shape.bottom_radius = radius
    shape.top_radius = radius * 0.9
    shape.height = height
    shape.radial_segments = 10
    item.mesh = shape
    item.position = pos
    item.material_override = _mat(color)
    parent.add_child(item)
    return item

func _make_distant_landmarks() -> void:
    var mountains = Node3D.new()
    mountains.name = "Skyline - Berge und Felsruecken"
    add_child(mountains)
    var rock_material = _mat(_biome_color().darkened(0.25), "rock")
    for i in range(36):
        var angle = float(i) / 36.0 * TAU
        var dist = rng.randf_range(197,248)
        var origin = Vector3(cos(angle)*dist,-9,sin(angle)*dist)
        var cliff = MeshInstance3D.new()
        var mesh = CylinderMesh.new()
        mesh.bottom_radius = rng.randf_range(22,36)
        mesh.top_radius = 0.0
        mesh.height = rng.randf_range(45,100)
        mesh.radial_segments = 7
        cliff.mesh = mesh
        cliff.material_override = rock_material
        cliff.position = origin + Vector3(0,mesh.height*0.34,0)
        cliff.rotation.y = rng.randf_range(0,TAU)
        mountains.add_child(cliff)
    if biome == "alien":
        for i in range(2):
            var moon = MeshInstance3D.new()
            var sphere = SphereMesh.new()
            sphere.radius = 30.0 + 17.0 * i
            sphere.height = sphere.radius * 2
            moon.mesh = sphere
            moon.position = Vector3(-150 + i*230, 195 + i*65, -315)
            moon.material_override = _mat(Color("b1a9da") if i == 0 else Color("d69ea8"))
            add_child(moon)

func _make_vegetation() -> void:
    var count: int = 220 if biome in ["alpine","jungle"] else 125
    var bushes = MultiMesh.new()
    bushes.transform_format = MultiMesh.TRANSFORM_3D
    var bushmesh = SphereMesh.new()
    bushmesh.radius = 1.0
    bushmesh.height = 2.0
    bushmesh.radial_segments = 6
    bushmesh.rings = 4
    bushes.mesh = bushmesh
    bushes.instance_count = count
    for i in range(count):
        var x = rng.randf_range(-155,155)
        var z = rng.randf_range(-155,155)
        if Vector2(x,z).length() < 24 or Vector2(x,z).distance_to(SCAN_POINT) < 17 or Vector2(x,z).distance_to(CORE_POINT) < 19:
            x += 28
            z += 16
        var y = height_at(x,z)
        var scale = rng.randf_range(1.6,5.6)
        var basis = Basis.IDENTITY.scaled(Vector3(scale*0.55,scale,scale*0.55))
        bushes.set_instance_transform(i,Transform3D(basis,Vector3(x,y+scale*0.78,z)))
    var vegetation = MultiMeshInstance3D.new()
    vegetation.name = "Vegetation - instanziert"
    vegetation.multimesh = bushes
    var color = Color("27533c")
    match biome:
        "desert": color = Color("927d5f")
        "ice": color = Color("8aa3b1")
        "volcanic": color = Color("565052")
        "alien": color = Color("665a9e")
        "jungle": color = Color("2c8354")
    vegetation.material_override = _mat(color)
    add_child(vegetation)
    var rocks = MultiMesh.new()
    rocks.transform_format = MultiMesh.TRANSFORM_3D
    var rock = PrismMesh.new()
    rock.size = Vector3(2.6,3.4,2.6)
    rocks.mesh = rock
    rocks.instance_count = 135
    for i in range(rocks.instance_count):
        var x = rng.randf_range(-158,158)
        var z = rng.randf_range(-158,158)
        if Vector2(x,z).length() < 19:
            x += 25
        var s = rng.randf_range(0.7,3.1)
        rocks.set_instance_transform(i,Transform3D(Basis.IDENTITY.rotated(Vector3.UP,rng.randf_range(0,TAU)).scaled(Vector3(s,s,s)),Vector3(x,height_at(x,z)+s*0.7,z)))
    var rock_instances = MultiMeshInstance3D.new()
    rock_instances.name = "Felsen - instanziert"
    rock_instances.multimesh = rocks
    rock_instances.material_override = _mat(_biome_color().darkened(0.28),"rock")
    add_child(rock_instances)

func _make_ruins() -> void:
    for anchor in [SCAN_POINT,CORE_POINT]:
        var pos = Vector3(anchor.x,height_at(anchor.x,anchor.y),anchor.y)
        var landmark = Node3D.new()
        landmark.position = pos
        landmark.name = "Ruinen und Forschungsanlage"
        add_child(landmark)
        _box(landmark,"Plattform",Vector3(0,0.15,0),Vector3(22,0.3,22),Color("686c70"),"city_concrete")
        _box(landmark,"Forschungsmodul",Vector3(0,4,-5),Vector3(11,8,6),Color("58606b"),"metal",0.42)
        _box(landmark,"Eingang",Vector3(0,2.2,-1.8),Vector3(3.6,4.4,0.35),Color("262f39"),"metal")
        _box(landmark,"Signalmast",Vector3(-7,11,-4),Vector3(0.6,20,0.6),Color("c1c6c8"),"metal",0.7)
        for i in range(5):
            var height = rng.randf_range(1.5,6.0)
            var wall = _box(landmark,"Ruine",Vector3(rng.randf_range(-12,12),height/2,rng.randf_range(3,11)),Vector3(rng.randf_range(1,4),height,0.7),Color("72706f"),"rock")
            wall.rotation.y = rng.randf_range(-1.0,1.0)
    if biome == "volcanic":
        for i in range(12):
            var x = rng.randf_range(-140,140)
            var z = rng.randf_range(-140,140)
            if Vector2(x,z).length() < 28:
                continue
            var molten = _cylinder(self,Vector3(x,height_at(x,z)+0.25,z),rng.randf_range(1,4),0.5,Color("e46636"))
            molten.material_override = _mat(Color("ff743c"),"",0.0,true)

func _make_objective() -> void:
    objective_marker = Node3D.new()
    objective_marker.name = "Story-Ziel und Scanner"
    add_child(objective_marker)
    var beacon = _cylinder(objective_marker,Vector3(0,2,0),0.23,4,Color("80f8ff"))
    beacon.material_override = _mat(Color("60dfe9"),"",0,true)
    objective_label = Label3D.new()
    objective_label.position.y = 4.5
    objective_label.font_size = 40
    objective_label.pixel_size = 0.006
    objective_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    objective_marker.add_child(objective_label)
    var light = OmniLight3D.new()
    light.position.y = 3
    light.light_color = Color("3bd9ee")
    light.light_energy = 1.4
    light.omni_range = 14
    objective_marker.add_child(light)

func _make_shuttle() -> void:
    var shuttle = Node3D.new()
    shuttle.name = "NEXUS LANDER - begehbarer Landeplatz"
    shuttle.position = Vector3(0,height_at(0,0),0)
    add_child(shuttle)
    _box(shuttle,"Landeplatte",Vector3(0,0.12,0),Vector3(20,0.24,20),Color("444d56"),"metal",0.5)
    _box(shuttle,"Shuttle Rumpf",Vector3(0,3.4,0),Vector3(4.4,3.2,9.2),Color("bdc8d1"),"metal",0.62)
    _box(shuttle,"Cockpit",Vector3(0,4.7,-3.2),Vector3(3.0,1.7,2.6),Color("4e7486"),"metal",0.28)
    for side in [-1,1]:
        _box(shuttle,"Fluegel",Vector3(4.4*side,2.4,1.0),Vector3(6,0.35,3.7),Color("959fa7"),"metal",0.5)
        _cylinder(shuttle,Vector3(1.35*side,1.5,3.6),0.75,2.4,Color("444f57"))
    _box(shuttle,"Antenne",Vector3(0,7.7,2),Vector3(0.16,5,0.16),Color("8ddce6"),"metal")

func _make_player() -> void:
    player = PLAYER_SCRIPT.new()
    player.position = Vector3(0,height_at(0,15)+2.2,15)
    add_child(player)
    player.health = hp

func _restore_visit() -> void:
    var visits: Dictionary = campaign.get("visits",{})
    var record: Dictionary = visits.get(pid,{})
    mission_stage = clampi(int(record.get("stage",0)),0,3)
    kills = clampi(int(record.get("kills",0)),0,20)
    ammo = maxi(1,int(record.get("ammo",48)))
    final_choice = int(record.get("choice", 0))
    if campaign.get("completed",[]).has(pid):
        mission_stage = 3
    if mission_stage == 1:
        _spawn_enemies()

func _make_hud() -> void:
    var layer = CanvasLayer.new()
    add_child(layer)
    var overlay = PanelContainer.new()
    overlay.position = Vector2(14,12)
    overlay.custom_minimum_size = Vector2(580,0)
    layer.add_child(overlay)
    var box = VBoxContainer.new()
    box.add_theme_constant_override("separation",7)
    overlay.add_child(box)
    hud = Label.new()
    hud.add_theme_font_size_override("font_size",17)
    box.add_child(hud)
    message_label = Label.new()
    message_label.add_theme_font_size_override("font_size",16)
    message_label.modulate = Color("9af2e4")
    box.add_child(message_label)
    var controls = HBoxContainer.new()
    box.add_child(controls)
    for record in [{"text":"E  INTERAGIEREN","id":"interact"},{"text":"FEUERN","id":"fire"},{"text":"NACHLADEN","id":"reload"},{"text":"STERNENKARTE","id":"map"}]:
        var button = Button.new()
        button.text = record["text"]
        button.custom_minimum_size = Vector2(120,43)
        var action: String = str(record["id"])
        button.pressed.connect(func(): _ui_action(action))
        controls.add_child(button)
    var cross = Label.new()
    cross.text = "+"
    cross.add_theme_font_size_override("font_size",32)
    cross.set_anchors_preset(Control.PRESET_CENTER)
    layer.add_child(cross)
    var touch = HBoxContainer.new()
    touch.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_LEFT)
    touch.position = Vector2(22,-94)
    layer.add_child(touch)
    for record in [{"text":"◀", "action":"move_left"},{"text":"▲","action":"move_forward"},{"text":"▼","action":"move_backward"},{"text":"▶","action":"move_right"},{"text":"JUMP","action":"jump"}]:
        var button = Button.new()
        button.text = record["text"]
        button.custom_minimum_size = Vector2(72,61)
        var move_action: String = str(record["action"])
        button.button_down.connect(func(): Input.action_press(move_action))
        button.button_up.connect(func(): Input.action_release(move_action))
        touch.add_child(button)

func _ui_action(action: String) -> void:
    match action:
        "interact": _interact()
        "fire": _fire()
        "reload": _reload()
        "map": _to_map()

func _refresh_objective() -> void:
    var pos = EXIT_POINT
    var lore = LORE.info(pid)
    match mission_stage:
        0:
            pos = SCAN_POINT
            objective_label.text = "[E] " + str(lore["scan"])
        1:
            pos = CORE_POINT
            objective_label.text = "SEKTOR SICHERN  //  " + str(lore["faction"])
            if kills >= 3:
                objective_label.text = "[E] " + str(lore["recovery"])
        2:
            pos = EXIT_POINT
            objective_label.text = "[1/2] ENTSCHEIDUNG   [E] RUECKKEHR"
        3:
            objective_label.text = "PLANET ERFORSCHT"
    objective_marker.position = Vector3(pos.x,height_at(pos.x,pos.y),pos.y)
    objective_marker.visible = mission_stage < 3

func _process(delta: float) -> void:
    time_elapsed += delta
    weapon_cooldown = maxf(0.0,weapon_cooldown - delta)
    enemy_attack_cooldown = maxf(0.0,enemy_attack_cooldown-delta)
    message_time = maxf(0.0,message_time-delta)
    if mission_stage == 1:
        _update_enemies(delta)
        if time_elapsed >= 82.0 and not ambush_spawned:
            ambush_spawned = true
            _spawn_enemy(Vector3(100,height_at(100,-20)+1,-20))
            _notice("NEXUS DIRECTOR: Feindliche Verstärkung trifft ein!")
    if mission_stage < 3 and objective_marker != null:
        objective_marker.rotate_y(delta * 0.45)
    if hud != null:
        var target_pos = Vector2(objective_marker.position.x,objective_marker.position.z)
        var player_pos = Vector2(player.global_position.x,player.global_position.z)
        var task = "SCANNER ANSTEUERN" if mission_stage == 0 else ("GEGNER SICHERN %d/3" % mini(kills,3) if mission_stage == 1 and kills < 3 else ("KERN BERGEN" if mission_stage == 1 else ("ZUM LANDER ZURUECK" if mission_stage == 2 else "ERFORSCHUNG ERFOLGREICH")))
        hud.text = "PROJECT NEXUS | PLANETEN-EXPEDITION V1.3\n%s / %s\n%s\nAUFTRAG: %s | Entfernung: %d m\nGesundheit: %d  Munition: %d  Fragmente: %d/6\nWASD bewegen | Maus zielen | Linksklick schiessen | E nutzen | R nachladen | G Sternenkarte" % [
            planet["name"],planet["subtitle"],planet["chapter"],task,roundi(target_pos.distance_to(player_pos)),roundi(hp),ammo,int(campaign.get("intel",0))]
        message_label.text = "" if message_time <= 0.0 else message_label.text

func _spawn_enemy(where: Vector3) -> void:
    var enemy = Node3D.new()
    enemy.name = "Sektor-Wache %d" % (enemies.size()+1)
    enemy.position = where
    add_child(enemy)
    _box(enemy,"Panzerung",Vector3(0,1.2,0),Vector3(0.9,1.55,0.7),Color("596c6b"),"metal")
    var head = _cylinder(enemy,Vector3(0,2.25,0),0.45,0.75,Color("a6a9ac"))
    head.material_override = _mat(Color("adacb8"),"metal",0.5)
    _box(enemy,"Waffe",Vector3(0.56,1.5,-0.2),Vector3(0.25,0.24,1.3),Color("2d3037"),"metal",0.7)
    for side in [-1,1]:
        _box(enemy,"Bein",Vector3(0.24*side,0.36,0),Vector3(0.3,0.72,0.37),Color("494f59"),"metal")
    enemies.append({"node":enemy,"hp":100,"cooldown":rng.randf_range(0,2),"speed":rng.randf_range(1.4,2.3)})

func _spawn_enemies() -> void:
    if enemies.size() > 0:
        return
    for i in range(5):
        var p = CORE_POINT + Vector2(rng.randf_range(-20,20),rng.randf_range(-18,18))
        _spawn_enemy(Vector3(p.x,height_at(p.x,p.y),p.y))

func _update_enemies(delta: float) -> void:
    for enemy in enemies:
        if not is_instance_valid(enemy["node"]):
            continue
        var body: Node3D = enemy["node"]
        var to_player = player.global_position - body.position
        to_player.y = 0.0
        var distance = to_player.length()
        if distance < 31 and distance > 5.5:
            var direction = to_player.normalized()
            var next = body.position + direction * float(enemy["speed"]) * delta
            next.y = height_at(next.x,next.z)
            body.position = next
            body.look_at(Vector3(player.position.x,body.position.y,player.position.z),Vector3.UP)
        enemy["cooldown"] = float(enemy["cooldown"]) - delta
        if distance < 23 and enemy["cooldown"] <= 0.0:
            hp = maxf(0.0,hp - 5.0)
            player.health = hp
            enemy["cooldown"] = 2.4
            if hp <= 0.0:
                _respawn()

func _fire() -> void:
    if weapon_cooldown > 0 or mission_stage == 3:
        return
    weapon_cooldown = 0.22
    if ammo <= 0:
        _notice("Magazin leer. R zum Nachladen.")
        return
    ammo -= 1
    var origin = player.camera.global_position
    var forward = -player.camera.global_transform.basis.z
    var best: Dictionary = {}
    var best_range = 125.0
    for enemy in enemies:
        if not is_instance_valid(enemy["node"]):
            continue
        var pos: Vector3 = enemy["node"].global_position + Vector3(0,1.4,0)
        var vec = pos - origin
        if vec.length() > 125:
            continue
        var projection = forward.dot(vec)
        if projection <= 0 or projection >= best_range:
            continue
        var miss = (vec - forward * projection).length()
        if miss <= 1.1:
            best = enemy
            best_range = projection
    if best.is_empty():
        return
    best["hp"] = int(best["hp"]) - 35
    if int(best["hp"]) <= 0:
        best["node"].queue_free()
        kills += 1
        _notice("Gegner neutralisiert | Sektor %d/3" % mini(kills,3))
        _save_visit()
        _refresh_objective()

func _reload() -> void:
    ammo = 48
    _notice("Munition nachgeladen.")

func _interact() -> void:
    var player_pos = Vector2(player.global_position.x,player.global_position.z)
    match mission_stage:
        0:
            if player_pos.distance_to(SCAN_POINT) < 12:
                mission_stage = 1
                _spawn_enemies()
                _notice("%s  //  %s" % [LORE.info(pid)["scan"], LORE.info(pid)["conflict"]])
            else:
                _notice("Gehe zum cyanfarbenen Scanner im Forschungssektor.")
        1:
            if kills >= 3 and player_pos.distance_to(CORE_POINT) < 14:
                mission_stage = 2
                _notice("%s  //  WAEHLE 1 ODER 2, DANACH ZUM LANDER" % LORE.info(pid)["recovery"])
            else:
                _notice("Sichere den Sektor und neutralisiere mindestens drei Wachen.")
        2:
            if player_pos.distance_to(EXIT_POINT) < 13 and final_choice == 0:
                _notice("Entscheide erst: 1 = %s   /   2 = %s" % [LORE.info(pid)["choice_a"],LORE.info(pid)["choice_b"]])
            elif player_pos.distance_to(EXIT_POINT) < 13:
                mission_stage = 3
                campaign = CAMPAIGN.complete_planet(campaign,pid,final_choice)
                _notice("Kapitel abgeschlossen! %s  |  G zur Sternenkarte." % LORE.info(pid)["secret"])
            else:
                _notice("Rendezvous am Landepad noerdlich des Shuttles.")
        _:
            _notice("Expedition abgeschlossen. G zur Sternenkarte.")
    _save_visit()
    _refresh_objective()

func _save_visit() -> void:
    var visits: Dictionary = campaign.get("visits",{})
    visits[pid] = {"stage":mission_stage,"kills":kills,"ammo":ammo,"choice":final_choice}
    campaign["visits"] = visits
    CAMPAIGN.save_data(campaign)

func _respawn() -> void:
    hp = 100.0
    player.health = hp
    player.velocity = Vector3.ZERO
    player.global_position = Vector3(0,height_at(0,15)+2.0,15)
    _notice("Evakuierung durch NEXUS-MedEvac. Mission bleibt bestehen.")

func _notice(message: String) -> void:
    message_time = 6.0
    if message_label != null:
        message_label.text = message

func _to_map() -> void:
    _save_visit()
    get_tree().change_scene_to_file("res://scenes/starmap.tscn")

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        match event.keycode:
            KEY_G: _to_map()
            KEY_1: _choose(1)
            KEY_2: _choose(2)
            KEY_E: _interact()
            KEY_R: _reload()
            KEY_ESCAPE:
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_CAPTURED
    elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
        if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
            _fire()

func _choose(chosen: int) -> void:
    if mission_stage != 2:
        _notice("Die Entscheidung wird am Ende der Expedition freigeschaltet.")
        return
    final_choice = clampi(chosen,1,2)
    var lore = LORE.info(pid)
    _notice("Entscheidung registriert: " + str(lore["choice_a"] if final_choice == 1 else lore["choice_b"]))
    _save_visit()
