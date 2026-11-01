extends Node3D
class_name NexusWorldStructure
const ASSETS = preload("res://scripts/nexus_production_assets.gd")
## V2.5: deterministic Alpine world layout and distance-aware scenic chunks.
## Adds roads, street-level cues, district landmarks, and instanced foliage.
## Mission-relevant buildings remain in world.gd and NEVER stream out.
## The static environment is a prototype until authored elevation meshes/terrain streaming arrive.

const DISTRICTS: Dictionary = {
    "alpendorf": {"label":"Alpendorf", "position":Vector3(102,0,-33), "radius":45.0, "style":"village"},
    "rettungsbasis": {"label":"Bergrettung", "position":Vector3(48,0,45), "radius":32.0, "style":"rescue"},
    "sektor31": {"label":"Sektor 31", "position":Vector3(116,0,-11), "radius":30.0, "style":"security"},
    "stadt": {"label":"NEXUS City", "position":Vector3(-62,0,58), "radius":46.0, "style":"urban"},
    "bauhof": {"label":"Wiederaufbau", "position":Vector3(-55,0,108), "radius":37.0, "style":"construction"},
    "industrie": {"label":"Industrie", "position":Vector3(-53,0,-39), "radius":43.0, "style":"industrial"},
    "raumhafen": {"label":"Raumhafen", "position":Vector3(117,0,114), "radius":38.0, "style":"spaceport"}
}

# Named graph: links connect via intermediate junctions rather than jumping straight
# through other buildings. All named districts are reachable from the starting garage.
const WAYPOINTS: Dictionary = {
    "garage": Vector3(17,0,-10),
    "crossroads": Vector3(50,0,-1),
    "village_junction": Vector3(102,0,2),
    "alpendorf": Vector3(102,0,-33),
    "rettungsbasis": Vector3(48,0,45),
    "sektor31": Vector3(116,0,-11),
    "city_junction": Vector3(-34,0,6),
    "stadt": Vector3(-62,0,58),
    "bauhof": Vector3(-55,0,108),
    "industrie": Vector3(-53,0,-39),
    "east_connector": Vector3(120,0,64),
    "raumhafen": Vector3(117,0,114)
}
const ROAD_EDGES = [
    ["garage","crossroads"],
    ["crossroads","village_junction"],
    ["village_junction","alpendorf"],
    ["village_junction","sektor31"],
    ["crossroads","rettungsbasis"],
    ["crossroads","east_connector"],
    ["east_connector","raumhafen"],
    ["garage","city_junction"],
    ["city_junction","stadt"],
    ["stadt","bauhof"],
    ["city_junction","industrie"]
]

const DETAIL_DISTANCE: float = 115.0
const MAX_RENDER_DISTANCE: float = 205.0
const UPDATE_INTERVAL: float = 0.6
const SEED: int = 20261101
var graphics_tier: int = 2
var player_actor: Node3D
var detail_chunks: Dictionary = {}
var distance_timer: float = 0.0
var mats: Dictionary = {}
var roads_root: Node3D
var scenery_root: Node3D
var route_segments: Array[Dictionary] = []

func _ready() -> void:
    name = "NEXUS | Alpine districts + road network + foliage LOD"
    roads_root = Node3D.new()
    roads_root.name = "Navigation roads"
    add_child(roads_root)
    scenery_root = Node3D.new()
    scenery_root.name = "Streamable detail only | NO mission collision"
    add_child(scenery_root)
    _build_roads()
    for district_id in DISTRICTS.keys():
        var chunk := Node3D.new()
        chunk.name = "District details | " + str(district_id)
        chunk.position = DISTRICTS[district_id]["position"]
        scenery_root.add_child(chunk)
        detail_chunks[district_id] = chunk
        _build_district(district_id, chunk)
    _update_visibility()

func bind_actor(actor: Node3D) -> void:
    player_actor = actor
    _update_visibility()

func apply_graphics_tier(tier: int) -> void:
    graphics_tier = clampi(tier,0,2)
    _update_visibility()

func get_district_at(location: Vector3) -> String:
    var best := "wildnis"
    var best_distance := INF
    for district_id in DISTRICTS.keys():
        var d: Dictionary = DISTRICTS[district_id]
        var p: Vector3 = d["position"]
        var delta := Vector2(location.x - p.x,location.z - p.z)
        if delta.length() <= float(d["radius"]) and delta.length() < best_distance:
            best = district_id
            best_distance = delta.length()
    return best

func find_road_route(start_id: String, goal_id: String) -> PackedStringArray:
    if not WAYPOINTS.has(start_id) or not WAYPOINTS.has(goal_id):
        return PackedStringArray()
    var queue: Array[String] = [start_id]
    var parent: Dictionary = {start_id:""}
    var current_index := 0
    while current_index < queue.size():
        var point: String = queue[current_index]
        current_index += 1
        if point == goal_id:
            var route := PackedStringArray()
            while point != "":
                route.insert(0,point)
                point = str(parent[point])
            return route
        for edge in ROAD_EDGES:
            var neighbour := ""
            if edge[0] == point: neighbour = edge[1]
            elif edge[1] == point: neighbour = edge[0]
            if neighbour != "" and not parent.has(neighbour):
                parent[neighbour] = point
                queue.append(neighbour)
    return PackedStringArray()

