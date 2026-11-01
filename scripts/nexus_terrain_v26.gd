extends RefCounted
class_name NexusTerrainV26
## V2.6: continuous, physically collidable Alpine heightfield with a real cut gorge.
## Existing level remains y=0; distant northeast ravine is entirely outside mission areas.
## Procedural authored fallback, NOT scanned AAA photogrammetry.

const SIZE: float = 460.0
const STEP: float = 4.0
const GORGE_DEPTH: float = 38.0
const CANYON_X: float = 175.0
const CANYON_Z: float = 168.0

static func gorge_mask(x: float, z: float) -> float:
    # Long E-W valley, N-S cross section. Fade at both extremities.
    var length_mask: float = smoothstep(80.0,104.0,x) * (1.0-smoothstep(214.0,231.0,x))
    var bank_mask: float = smoothstep(133.0,154.0,z) * (1.0-smoothstep(183.0,205.0,z))
    return length_mask*bank_mask

static func height_at(x: float, z: float) -> float:
    var mask: float = gorge_mask(x,z)
    var strata: float = (sin(x*0.125+z*0.035)*0.8 + sin(x*0.37-z*0.19)*0.37)*mask
    return -GORGE_DEPTH*mask+strata

static func biome_color(x: float, z: float, y: float, slope: float) -> Color:
    var noise: float = 0.91+0.06*sin(x*0.31+z*0.13)+0.035*sin(z*1.19-x*0.73)
    var grass := Color("667d59")
    var gravel := Color("a29a89")
    var cliff := Color("777975")
    var sand := Color("ad9572")
    var mud := Color("554a3c")
    var volcanic := Color("3e3836")
    var color: Color = grass.lerp(gravel,clampf(slope*0.35,0.0,0.42))
    color = color.lerp(cliff,clampf(slope*0.58 + (1.0-smoothstep(-17.0,-4.0,y)),0.0,0.96))
    var dry: float = (1.0-smoothstep(22.0,37.0,Vector2(x-26.0,z+170.0).length()))*0.93
    var mire: float = (1.0-smoothstep(19.0,33.0,Vector2(x+75.0,z+160.0).length()))*0.86
    var lava: float = (1.0-smoothstep(24.0,42.0,Vector2(x-167.0,z+153.0).length()))*0.95
    color = color.lerp(sand,dry).lerp(mud,mire).lerp(volcanic,lava)
    return Color(clampf(color.r*noise,0.0,1.0),clampf(color.g*noise,0.0,1.0),clampf(color.b*noise,0.0,1.0))

static func create_mesh() -> ArrayMesh:
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    var n: int = int(SIZE/STEP)
    for ix in range(n):
        var x: float = -SIZE*0.5 + ix*STEP
        for iz in range(n):
            var z: float = -SIZE*0.5 + iz*STEP
            var p00 := Vector3(x,height_at(x,z),z)
            var p01 := Vector3(x,height_at(x,z+STEP),z+STEP)
            var p10 := Vector3(x+STEP,height_at(x+STEP,z),z)
            var p11 := Vector3(x+STEP,height_at(x+STEP,z+STEP),z+STEP)
            _add_triangle(st,p00,p01,p10)
            _add_triangle(st,p01,p11,p10)
    st.generate_normals()
    return st.commit()

static func _add_triangle(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3) -> void:
    for p in [a,b,c]:
        var steep: float = Vector2(height_at(p.x+STEP,p.z)-height_at(p.x-STEP,p.z),height_at(p.x,p.z+STEP)-height_at(p.x,p.z-STEP)).length()/(STEP*2.0)
        st.set_color(biome_color(p.x,p.z,p.y,steep))
        st.set_uv(Vector2(p.x,p.z)*0.14)
        st.add_vertex(p)

static func make_material() -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.vertex_color_use_as_albedo = true
    material.roughness = 0.94
    material.metallic = 0.0
    material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
    return material

static func populate_ground(ground_body: StaticBody3D) -> void:
    var generated: ArrayMesh = create_mesh()
    var visual := MeshInstance3D.new()
    visual.name = "V2.6 continuous terrain | roads, gullies, river valley and biome colors"
    visual.mesh = generated
    visual.material_override = make_material()
    visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    ground_body.add_child(visual)
    var collider := CollisionShape3D.new()
    collider.name = "V2.6 true ground collisions, including deep canyon"
    collider.shape = generated.create_trimesh_shape()
    ground_body.add_child(collider)
