extends Node3D
class_name NexusAdlerklammEnvironmentV35
## Visual-only art-direction pass over the real V2.6 canyon terrain.
## Rock PBR uses the checked-in production texture set, not a generated preview.
const PRODUCTION = preload("res://scripts/nexus_production_assets.gd")
const TERRAIN = preload("res://scripts/nexus_terrain_v26.gd")
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

func _build_rock_banks() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 202611011635
    var rock_mesh := SphereMesh.new()
    rock_mesh.radial_segments = 14
    rock_mesh.rings = 8
    rock_mesh.material = _rock_material()
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
    plane.subdivide_width = 28
    plane.subdivide_depth = 8
    river.mesh = plane
    river.position = Vector3(163,-36.8,168)
    var material := ShaderMaterial.new()
    var shader := Shader.new()
    shader.code = """
shader_type spatial;
render_mode cull_disabled, depth_draw_opaque;
uniform vec4 deep_water : source_color = vec4(0.065,0.19,0.23,1.0);
uniform vec4 foam : source_color = vec4(0.71,0.83,0.85,1.0);
void vertex() {
    VERTEX.y += 0.12*sin(VERTEX.x*1.2+TIME*2.0)+0.07*cos(VERTEX.z*2.4-TIME*1.6);
}
void fragment() {
    float wave = sin(UV.x*91.0-TIME*4.5)*sin(UV.y*23.0+TIME*1.5);
    float streak = smoothstep(0.64,0.93,0.5+0.5*wave);
    ALBEDO = mix(deep_water.rgb,foam.rgb,streak*0.37);
    METALLIC = 0.1;
    ROUGHNESS = 0.18+0.22*(1.0-streak);
}
"""
    material.shader = shader
    river.material_override = material
    add_child(river)
