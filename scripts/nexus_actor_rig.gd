extends Node3D
class_name NexusActorRig
## Procedural articulated character used until licensed/skinned GLB characters are available.
## No claim of motion-captured AAA animation.
var arms: Array[Node3D] = []
var legs: Array[Node3D] = []
var clock: float = 0.0
var torso: Node3D
var head: Node3D
var stance: float = 0.0

func _material(tint: Color, roughness: float = 0.72) -> StandardMaterial3D:
    var surface := StandardMaterial3D.new()
    surface.albedo_color = tint
    surface.roughness = roughness
    return surface

func _mesh_part(parent: Node3D, label_text: String, shape: Mesh, position: Vector3, material: Material) -> MeshInstance3D:
    var part := MeshInstance3D.new()
    part.name = label_text
    part.mesh = shape
    part.material_override = material
    part.position = position
    parent.add_child(part)
    return part

func _capsule(radius: float, height: float) -> CapsuleMesh:
    var shape := CapsuleMesh.new()
    shape.radius = radius
    shape.height = height
    return shape

func _ready() -> void:
    name = "Procedural Character Rig"
    var coat := _material(Color("273f51"))
    var leather := _material(Color("202a2e"))
    var skin := _material(Color("c58b68"))
    var vest := _material(Color("d68c46"))
    torso = Node3D.new()
    torso.position.y = 1.16
    add_child(torso)
    _mesh_part(torso,"Oberkoerper",_capsule(0.32,0.87),Vector3.ZERO,coat)
    var armor := BoxMesh.new()
    armor.size = Vector3(0.56,0.49,0.13)
    _mesh_part(torso,"Einsatzweste",armor,Vector3(0,0.05,-0.29),vest)
    head = Node3D.new()
    head.position = Vector3(0,1.74,0)
    add_child(head)
    var skull := SphereMesh.new()
    skull.radius = 0.245
    skull.height = 0.49
    _mesh_part(head,"Kopf",skull,Vector3.ZERO,skin)
    var helmet := SphereMesh.new()
    helmet.radius = 0.26
    helmet.height = 0.19
    _mesh_part(head,"Helm",helmet,Vector3(0,0.16,0),leather)
    for side in [-1.0,1.0]:
        var arm := Node3D.new()
        arm.position = Vector3(0.39*side,1.47,0)
        arm.name = "Arm rechts" if side>0 else "Arm links"
        add_child(arm)
        _mesh_part(arm,"Aermel",_capsule(0.125,0.64),Vector3(0,-0.29,0),coat)
        _mesh_part(arm,"Hand",_capsule(0.108,0.2),Vector3(0,-0.65,0),skin)
        arms.append(arm)
        var leg := Node3D.new()
        leg.position = Vector3(0.18*side,0.84,0)
        leg.name = "Bein rechts" if side>0 else "Bein links"
        add_child(leg)
        _mesh_part(leg,"Hose",_capsule(0.155,0.71),Vector3(0,-0.35,0),leather)
        var boot := BoxMesh.new()
        boot.size = Vector3(0.28,0.17,0.42)
        _mesh_part(leg,"Stiefel",boot,Vector3(0,-0.73,-0.10),leather)
        legs.append(leg)

func animate_motion(delta: float, ground_speed: float, running: bool) -> void:
    var walking: float = clampf(ground_speed/8.0,0.0,1.0)
    clock += delta*(3.8+ground_speed*0.82)
    var target_stance: float = walking*(0.66 if running else 0.42)
    stance = move_toward(stance,target_stance,delta*3.8)
    for index in range(2):
        var sign_value: float = 1.0 if index == 0 else -1.0
        legs[index].rotation.x = sin(clock)*stance*sign_value
        arms[index].rotation.x = -sin(clock)*stance*sign_value*0.7
    torso.rotation.z = sin(clock*0.5)*stance*0.045
    torso.position.y = 1.16+absf(sin(clock))*stance*0.035
    head.rotation.z = -torso.rotation.z*0.4
