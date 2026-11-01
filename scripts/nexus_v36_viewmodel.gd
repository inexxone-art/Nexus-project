extends Node3D
class_name NexusV36Viewmodel
## Procedural FPS placeholder equipment: silhouettes, not imported AAA assets.
## Attached to the existing real first-person player camera.
const BLACK := Color("292e31")
const STEEL := Color("495357")
const RUBBER := Color("1c2225")
const MEDICAL := Color("e6e9e4")
const RED := Color("bf3336")
var groups: Array[Node3D] = []
var equipped: int = 0
var total_time := 0.0

func _ready() -> void:
    name = "V3.6 first person equipment viewmodel"
    position = Vector3(0.34,-0.36,-0.62)
    _build_rifle()
    _build_pistol()
    _build_medkit()
    _build_tool()
    equip(0)

func _material(tint: Color,metallic: float = 0.0,rough: float = 0.7) -> StandardMaterial3D:
    var result := StandardMaterial3D.new()
    result.albedo_color = tint
    result.metallic = metallic
    result.roughness = rough
    return result

func _block(parent: Node3D, label: String, at: Vector3, extents: Vector3, mat: Material,rotation_value: Vector3 = Vector3.ZERO) -> void:
    var mesh := BoxMesh.new()
    mesh.size = extents
    var item := MeshInstance3D.new()
    item.name = label
    item.mesh = mesh
    item.position = at
    item.rotation = rotation_value
    item.material_override = mat
    item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    parent.add_child(item)

func _cylinder(parent: Node3D, label: String, at: Vector3, radius: float,length_value: float,mat: Material,axis: Vector3) -> void:
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = length_value
    mesh.radial_segments = 12
    var item := MeshInstance3D.new()
    item.name = label
    item.mesh = mesh
    item.position = at
    item.rotation = axis
    item.material_override = mat
    item.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    parent.add_child(item)

func _new_group(label: String) -> Node3D:
    var holder := Node3D.new()
    holder.name = label
    add_child(holder)
    groups.append(holder)
    return holder

func _build_rifle() -> void:
    var g := _new_group("Rifle: receiver, handguard, rails, optic and magazine")
    var paint := _material(STEEL,0.72,0.42)
    var dark := _material(BLACK,0.48,0.55)
    var rubber := _material(RUBBER,0.1,0.91)
    _block(g,"Stamped receiver",Vector3(0,-0.04,-0.18),Vector3(0.21,0.17,0.59),paint)
    _block(g,"Long handguard",Vector3(0,-0.012,-0.56),Vector3(0.18,0.15,0.43),dark)
    _block(g,"Picatinny top rail",Vector3(0,0.105,-0.38),Vector3(0.075,0.036,0.76),dark)
    _cylinder(g,"Rifled barrel",Vector3(0,0.005,-0.93),0.028,0.58,dark,Vector3(PI*0.5,0,0))
    _cylinder(g,"Muzzle brake",Vector3(0,0.005,-1.19),0.05,0.14,paint,Vector3(PI*0.5,0,0))
    _block(g,"Charging handle",Vector3(0.12,0.08,-0.1),Vector3(0.11,0.035,0.07),dark)
    _block(g,"Optic mounting base",Vector3(0,0.14,-0.15),Vector3(0.12,0.085,0.25),paint)
    _block(g,"Holographic optical window",Vector3(0,0.22,-0.2),Vector3(0.13,0.13,0.055),rubber)
    _block(g,"Magazine",Vector3(0,-0.23,-0.28),Vector3(0.12,0.34,0.23),dark,Vector3(-0.2,0,0))
    _block(g,"Pistol grip",Vector3(0,-0.205,0.06),Vector3(0.125,0.35,0.17),rubber,Vector3(0.28,0,0))
    _block(g,"Rear stock",Vector3(0,-0.04,0.27),Vector3(0.20,0.15,0.31),dark)

func _build_pistol() -> void:
    var g := _new_group("Pistol: slide and grip")
    var dark := _material(BLACK,0.63,0.48)
    var rubber := _material(RUBBER,0.02,0.9)
    _block(g,"Machined steel slide",Vector3(0,0.07,-0.36),Vector3(0.16,0.15,0.45),dark)
    _block(g,"Pistol frame",Vector3(0,-0.03,-0.31),Vector3(0.15,0.09,0.30),dark)
    _block(g,"Handgrip",Vector3(0,-0.21,-0.15),Vector3(0.14,0.37,0.17),rubber,Vector3(0.26,0,0))
    _cylinder(g,"Muzzle",Vector3(0,0.08,-0.59),0.03,0.12,dark,Vector3(PI*0.5,0,0))
    g.position = Vector3(0.04,-0.06,0.06)

func _build_medkit() -> void:
    var g := _new_group("Red cross emergency medical pack")
    var white := _material(MEDICAL,0.02,0.78)
    var red := _material(RED,0.0,0.67)
    _block(g,"Medical case",Vector3(0,-0.13,-0.30),Vector3(0.42,0.37,0.2),white)
    _block(g,"Red cross vertical",Vector3(0,-0.12,-0.41),Vector3(0.085,0.23,0.018),red)
    _block(g,"Red cross horizontal",Vector3(0,-0.12,-0.41),Vector3(0.23,0.085,0.02),red)

func _build_tool() -> void:
    var g := _new_group("Construction wrench")
    var steel := _material(STEEL,0.84,0.39)
    _block(g,"Long adjustable steel shaft",Vector3(0,-0.18,-0.34),Vector3(0.09,0.13,0.67),steel,Vector3(-0.30,0,0))
    _block(g,"Wrench head left",Vector3(-0.10,-0.04,-0.70),Vector3(0.11,0.15,0.22),steel)
    _block(g,"Wrench head right",Vector3(0.11,-0.04,-0.70),Vector3(0.11,0.15,0.22),steel)

func equip(index: int) -> void:
    equipped = clampi(index,0,3)
    for i in range(groups.size()):
        groups[i].visible = i == equipped

func _process(delta: float) -> void:
    total_time += delta
    rotation.z = sin(total_time*1.6)*0.012
    if get_parent() is Camera3D:
        var player := get_parent().get_parent()
        if player is NexusPlayer:
            visible = player.first_person and player.active
