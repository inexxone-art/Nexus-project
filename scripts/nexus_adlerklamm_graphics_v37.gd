extends Node3D
class_name NexusAdlerklammGraphicsV37
## V3.7: high-density, procedurally AUTHORED visual pass around Adlerklamm.
## Not photogrammetry. Licensed PBR texture maps come from assets/production.
## CPU/editor headless compatibility; no runtime downloads, optional hero GLB.
const PRODUCTION = preload("res://scripts/nexus_production_assets.gd")
const TERRAIN = preload("res://scripts/nexus_terrain_v26.gd")
const GROUND_SHADER = preload("res://shaders/nexus_ground_v37.gdshader")
const RIVER_SHADER = preload("res://shaders/nexus_river_v37.gdshader")
var owner_world
var ground_material: ShaderMaterial
var canyon_river_material: ShaderMaterial
var cliff_count: int = 0
var pine_count: int = 0
var response_vehicle_count: int = 0
var rescue_helicopter: Node3D
var sky_preset_applied: bool = false
var clock_timer: float = 0.0
var models: Dictionary = {}

func _ready() -> void:
    name = "Adlerklamm V3.7 | cinematic geology, forest, river, response services"
    _spawn_cliff_sides()
    _spawn_alpine_forest()
    _stage_emergency_vehicles()
    _stage_helicopter()
    _stage_water_spray()

func bind_game(world_node) -> void:
    owner_world = world_node
    _terrain_surface()
    _render_environment()
    if owner_world.mega_map != null:
        for child in owner_world.mega_map.get_children():
            if child is NexusAdlerklammEnvironmentV35:
                if child.river != null and child.river.material_override is ShaderMaterial:
                    canyon_river_material = child.river.material_override

func _rock_material() -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color("c7c6c0")
    mat.roughness = 0.87
    mat.uv1_triplanar = true
    mat.uv1_scale = Vector3(0.18,0.18,0.18)
    mat.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
    var albedo := PRODUCTION.surface_texture("rock","albedo")
    var roughness := PRODUCTION.surface_texture("rock","roughness")
    var normal := PRODUCTION.surface_texture("rock","normal")
    if albedo != null:
        mat.albedo_texture = albedo
    if roughness != null:
        mat.roughness_texture = roughness
        mat.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
    if normal != null:
        mat.normal_enabled = true
        mat.normal_texture = normal
        mat.normal_scale = 0.55
    return mat

func _terrain_surface() -> void:
    if owner_world == null or owner_world.ground_body == null:
        return
    var rock := PRODUCTION.surface_texture("rock","albedo")
    var grass := PRODUCTION.surface_texture("grass","albedo")
    var asphalt := PRODUCTION.surface_texture("asphalt","albedo")
    var rock_rough := PRODUCTION.surface_texture("rock","roughness")
    var grass_rough := PRODUCTION.surface_texture("grass","roughness")
    if rock == null or grass == null or asphalt == null or rock_rough == null or grass_rough == null:
        push_warning("V3.7 PBR terrain texture missing; keep original ground fallback.")
        return
    ground_material = ShaderMaterial.new()
    ground_material.shader = GROUND_SHADER
    ground_material.set_shader_parameter("rock_albedo",rock)
    ground_material.set_shader_parameter("rock_roughness",rock_rough)
    ground_material.set_shader_parameter("grass_albedo",grass)
    ground_material.set_shader_parameter("grass_roughness",grass_rough)
    ground_material.set_shader_parameter("asphalt_albedo",asphalt)
    for child in owner_world.ground_body.get_children():
        if child is MeshInstance3D:
            child.material_override = ground_material
            child.name = "V3.7 wet triplanar forest and rock world terrain"

func _render_environment() -> void:
    if owner_world == null or not owner_world.has_node("WorldEnvironment"):
        return
    var world_environment: WorldEnvironment = owner_world.get_node("WorldEnvironment")
    var setting: Environment = world_environment.environment
    if setting == null:
        return
    setting.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    setting.ssao_enabled = true
    setting.ssao_intensity = 1.05
    setting.ssao_radius = 2.9
    setting.volumetric_fog_enabled = true
    setting.volumetric_fog_density = 0.014
    setting.fog_enabled = true
    setting.fog_density = 0.0032
    setting.fog_light_color = Color("abbac0")
    setting.glow_enabled = true
    setting.glow_intensity = 0.14
    if owner_world.sky_light != null:
        owner_world.sky_light.directional_shadow_max_distance = 280.0
        owner_world.sky_light.shadow_enabled = true
    sky_preset_applied = true

