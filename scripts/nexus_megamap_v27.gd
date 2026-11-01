extends Node3D
class_name NexusMegaMapV27
## PROJECT NEXUS V2.7 — original, mixed-biome world districts.
## Inspired by the density and tactical variety of large modern shooter maps,
## never a copy of another game's map or assets. Procedural prototype meshes.
## Stable world-space anchors, material layering and distance-based scenic LOD.

const PRODUCTION = preload("res://scripts/nexus_production_assets.gd")
const ADLERKLAMM_EVENT_SCRIPT = preload("res://scripts/nexus_adlerklamm_disaster_v34.gd")
const INDUSTRY_SKYLINE_SCRIPT = preload("res://scripts/nexus_industry_skyline_v34.gd")
const ADLERKLAMM_ENVIRONMENT = preload("res://scripts/nexus_adlerklamm_environment_v35.gd")
const SEED: int = 273010
const DISTRICTS: Dictionary = {
    "aurelia": {"title":"Aurelia | Luxushochhaus-City", "style":"luxury", "center":Vector3(-135.0,0.0,86.0), "radius":65.0},
    "stahlhafen": {"title":"Stahlhafen | Industrie & Wiederaufbau", "style":"industrial", "center":Vector3(-165.0,0.0,-112.0), "radius":53.0},
    "silberkueste": {"title":"Silberkueste | Wasserstadt", "style":"waterfront", "center":Vector3(-175.0,0.0,166.0), "radius":50.0},
    "bergstadt": {"title":"Bergstadt | Alte Alpenstadt", "style":"mountain", "center":Vector3(12.0,0.0,177.0), "radius":55.0},
    "canyon": {"title":"Adlerklamm | Talbruecke", "style":"gorge", "center":Vector3(175.0,0.0,168.0), "radius":60.0}
}

var quality: int = 2
var actor: Node3D
var city_chunks: Dictionary = {}
var always_on: Node3D
var materials: Dictionary = {}
var next_update: float = 0.0
var building_count: int = 0
var bridge_deck: StaticBody3D
var canyon_disaster: NexusAdlerklammDisaster
var landmark_count: int = 0

func _ready() -> void:
    name = "PROJECT NEXUS | V2.7 differentiated megamap (visual alpha)"
    always_on = Node3D.new()
    always_on.name = "Connected arterial roads and collidable canyon bridge"
    add_child(always_on)
    for id in DISTRICTS.keys():
        var region := Node3D.new()
        region.name = str(DISTRICTS[id]["title"])
        region.position = DISTRICTS[id]["center"]
        add_child(region)
        city_chunks[id] = region
        _build_region(str(id), region)
    _build_canyon_bridge()
    # Capture only bridge-owned geometry before arterial connectors are added.
    var original_bridge: Array[Node] = always_on.get_children()
    canyon_disaster = ADLERKLAMM_EVENT_SCRIPT.new()
    add_child(canyon_disaster)
    canyon_disaster.configure_bridge(original_bridge)
    _build_connector_roads()
    _update_visibility()

func set_actor(target: Node3D) -> void:
    actor = target
    _update_visibility()

func set_graphics_tier(value: int) -> void:
    quality = clampi(value,0,2)
    _update_visibility()

func _process(delta: float) -> void:
    next_update += delta
    if next_update >= 0.65:
        next_update = 0.0
        _update_visibility()

func get_region_at(point: Vector3) -> String:
    var best := "wildnis"
    var score := INF
    for id in DISTRICTS.keys():
        var d: Dictionary = DISTRICTS[id]
        var c: Vector3 = d["center"]
        var dist := Vector2(point.x-c.x,point.z-c.z).length()
        if dist <= float(d["radius"]) and dist < score:
            score = dist
            best = str(id)
    return best

func _update_visibility() -> void:
    for id in city_chunks.keys():
        var chunk: Node3D = city_chunks[id]
        if actor == null or not is_instance_valid(actor):
            chunk.visible = true
            continue
        var center: Vector3 = DISTRICTS[id]["center"]
        var horizontal := Vector2(center.x-actor.global_position.x,center.z-actor.global_position.z).length()
        var budget := 140.0 if quality == 0 else (240.0 if quality == 1 else 390.0)
        chunk.visible = horizontal < budget
        for child in chunk.get_children():
            if child is Node3D and str(child.name).begins_with("HD "):
                (child as Node3D).visible = quality == 2 and horizontal < 120.0