func _process(delta: float) -> void:
    distance_timer += delta
    if distance_timer < UPDATE_INTERVAL:
        return
    distance_timer = 0.0
    _update_visibility()

func _update_visibility() -> void:
    for district_id in detail_chunks.keys():
        var chunk: Node3D = detail_chunks[district_id]
        if player_actor == null or not is_instance_valid(player_actor):
            chunk.visible = graphics_tier != 0
            continue
        var p: Vector3 = player_actor.global_position
        var center: Vector3 = DISTRICTS[district_id]["position"]
        var dist := Vector2(p.x-center.x,p.z-center.z).length()
        chunk.visible = graphics_tier > 0 and dist < (DETAIL_DISTANCE if graphics_tier == 1 else MAX_RENDER_DISTANCE)

func _material(key: String, color: Color, metallic: float = 0.0, roughness: float = 0.8) -> Material:
    if mats.has(key):
        return mats[key]
    var result := StandardMaterial3D.new()
    result.albedo_color = color
    result.metallic = metallic
    result.roughness = roughness
    var channel: String = ""
    if key == "connector_asphalt": channel = "asphalt"
    elif key == "pavement": channel = "concrete"
    elif key == "alpine_wood": channel = "wood"
    elif key == "stone": channel = "rock"
    if channel != "":
        var albedo: Texture2D = ASSETS.surface_texture(channel,"albedo")
        if albedo != null: result.albedo_texture = albedo
        var normal: Texture2D = ASSETS.surface_texture(channel,"normal")
        if normal != null:
            result.normal_enabled = true
            result.normal_texture = normal
            result.normal_scale = 0.48
        var roughness_map: Texture2D = ASSETS.surface_texture(channel,"roughness")
        if roughness_map != null:
            result.roughness_texture = roughness_map
            result.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
        result.uv1_triplanar = true
        result.uv1_scale = Vector3(0.3,0.3,0.3)
    mats[key] = result
    return result

func _block(parent: Node3D, tag: String, offset: Vector3, size: Vector3, material: Material, heading: float = 0.0) -> MeshInstance3D:
    var item := MeshInstance3D.new()
    item.name = tag
    var mesh := BoxMesh.new()
    mesh.size = size
    item.mesh = mesh
    item.position = offset
    item.rotation.y = heading
    item.material_override = material
    item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    parent.add_child(item)
    return item

func _road_piece(p0: Vector3, p1: Vector3, width: float = 6.0) -> void:
    var direction := p1-p0
    var length := Vector2(direction.x,direction.z).length()
    if length < 0.01:
        return
    var center := (p0+p1)*0.5 + Vector3(0,0.048,0)
    var yaw := atan2(direction.x,direction.z)
    var road_mat: Material = _material("connector_asphalt",Color("484c4c"),0.0,0.83)
    var centerline_mat: Material = _material("connector_lane",Color("d8d3b9"),0.0,0.84)
    var kerb_mat: Material = _material("connector_kerb",Color("85837e"),0.0,0.9)
    _block(roads_root,"Road connector",center,Vector3(width,0.035,length),road_mat,yaw)
    var direction_2d := Vector2(direction.x,direction.z).normalized()
    var right := Vector3(direction_2d.y,0,-direction_2d.x)
    for side in [-1.0,1.0]:
        _block(roads_root,"Road shoulder",center + right*side*(width*0.5+0.13),Vector3(0.23,0.085,length),kerb_mat,yaw)
    var dashes := int(length/8.0)
    for index in range(dashes):
        var t := (float(index)+0.5)/float(maxi(dashes,1))
        var marker := p0.lerp(p1,t) + Vector3(0,0.095,0)
        _block(roads_root,"Center dash",marker,Vector3(0.15,0.008,2.6),centerline_mat,yaw)
    route_segments.append({"from":p0,"to":p1,"length":length,"width":width})

func _build_roads() -> void:
    for edge in ROAD_EDGES:
        _road_piece(WAYPOINTS[edge[0]],WAYPOINTS[edge[1]],6.6 if edge[0]=="crossroads" else 5.4)