func _cliff_pt(x: float, row: float, side: int) -> Vector3:
    var wiggle := sin(x*0.092+float(side)*2.7+row*5.0)*2.1
    wiggle += cos(x*0.29-row*8.2)*0.8
    var surface_z := 130.0 if side < 0 else 206.0
    var offset := (1.0-row)*(-2.9 if side < 0 else 2.9)
    var ledges := sin(row*19.5+x*0.081)*1.0+cos(row*38.0+x*0.16)*0.37
    return Vector3(x,-37.4+row*47.5,surface_z+offset+wiggle+ledges)

func _spawn_cliff_sides() -> void:
    var material := _rock_material()
    for side in [-1,1]:
        var st := SurfaceTool.new()
        st.begin(Mesh.PRIMITIVE_TRIANGLES)
        for ix in range(62):
            var x0 := 105.0+float(ix)*1.83
            var x1 := x0+1.83
            # No wall intersects the bridge's road corridor.
            if absf(0.5*(x0+x1)-175.0) < 11.0:
                continue
            for layer in range(28):
                var t0 := float(layer)/28.0
                var t1 := float(layer+1)/28.0
                var a := _cliff_pt(x0,t0,side)
                var b := _cliff_pt(x1,t0,side)
                var c := _cliff_pt(x0,t1,side)
                var d := _cliff_pt(x1,t1,side)
                var corners: Array = [a,c,b,b,c,d] if side < 0 else [a,b,c,b,d,c]
                for p in corners:
                    st.set_uv(Vector2(p.x*0.05,p.y*0.05))
                    st.add_vertex(p)
        st.generate_normals()
        var mesh: ArrayMesh = st.commit()
        var visual := MeshInstance3D.new()
        visual.name = "North stratified escarpment" if side < 0 else "South stratified escarpment"
        visual.mesh = mesh
        visual.material_override = material
        visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
        add_child(visual)
        cliff_count += 1

func _conifer_mesh() -> ArrayMesh:
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    for layer in range(4):
        var bottom := 0.3+float(layer)*1.65
        var peak := 3.1+float(layer)*1.4
        var width := 1.30-float(layer)*0.22
        for sector in range(14):
            var a := TAU*float(sector)/14.0
            var b := TAU*float(sector+1)/14.0
            var points := [Vector3(cos(a)*width,bottom,sin(a)*width),
                           Vector3(0,peak,0),
                           Vector3(cos(b)*width,bottom,sin(b)*width)]
            for p in points:
                st.set_uv(Vector2(p.x*0.24,p.y*0.27))
                st.add_vertex(p)
    st.generate_normals()
    return st.commit()

func _spawn_alpine_forest() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 133707131
    var foliage_mat := StandardMaterial3D.new()
    foliage_mat.albedo_color = Color("48664b")
    foliage_mat.roughness = 0.91
    foliage_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    var needles: ArrayMesh = _conifer_mesh()
    needles.surface_set_material(0,foliage_mat)
    var pine_multimesh := MultiMesh.new()
    pine_multimesh.transform_format = MultiMesh.TRANSFORM_3D
    pine_multimesh.use_colors = true
    pine_multimesh.mesh = needles
    pine_multimesh.instance_count = 490
    var trunk_multimesh := MultiMesh.new()
    trunk_multimesh.transform_format = MultiMesh.TRANSFORM_3D
    trunk_multimesh.mesh = CylinderMesh.new()
    var trunk_material := StandardMaterial3D.new()
    trunk_material.albedo_color = Color("574638")
    trunk_material.roughness = 0.95
    (trunk_multimesh.mesh as CylinderMesh).material = trunk_material
    trunk_multimesh.instance_count = 490
    for i in range(pine_multimesh.instance_count):
        var px := rng.randf_range(88.0,229.0)
        var pz := rng.randf_range(91.0,245.0)
        if absf(px-175.0)<13.0 and pz>108.0 and pz<228.0:
            pz = 90.0+float(i%15)*1.5
        if pz>142.0 and pz<200.0:
            pz = 123.0 if i%2==0 else 219.0
        var y := TERRAIN.height_at(px,pz)
        var height_scale := rng.randf_range(0.75,2.1)
        var pos := Vector3(px,y+0.2,pz)
        var basis := Basis(Vector3.UP,rng.randf_range(0,TAU)).scaled(Vector3(height_scale*0.66,height_scale,height_scale*0.66))
        pine_multimesh.set_instance_transform(i,Transform3D(basis,pos))
        pine_multimesh.set_instance_color(i,Color(rng.randf_range(0.81,1.0),rng.randf_range(0.82,1.0),rng.randf_range(0.82,0.98)))
        trunk_multimesh.set_instance_transform(i,Transform3D(Basis.from_scale(Vector3(0.24*height_scale,3.9*height_scale,0.24*height_scale)),pos+Vector3(0,2.0*height_scale,0)))
    var foliage := MultiMeshInstance3D.new()
    foliage.name = "490 instanced alpine evergreen crowns"
    foliage.multimesh = pine_multimesh
    foliage.visibility_range_end = 410.0
    add_child(foliage)
    var trunks := MultiMeshInstance3D.new()
    trunks.name = "490 pine trunks"
    trunks.multimesh = trunk_multimesh
    trunks.visibility_range_end = 410.0
    add_child(trunks)
    pine_count = 490