func _pbr(key: String, tint: Color, metal: float = 0.0, rough: float = 0.65) -> StandardMaterial3D:
    var signature := "%s_%s_%.2f" % [key,tint.to_html(),rough]
    if materials.has(signature):
        return materials[signature]
    var material := StandardMaterial3D.new()
    material.albedo_color = tint
    material.metallic = metal
    material.roughness = rough
    var albedo: Texture2D = PRODUCTION.surface_texture(key,"albedo")
    if albedo != null:
        material.albedo_texture = albedo
        material.uv1_triplanar = true
        material.uv1_scale = Vector3(0.33,0.33,0.33)
    var normal: Texture2D = PRODUCTION.surface_texture(key,"normal")
    if normal != null:
        material.normal_enabled = true
        material.normal_texture = normal
        material.normal_scale = 0.45
    var roughness_map: Texture2D = PRODUCTION.surface_texture(key,"roughness")
    if roughness_map != null:
        material.roughness_texture = roughness_map
        material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
    material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
    materials[signature] = material
    return material

func _box(where: Node3D, label: String, at: Vector3, size: Vector3, material: Material, collision: bool = false, yaw: float = 0.0) -> Node3D:
    var holder: Node3D = StaticBody3D.new() if collision else Node3D.new()
    holder.name = label
    holder.position = at
    holder.rotation.y = yaw
    where.add_child(holder)
    var mesh := BoxMesh.new()
    mesh.size = size
    var item := MeshInstance3D.new()
    item.mesh = mesh
    item.material_override = material
    item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    holder.add_child(item)
    if collision:
        var cshape := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        cshape.shape = shape
        holder.add_child(cshape)
    return holder

func _road(start: Vector3, finish: Vector3, width: float = 7.0, bridge: bool = false) -> void:
    var length := Vector2(finish.x-start.x,finish.z-start.z).length()
    if length < 0.1:
        return
    var midpoint := (start+finish)*0.5
    var rotation_y := atan2(finish.x-start.x,finish.z-start.z)
    var asphalt := _pbr("asphalt",Color("909294"),0.02,0.83)
    _box(always_on,"Road | route",midpoint,Vector3(width,0.25,length),asphalt,bridge,rotation_y)
    var markings := _pbr("",Color("d8d1b7"),0.0,0.72)
    var dashes := maxi(1,int(length/9.0))
    for index in range(dashes):
        var t := (float(index)+0.5)/float(dashes)
        var p := start.lerp(finish,t)+Vector3(0.0,0.15,0.0)
        _box(always_on,"Road center mark",p,Vector3(0.18,0.022,3.2),markings,false,rotation_y)

func _build_connector_roads() -> void:
    # Extra authored links that visually join the legacy city with new districts.
    _road(Vector3(-62,0.18,58), Vector3(-135,0.18,86), 8.0)
    _road(Vector3(-135,0.18,86), Vector3(-175,0.18,166), 8.0)
    _road(Vector3(-53,0.18,-39), Vector3(-165,0.18,-112), 8.0)
    _road(Vector3(12,0.18,135), Vector3(12,0.18,177), 6.5)
    _road(Vector3(117,0.22,114), Vector3(175,0.22,127), 7.0)
    _road(Vector3(175,0.22,209), Vector3(175,0.22,222), 7.0)

func _build_canyon_bridge() -> void:
    var asphalt := _pbr("asphalt",Color("8b8d90"),0.0,0.85)
    var concrete := _pbr("concrete",Color("b4b6b5"),0.0,0.92)
    var iron := _pbr("",Color("505b62"),0.75,0.37)
    # The V2.6 canyon sinks nearly 38 m below y=0. Bridge crosses its north-south banks.
    bridge_deck = _box(always_on,"Adlerklamm bridge | drivable collidable deck",Vector3(175,0.0,168),Vector3(10,0.65,82),asphalt,true) as StaticBody3D
    for side in [-1.0,1.0]:
        var sx: float = 175.0 + float(side)*4.75
        _box(always_on,"Bridge crash barrier",Vector3(sx,1.25,168),Vector3(0.37,1.2,82),concrete,true)
        _box(always_on,"Bridge steel railing",Vector3(sx,2.50,168),Vector3(0.16,0.16,82),iron)
        for index in range(17):
            var z := 129.0+float(index)*4.85
            _box(always_on,"Bridge railing upright",Vector3(sx,1.98,z),Vector3(0.17,1.65,0.18),iron)
    for z in [143.0,168.0,193.0]:
        _box(always_on,"Bridge deep canyon pier",Vector3(175,-18.0,z),Vector3(2.6,38.0,4.5),concrete)
        _box(always_on,"Bridge lower truss",Vector3(175,-1.2,z),Vector3(9.1,0.8,1.3),iron)
    for x in [171.5,178.5]:
        _box(always_on,"Bridge side beam",Vector3(x,-0.35,168),Vector3(0.9,1.3,81),iron)
    _road(Vector3(175,0.35,127),Vector3(175,0.35,209),7.6,false)
    landmark_count += 1

