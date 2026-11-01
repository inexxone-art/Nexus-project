extends Node3D
class_name NexusAdlerklammEnvironmentV35
## Visual-only art-direction pass over the real V2.6 canyon terrain.
## Rock PBR uses the checked-in production texture set, not a generated preview.
const PRODUCTION = preload("res://scripts/nexus_production_assets.gd")
const TERRAIN = preload("res://scripts/nexus_terrain_v26.gd")
const RIVER_V37 = preload("res://shaders/nexus_river_v37.gdshader")
var rock_count: int = 0
var grass_count: int = 0
var river: MeshInstance3D

func _ready() -> void:
    name = "Adlerklamm | PBR canyon boulders, river and roadside detail"
    _build_rock_banks()
    _build_river()

func _rock_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("c3c4bc")
    material.roughness = 0.91
    material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
    material.uv1_triplanar = true
    material.uv1_scale = Vector3(0.15,0.15,0.15)
    var albedo := PRODUCTION.surface_texture("rock","albedo")
    if albedo != null:
        material.albedo_texture = albedo
    var normal := PRODUCTION.surface_texture("rock","normal")
    if normal != null:
        material.normal_enabled = true
        material.normal_texture = normal
        material.normal_scale = 0.68
    var rough := PRODUCTION.surface_texture("rock","roughness")
    if rough != null:
        material.roughness_texture = rough
        material.roughness_texture_channel = BaseMaterial3D.TEXTURE_CHANNEL_RED
    return material

func _make_irregular_rock() -> ArrayMesh:
    # Irregular angular rock mesh, replacing the smooth repeated spheres from alpha.
    # Angular strata and asymmetric ridges are tessellated, normals generated for PBR.
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    const SIDES: int = 23
    const BANDS: int = 12
    for row in range(BANDS):
        for col in range(SIDES):
            var t0 := PI*float(row)/float(BANDS)
            var t1 := PI*float(row+1)/float(BANDS)
            var p0 := TAU*float(col)/float(SIDES)
            var p1 := TAU*float(col+1)/float(SIDES)
            var a := _rock_vertex(t0,p0)
            var b := _rock_vertex(t1,p0)
            var c := _rock_vertex(t0,p1)
            var d := _rock_vertex(t1,p1)
            surface.set_uv(Vector2(float(col)/float(SIDES),float(row)/float(BANDS)))
            surface.add_vertex(a)
            surface.set_uv(Vector2(float(col)/float(SIDES),float(row+1)/float(BANDS)))
            surface.add_vertex(b)
            surface.set_uv(Vector2(float(col+1)/float(SIDES),float(row)/float(BANDS)))
            surface.add_vertex(c)
            surface.set_uv(Vector2(float(col+1)/float(SIDES),float(row)/float(BANDS)))
            surface.add_vertex(c)
            surface.set_uv(Vector2(float(col)/float(SIDES),float(row+1)/float(BANDS)))
            surface.add_vertex(b)
            surface.set_uv(Vector2(float(col+1)/float(SIDES),float(row+1)/float(BANDS)))
            surface.add_vertex(d)
    surface.generate_normals()
    return surface.commit()

func _rock_vertex(latitude: float,longitude: float) -> Vector3:
    var stratum := 1.0+0.17*sin(longitude*7.0+latitude*2.3)+0.095*cos(longitude*11.0-latitude*9.0)
    var ridge := 1.0+0.13*sin(latitude*14.0+longitude*4.0)
    var r := stratum*ridge
    return Vector3(sin(latitude)*cos(longitude)*r,cos(latitude)*r*0.85,sin(latitude)*sin(longitude)*r)

func _build_rock_banks() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 202611011635
    var rock_mesh: ArrayMesh = _make_irregular_rock()
    rock_mesh.surface_set_material(0,_rock_material())
    var multimesh := MultiMesh.new()
    multimesh.transform_format = MultiMesh.TRANSFORM_3D
    multimesh.use_colors = true
    multimesh.mesh = rock_mesh
    multimesh.instance_count = 130
    for i in range(multimesh.instance_count):
        var x := rng.randf_range(108.0,218.0)
        var bank := 1.0 if i%2 == 0 else -1.0
        var z := 168.0+bank*rng.randf_range(15.0,37.0)
        var y: float = TERRAIN.height_at(x,z)
        var radius := rng.randf_range(1.2,5.5)
        var position := Vector3(x,y+radius*0.15,z)
        var transform := Transform3D(Basis.from_euler(Vector3(rng.randf_range(-0.5,0.5),rng.randf_range(-PI,PI),rng.randf_range(-0.7,0.7))).scaled(Vector3(radius,radius*rng.randf_range(0.5,1.4),radius*rng.randf_range(0.6,1.5))),position)
        multimesh.set_instance_transform(i,transform)
        multimesh.set_instance_color(i,Color(rng.randf_range(0.79,1.0),rng.randf_range(0.81,1.0),rng.randf_range(0.80,0.97)))
    var rocks := MultiMeshInstance3D.new()
    rocks.name = "130 instanced triplanar photo-rock boulders"
    rocks.multimesh = multimesh
    rocks.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    add_child(rocks)
    rock_count = multimesh.instance_count

func _build_river() -> void:
    river = MeshInstance3D.new()
    river.name = "Adlerklamm river channel | animated surface"
    var plane := PlaneMesh.new()
    plane.size = Vector2(104,15)
    plane.subdivide_width = 92
    plane.subdivide_depth = 18
    river.mesh = plane
    river.position = Vector3(163,-36.8,168)
    var material := ShaderMaterial.new()
    material.shader = RIVER_V37
    river.material_override = material
    add_child(river)
