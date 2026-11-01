extends Node3D
class_name NexusIndustrySkylineV34
## Procedural architecture blockout behind the Adlerklamm approach.
## Facades, setbacks, glazing and roof plant add silhouette detail; authored
## high-poly buildings and explorable interiors are NOT supplied by this file.

var tower_count: int = 0
var window_count: int = 0

func _ready() -> void:
    name = "Industrial skyline beyond Adlerklamm | modular facade prototype"
    var concrete := _mat(Color("777e83"),0.06,0.86)
    var steel := _mat(Color("3e4951"),0.68,0.35)
    var glass := _mat(Color("60818b"),0.32,0.16)
    for i in range(6):
        var x := -76.0 + float(i%3)*25.0
        var z := -86.0 + float(i/3)*26.0
        var h := 55.0 + float((i*17)%49)
        _tower(Vector3(x,0,z),Vector3(15.0+float(i%2)*4.0,h,13.0+float(i%3)*2.0),concrete,steel,glass)
    _crane(Vector3(-6.0,0,-64.0),steel)
    _crane(Vector3(-61.0,0,-34.0),steel)
    for i in range(3):
        _box(self,"Industrial exhaust stack",Vector3(-91.0+float(i)*17.0,19.0,-109.0),Vector3(3.2,38.0,3.2),steel)

func _mat(color: Color, metallic: float, roughness: float) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = metallic
    m.roughness = roughness
    return m

func _box(parent: Node3D, tag: String, pos: Vector3, size: Vector3, material: Material) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = tag
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.material_override = material
    node.position = pos
    parent.add_child(node)
    return node

func _tower(base: Vector3, size: Vector3, wall: Material, frame: Material, glazing: Material) -> void:
    tower_count += 1
    var part := Node3D.new()
    part.name = "Highrise with glazed curtain-wall sections %02d" % tower_count
    part.position = base
    add_child(part)
    _box(part,"Recessed tower structural core",Vector3(0,size.y*0.5,0),size,wall)
    _box(part,"Deep setback podium",Vector3(0,4.0,0),Vector3(size.x+5.0,8.0,size.z+5.0),frame)
    _box(part,"Mechanical crown",Vector3(0,size.y+2.0,0),Vector3(size.x-2.0,4.0,size.z-2.0),frame)
    _box(part,"Roof service block",Vector3(-2.0,size.y+5.4,0),Vector3(5.0,3.0,5.0),wall)
    var levels := int(size.y/4.0)
    var transforms: Array[Transform3D] = []
    for level in range(2,levels):
        var y := float(level)*3.9+1.8
        for col in range(4):
            var fraction := (float(col)+0.5)/4.0-0.5
            for sign in [-1.0,1.0]:
                transforms.append(Transform3D(Basis.from_scale(Vector3(size.x*0.19,2.65,0.08)),Vector3(fraction*size.x,y,float(sign)*(size.z*0.5+0.06))))
                transforms.append(Transform3D(Basis.from_scale(Vector3(0.08,2.65,size.z*0.19)),Vector3(float(sign)*(size.x*0.5+0.06),y,fraction*size.z)))
        if level % 4 == 0:
            _box(part,"Concrete horizontal spandrel",Vector3(0,y-1.55,size.z*0.5+0.12),Vector3(size.x+0.5,0.22,0.35),frame)
    var pane := BoxMesh.new()
    pane.size = Vector3.ONE
    pane.material = glazing
    var multi := MultiMesh.new()
    multi.transform_format = MultiMesh.TRANSFORM_3D
    multi.mesh = pane
    multi.instance_count = transforms.size()
    for idx in range(transforms.size()):
        multi.set_instance_transform(idx,transforms[idx])
    var windows := MultiMeshInstance3D.new()
    windows.name = "Curtain wall glazing (%d instanced panes)" % transforms.size()
    windows.multimesh = multi
    windows.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    part.add_child(windows)
    window_count += transforms.size()
    for side in [-1.0,1.0]:
        _box(part,"Vertical steel corner mullion",Vector3(float(side)*(size.x*0.5+0.19),size.y*0.5,size.z*0.5+0.2),Vector3(0.35,size.y,0.38),frame)

func _crane(pos: Vector3, mat: Material) -> void:
    var crane := Node3D.new()
    crane.name = "Construction crane | industrial skyline"
    crane.position = pos
    add_child(crane)
    _box(crane,"Crane steel mast",Vector3(0,20,0),Vector3(1.3,40,1.3),mat)
    _box(crane,"Crane long jib",Vector3(11,39.5,0),Vector3(29,0.85,0.95),mat)
    _box(crane,"Crane counter-jib",Vector3(-9,39.5,0),Vector3(17,1.0,0.95),mat)
    _box(crane,"Crane suspended hook",Vector3(20,30,0),Vector3(0.15,18,0.16),mat)