func _build_region(id: String, parent: Node3D) -> void:
    var style: String = str(DISTRICTS[id]["style"])
    if style == "luxury":
        _luxury_city(parent)
    elif style == "industrial":
        _industrial_city(parent)
    elif style == "waterfront":
        _waterfront_city(parent)
    elif style == "mountain":
        _alpine_city(parent)
    elif style == "gorge":
        _gorge_lookouts(parent)
        var skyline := INDUSTRY_SKYLINE_SCRIPT.new()
        parent.add_child(skyline)
        var canyon_art := ADLERKLAMM_ENVIRONMENT.new()
        # Art pass uses absolute world-space rock/river coordinates.
        add_child(canyon_art)

func _luxury_city(parent: Node3D) -> void:
    var glass := _pbr("",Color("506e80"),0.28,0.14)
    var facade := _pbr("concrete",Color("ddd2bd"),0.05,0.65)
    var roof := _pbr("",Color("3a444c"),0.65,0.4)
    var green := _pbr("grass",Color("668b53"),0.0,1.0)
    _box(parent,"Luxury boulevard central plaza",Vector3(0,-0.15,0),Vector3(112,0.25,116),_pbr("concrete",Color("9e9b93")))
    var rng := RandomNumberGenerator.new()
    rng.seed = SEED
    var windows: Array[Transform3D] = []
    var window_colors: Array[Color] = []
    for gx in range(5):
        for gz in range(5):
            if gx == 2 or gz == 2:
                continue  # Streets and wide visibility lanes through the city.
            var x := (float(gx)-2.0)*24.0
            var z := (float(gz)-2.0)*24.0
            var height: float = float(rng.randi_range(38,94))
            var width: float = rng.randf_range(11,17)
            _box(parent,"Luxury highrise %d_%d" % [gx,gz],Vector3(x,height*0.5,z),Vector3(width,height,width*0.82),glass,true)
            _box(parent,"Roof terrace",Vector3(x,height+0.25,z),Vector3(width+1,0.55,width*0.87+1),roof)
            _box(parent,"Luxury entrance podium",Vector3(x,1.3,z+width*0.47),Vector3(width+3,2.6,3.5),facade)
            for side in [-1.0,1.0]:
                for level in range(3,int(height/4.0)):
                    for col in range(3):
                        var px := x+(float(col)-1.0)*(width*0.28)
                        var py := float(level)*3.9+1.5
                        var pz: float = z+float(side)*(width*0.42+0.06)
                        windows.append(Transform3D(Basis.from_scale(Vector3(width*0.16,2.4,0.07)),Vector3(px,py,pz)))
                        window_colors.append(Color("bcd6eb") if rng.randf() < 0.67 else Color("ffe2a4"))
            building_count += 1
    _make_windows(parent,windows,window_colors)
    for ix in range(-2,3):
        _box(parent,"Luxury boulevard glass median",Vector3(float(ix)*17.0,0.25,0),Vector3(5.0,0.2,5.0),green)
    landmark_count += 1

func _make_windows(parent: Node3D, transforms: Array[Transform3D], colors: Array[Color]) -> void:
    if transforms.is_empty():
        return
    var unit := BoxMesh.new()
    unit.size = Vector3.ONE
    var mat := StandardMaterial3D.new()
    mat.vertex_color_use_as_albedo = true
    mat.roughness = 0.14
    mat.metallic = 0.3
    unit.material = mat
    var multi := MultiMesh.new()
    multi.transform_format = MultiMesh.TRANSFORM_3D
    multi.use_colors = true
    multi.mesh = unit
    multi.instance_count = transforms.size()
    for index in range(transforms.size()):
        multi.set_instance_transform(index,transforms[index])
        multi.set_instance_color(index,colors[index])
    var node := MultiMeshInstance3D.new()
    node.name = "HD facade window atlas | %d instances" % transforms.size()
    node.multimesh = multi
    node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    parent.add_child(node)