func _build_district(district_id: String, chunk: Node3D) -> void:
    var descriptor: Dictionary = DISTRICTS[district_id]
    var style: String = descriptor["style"]
    var paving := _material("pavement",Color("77766e"),0.0,0.92)
    var timber := _material("alpine_wood",Color("675344"),0.0,0.87)
    var metal := _material("street_metal",Color("6e7a7b"),0.72,0.39)
    var safety := _material("safety_paint",Color("e6a93a"),0.0,0.58)
    var stone := _material("stone",Color("7e837d"),0.02,0.94)
    # Parked vehicles, story objects and buildings are deliberately owned by
    # their original gameplay subsystems, not these visual-only LOD chunks.
    if style in ["village", "rescue", "urban"]:
        for i in range(7):
            var x := -12.0 + float(i)*4.0
            _block(chunk,"Pavement",Vector3(x,0.11,12),Vector3(3.9,0.18,2.6),paving)
        for i in range(7):
            var x := -12.0 + float(i)*4.0
            _block(chunk,"Fence post",Vector3(x,0.72,14.0),Vector3(0.11,1.45,0.11),timber)
        _block(chunk,"Fence beam",Vector3(0,0.98,14.0),Vector3(27.5,0.12,0.11),timber)
    if style == "village":
        for i in range(7):
            _block(chunk,"Village stone wall",Vector3(-17.0,0.42,-22.0+float(i)*5.0),Vector3(0.7,0.84,4.8),stone)
        _pbr_foliage(chunk,Vector3(-2,0,-1),35.0,190,SEED+11)
    elif style == "rescue":
        for i in range(12):
            var angle := TAU*float(i)/12.0
            _block(chunk,"Helipad border",Vector3(cos(angle)*15,0.17,sin(angle)*15),Vector3(0.5,0.12,2.0),safety,-angle)
        _pbr_foliage(chunk,Vector3(-10,0,0),25.0,85,SEED+16)
    elif style == "security":
        for i in range(8):
            _block(chunk,"Checkpoint stanchion",Vector3(-16.0+float(i)*4.5,1.5,24),Vector3(0.14,3.0,0.14),metal)
        _block(chunk,"Checkpoint barrier",Vector3(0,2.6,24),Vector3(36.0,0.15,0.14),metal)
        for i in range(8):
            _block(chunk,"Barricade stripe",Vector3(-16.0+float(i)*4.5,0.6,20),Vector3(2.5,1.2,0.4),safety)
    elif style == "urban":
        for i in range(9):
            var z := -26.0+float(i)*6.5
            _block(chunk,"Street bollard",Vector3(-13,0.55,z),Vector3(0.22,1.1,0.22),metal)
            _block(chunk,"Bus stop pavement",Vector3(12,0.16,z),Vector3(3.2,0.24,4.5),paving)
        _pbr_foliage(chunk,Vector3(14,0,-5),15.0,45,SEED+55)
    elif style == "construction":
        for i in range(9):
            var z := -13.0+float(i)*4.0
            _block(chunk,"Material stack",Vector3(17.0,0.43,z),Vector3(3.5,0.85,1.3),stone)
            _block(chunk,"Barricade",Vector3(-18,0.65,z),Vector3(0.4,1.3,2.4),safety)
    elif style == "industrial":
        for i in range(9):
            _block(chunk,"Loading dock",Vector3(-20+float(i)*5.0,0.5,16),Vector3(4.5,1.0,5.0),paving)
    elif style == "spaceport":
        for ring in range(24):
            var angle := TAU*float(ring)/24.0
            _block(chunk,"Landing guidance",Vector3(cos(angle)*24,0.2,sin(angle)*24),Vector3(0.55,0.08,2.5),safety,-angle)
        for i in range(6):
            _block(chunk,"Cargo loading point",Vector3(-20+float(i)*8.0,0.9,-26),Vector3(5.0,1.8,2.7),metal)

func _pbr_foliage(parent: Node3D, local_center: Vector3, radius: float, count: int, seed_value: int) -> void:
    # Efficient MultiMesh LOD vegetation for mobile instead of hundreds of nodes.
    # Intentionally cosmetic and deterministic: no blocking player collision.
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value
    var tuft := SphereMesh.new()
    tuft.radial_segments = 5
    tuft.rings = 3
    var grass_mat := StandardMaterial3D.new()
    grass_mat.vertex_color_use_as_albedo = true
    grass_mat.roughness = 1.0
    tuft.material = grass_mat
    var mm := MultiMesh.new()
    mm.transform_format = MultiMesh.TRANSFORM_3D
    mm.use_colors = true
    mm.mesh = tuft
    mm.instance_count = count
    for i in range(count):
        var angle := rng.randf_range(0.0,TAU)
        var r := sqrt(rng.randf())*radius
        var scale_value := rng.randf_range(0.3,0.9)
        var t := Transform3D(Basis.from_scale(Vector3(scale_value,scale_value*0.52,scale_value)), local_center+Vector3(cos(angle)*r,0.22,sin(angle)*r))
        mm.set_instance_transform(i,t)
        mm.set_instance_color(i,Color.from_hsv(rng.randf_range(0.25,0.37),0.48,rng.randf_range(0.22,0.55)))
    var foliage := MultiMeshInstance3D.new()
    foliage.name = "LOD vegetation %d" % count
    foliage.multimesh = mm
    foliage.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    parent.add_child(foliage)