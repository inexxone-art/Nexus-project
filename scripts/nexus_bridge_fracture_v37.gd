extends Node3D
class_name NexusBridgeFractureArtV37
## Exposed structural mesh and bent reinforcement; all fragments stay attached
## to the existing physical RigidBody segment to avoid collision/physics regressions.
var reinforcement_count: int = 0
var fracture_meshes: int = 0
var section_length := 6.7

func setup(segment_length: float,segment_index: int) -> void:
    section_length = segment_length
    name = "Span %02d | fractured concrete with reinforcement" % segment_index
    _fracture_edge(-1)
    _fracture_edge(1)
    _rebar(segment_index)

func _fracture_edge(side: int) -> void:
    var mesh := SurfaceTool.new()
    mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
    var z := float(side)*section_length*0.5
    for i in range(22):
        var x0 := -4.95+float(i)*9.9/22.0
        var x1 := -4.95+float(i+1)*9.9/22.0
        var jag0 := 0.19*sin(x0*5.1+float(side)*1.1)
        var jag1 := 0.19*sin(x1*5.1+float(side)*1.1)
        var surface := [Vector3(x0,0.05,z+jag0),Vector3(x0,-0.53,z+float(side)*0.21),
                        Vector3(x1,0.02,z+jag1),Vector3(x1,-0.56,z+float(side)*0.14)]
        var verts := [surface[0],surface[1],surface[2],surface[2],surface[1],surface[3]]
        for p in verts:
            mesh.set_uv(Vector2(p.x*0.2,p.y*0.2))
            mesh.add_vertex(p)
    mesh.generate_normals()
    var rock_mat := StandardMaterial3D.new()
    rock_mat.albedo_color = Color("9d9a91")
    rock_mat.roughness = 0.94
    var visual := MeshInstance3D.new()
    visual.name = "Uneven exposed aggregate fracture face"
    visual.mesh = mesh.commit()
    visual.material_override = rock_mat
    visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON
    add_child(visual)
    fracture_meshes += 1

func _rebar(index: int) -> void:
    var metal := StandardMaterial3D.new()
    metal.albedo_color = Color("675b4d")
    metal.metallic = 0.58
    metal.roughness = 0.79
    for side in [-1.0,1.0]:
        for i in range(9):
            var rod := MeshInstance3D.new()
            rod.name = "Torn steel reinforcement rod"
            var cylinder := CylinderMesh.new()
            cylinder.top_radius = 0.055
            cylinder.bottom_radius = 0.055
            cylinder.height = 0.45+0.27*float(i%3)
            cylinder.radial_segments = 7
            rod.mesh = cylinder
            rod.material_override = metal
            rod.position = Vector3(-4.2+float(i)*1.05,-0.22,float(side)*(section_length*0.5+0.13))
            rod.rotation.x = float(side)*(PI*0.46)
            rod.rotation.z = 0.30*sin(float(i*7+index))
            add_child(rod)
            reinforcement_count += 1