func _industrial_city(parent: Node3D) -> void:
    var concrete := _pbr("concrete",Color("7c8285"))
    var rust := _pbr("",Color("706350"),0.48,0.7)
    var roof := _pbr("roof",Color("7e7163"))
    for ix in range(4):
        for iz in range(3):
            var x := (float(ix)-1.5)*23.0
            var z := (float(iz)-1.0)*28.0
            var h := 9.0+float((ix*5+iz*7)%6)*3.2
            _box(parent,"Industrial production hall",Vector3(x,h*0.5,z),Vector3(16,h,20),concrete,true)
            _box(parent,"Factory roof",Vector3(x,h+0.3,z),Vector3(17,0.65,21),roof)
            _box(parent,"Factory roof exhaust",Vector3(x+5,h+3,z),Vector3(1.4,5.0,1.4),rust)
            building_count += 1
    for i in range(5):
        var p := Vector3(-40.0+float(i)*18.0,1.0,44.0)
        _box(parent,"Construction concrete pillars",p+Vector3(0,5,0),Vector3(0.8,10,0.8),concrete)
        _box(parent,"Construction steel truss",p+Vector3(0,10,0),Vector3(15,0.8,0.9),rust)
    landmark_count += 1

func _waterfront_city(parent: Node3D) -> void:
    var water := _pbr("",Color("286b86"),0.18,0.19)
    var decking := _pbr("wood",Color("a18e71"))
    var glass := _pbr("",Color("829fb2"),0.23,0.17)
    var sandstone := _pbr("concrete",Color("d1c8a9"))
    _box(parent,"Harbor basin water | reflective PBR plane",Vector3(-2,0.25,12),Vector3(100,0.12,50),water)
    for i in range(7):
        var x := -42.0+float(i)*14.0
        _box(parent,"Waterfront pier",Vector3(x,0.55,4),Vector3(5.8,0.55,32),decking)
        var h := 15.0+float(i%4)*6.0
        _box(parent,"Waterfront hotel and residence",Vector3(x,h*0.5,-31),Vector3(11.0,h,13.0),glass,true)
        _box(parent,"Marina streetlevel arcade",Vector3(x,1.5,-31),Vector3(12.0,2.9,14.0),sandstone)
        building_count += 1
    landmark_count += 1

func _alpine_city(parent: Node3D) -> void:
    var wood := _pbr("wood",Color("a68a65"))
    var stone := _pbr("rock",Color("95958b"))
    var tiles := _pbr("roof",Color("9c6251"))
    for i in range(13):
        var col := i%5
        var row := i/5
        var x := (float(col)-2.0)*17.0
        var z := (float(row)-1.0)*25.0
        var height := 7.0+float(i%3)*2.3
        _box(parent,"Alpine inn stone ground floor",Vector3(x,1.6,z),Vector3(11,3.2,12),stone,true)
        _box(parent,"Alpine timber upper floors",Vector3(x,3.2+height*0.5,z),Vector3(11,height,12),wood)
        _box(parent,"Gabled roof volume",Vector3(x,4.0+height,z),Vector3(12,1.4,13),tiles)
        for y in range(2):
            _box(parent,"Alpine balcony",Vector3(x,4.0+float(y)*3.0,z+6.8),Vector3(9.0,0.25,1.6),wood)
        building_count += 1
    _box(parent,"Mountain church nave",Vector3(42,7,36),Vector3(16,14,29),stone,true)
    _box(parent,"Mountain church roof",Vector3(42,14.8,36),Vector3(18,1.4,31),tiles)
    _box(parent,"Mountain bell tower",Vector3(42,19,21),Vector3(6,38,6),stone,true)
    _box(parent,"Mountain bell tower cap",Vector3(42,38.7,21),Vector3(8,1.5,8),tiles)
    landmark_count += 1

func _gorge_lookouts(parent: Node3D) -> void:
    var rock := _pbr("rock",Color("8d8982"))
    var timber := _pbr("wood",Color("806b55"))
    for side in [-1.0,1.0]:
        var z: float = 57.0*float(side)
        _box(parent,"Rock scenic overlook",Vector3(21*side,0.3,z),Vector3(17,0.6,15),rock)
        _box(parent,"Overlook observation rail",Vector3(21*side,1.45,z+5),Vector3(17,1.3,0.25),timber)
    landmark_count += 1