func _box(parent: Node3D, text: String, pos: Vector3, size: Vector3, color: Color, metallic: float = 0.0) -> void:
    var node := MeshInstance3D.new()
    node.name = text
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = pos
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = metallic
    mat.roughness = 0.48
    node.material_override = mat
    parent.add_child(node)

func _stage_emergency_vehicles() -> void:
    for id in range(3):
        var car := Node3D.new()
        car.name = "Rescue vehicle high detail silhouette %d" % id
        car.position = Vector3(153.0+float(id)*22.0,0.0,222.0+float(id%2)*4.0)
        car.rotation.y = PI*0.5 if id != 1 else -PI*0.5
        add_child(car)
        _box(car,"White-red rescue van body",Vector3(0,1.5,0),Vector3(2.45,2.4,5.3),Color("e1e2df"))
        _box(car,"Emergency stripe",Vector3(0,1.08,0),Vector3(2.48,0.48,5.34),Color("b32825"))
        _box(car,"Cab windshield",Vector3(0,2.05,-2.68),Vector3(2.18,0.83,0.09),Color("42575e"),0.25)
        _box(car,"Lightbar",Vector3(0,2.88,-1.55),Vector3(1.6,0.18,0.28),Color("30444f"))
        _box(car,"Blue emergency LED",Vector3(-0.51,2.98,-1.55),Vector3(0.43,0.18,0.3),Color("2e78ff"))
        _box(car,"Red emergency LED",Vector3(0.51,2.98,-1.55),Vector3(0.43,0.18,0.3),Color("ee3f3a"))
        for side in [-1.0,1.0]:
            for z in [-1.65,1.72]:
                var wheel := MeshInstance3D.new()
                wheel.name = "Tire and hub"
                var wheel_mesh := CylinderMesh.new()
                wheel_mesh.top_radius = 0.52
                wheel_mesh.bottom_radius = 0.52
                wheel_mesh.height = 0.27
                wheel.mesh = wheel_mesh
                wheel.position = Vector3(float(side)*1.28,0.52,z)
                wheel.rotation.z = PI*0.5
                car.add_child(wheel)
        response_vehicle_count += 1

func _stage_helicopter() -> void:
    var helicopter: Node3D = PRODUCTION.create_hero_instance("HELI_01")
    if helicopter == null:
        return
    helicopter.name = "Production helicopter | Alpine mountain rescue helicopter"
    helicopter.position = Vector3(198,28,172)
    helicopter.rotation.y = PI*0.3
    add_child(helicopter)
    rescue_helicopter = helicopter
    var line := MeshInstance3D.new()
    var cable := CylinderMesh.new()
    cable.height = 14.0
    cable.top_radius = 0.025
    cable.bottom_radius = 0.025
    line.mesh = cable
    line.position = Vector3(0,-9,0)
    var steel := StandardMaterial3D.new()
    steel.albedo_color = Color("454b4e")
    steel.metallic = 0.6
    line.material_override = steel
    helicopter.add_child(line)

func _stage_water_spray() -> void:
    for at in [Vector3(141,-36.0,161),Vector3(174,-36.0,175),Vector3(203,-36.0,158)]:
        var spray := CPUParticles3D.new()
        spray.name = "River waterfall spray mist"
        spray.position = at
        spray.amount = 110
        spray.lifetime = 2.4
        spray.emission_shape = CPUParticles3D.EMISSION_SHAPE_SPHERE
        spray.emission_sphere_radius = 1.7
        spray.direction = Vector3.UP
        spray.spread = 65.0
        spray.initial_velocity_min = 1.1
        spray.initial_velocity_max = 4.6
        spray.gravity = Vector3(0,-1.5,0)
        spray.color = Color(0.76,0.88,0.89,0.5)
        var mesh := SphereMesh.new()
        mesh.radius = 0.14
        mesh.height = 0.28
        spray.mesh = mesh
        add_child(spray)
        spray.emitting = true

func _process(delta: float) -> void:
    clock_timer += delta
    if rescue_helicopter != null:
        rescue_helicopter.position.y = 27.5+sin(float(Time.get_ticks_msec())*0.00045)*0.45
    if clock_timer < 0.45 or owner_world == null:
        return
    clock_timer = 0.0
    var rain: float = 0.85 if int(owner_world.world_clock.weather)==2 else (0.32 if int(owner_world.world_clock.weather)==1 else 0.0)
    if ground_material != null:
        ground_material.set_shader_parameter("rainfall",rain)
    if canyon_river_material != null:
        canyon_river_material.set_shader_parameter("rain_strength",rain)
