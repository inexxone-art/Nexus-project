extends Node3D
class_name NexusShipWalkthrough
## Stationary, traversable spaceship interior prototype.
## Cockpit controls and upgrades are informative, not simulated orbital flight.
signal boarded()
const DOCK := Vector3(72.0,0.0,84.0)
const BOARDING := DOCK + Vector3(0,0,7.5)
const EXIT_POINT := DOCK + Vector3(0,0,11.0)
const CONSOLE := DOCK + Vector3(0,0,-3.0)
const RADIUS := 3.3
var crew_aboard: bool = false
var modules: Dictionary = {}
var airlock_open: bool = false
var door: Node3D
var module_screen: Label3D

func _ready() -> void:
    name = "NEXUS | Begehbares Raumschiff - Mockup"
    position = DOCK
    _build_deck()

func _mat(color: Color, metallic: float = 0.0, emissive: bool = false) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = 0.39 if metallic > 0.0 else 0.74
    m.metallic = metallic
    if emissive:
        m.emission_enabled = true
        m.emission = color
        m.emission_energy_multiplier = 1.65
    return m

func _block(parent: Node3D, title: String, where: Vector3, dimensions: Vector3, color: Material, solid: bool = false) -> Node3D:
    var item: Node3D = StaticBody3D.new() if solid else Node3D.new()
    item.name = title
    item.position = where
    parent.add_child(item)
    var mesh := MeshInstance3D.new()
    var cube := BoxMesh.new()
    cube.size = dimensions
    mesh.mesh = cube
    mesh.material_override = color
    item.add_child(mesh)
    if solid:
        var collider := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = dimensions
        collider.shape = shape
        item.add_child(collider)
    return item

func _build_deck() -> void:
    var steel := _mat(Color("586879"),0.72)
    var floor_mat := _mat(Color("a5b3b7"),0.22)
    var window := _mat(Color("326985"),0.18)
    var signal_mat := _mat(Color("4fe4d7"),0.02,true)
    _block(self,"Rumpf Unterdeck",Vector3(0,0.52,0),Vector3(6,0.42,15.0),steel,true)
    _block(self,"Begehbarer Kabinenboden",Vector3(0,0.77,0),Vector3(5.5,0.15,14.4),floor_mat,true)
    _block(self,"Rumpf links",Vector3(-2.84,2.45,0),Vector3(0.26,3.45,15),steel,true)
    _block(self,"Rumpf rechts",Vector3(2.84,2.45,0),Vector3(0.26,3.45,15),steel,true)
    _block(self,"Rumpf Decke",Vector3(0,4.21,0),Vector3(6.2,0.3,15.3),steel,true)
    _block(self,"Cockpit Trennwand",Vector3(0,2.4,-5.5),Vector3(6,3.6,0.22),steel)
    _block(self,"Frontscheibe",Vector3(0,2.9,-7.6),Vector3(4.6,1.6,0.1),window)
    _block(self,"Linke Sichtscheibe",Vector3(-2.67,2.85,-4.5),Vector3(0.09,1.35,2.3),window)
    _block(self,"Rechte Sichtscheibe",Vector3(2.67,2.85,-4.5),Vector3(0.09,1.35,2.3),window)
    for i in range(3):
        var z := float(i)*2.8-2.1
        for side in [-1.0,1.0]:
            _block(self,"Sitz-%d-%d"%[i,int(side)],Vector3(side*1.9,1.35,z),Vector3(0.82,0.95,0.85),floor_mat)
            _block(self,"Konsole-%d-%d"%[i,int(side)],Vector3(side*2.18,1.95,z-0.5),Vector3(0.8,0.42,0.12),signal_mat)
    _block(self,"Pilotenpult",Vector3(0,1.45,-5.9),Vector3(3,0.75,1.2),steel)
    _block(self,"Navigation",Vector3(0,1.98,-6.4),Vector3(2.7,0.25,0.24),signal_mat)
    _block(self,"Schiffsmedizin",Vector3(-1.5,1.45,3.85),Vector3(1.65,0.32,1.15),floor_mat)
    door = _block(self,"Schleusenklappe",Vector3(0,2.2,7.48),Vector3(2.1,3.2,0.16),window)
    for side in [-1.0,1.0]:
        _block(self,"Landestuetze",Vector3(side*2.1,0.26,-4.5),Vector3(0.42,0.55,1.25),steel,true)
        _block(self,"Hecktriebwerk",Vector3(side*1.7,1.8,7.8),Vector3(1.0,1.1,0.65),signal_mat)
    var label := Label3D.new()
    label.text = "NEXUS EXPLORER | E: LUFTSCHLEUSE"
    label.position = Vector3(0,3.55,8.0)
    label.font_size = 32
    label.pixel_size = 0.01
    label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    add_child(label)
    module_screen = Label3D.new()
    module_screen.text = "SCHIFFSMODULE: GRUNDAUSSTATTUNG"
    module_screen.position = Vector3(0,3.2,-4.35)
    module_screen.font_size = 29
    module_screen.pixel_size = 0.008
    module_screen.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    add_child(module_screen)

func _close(a: Vector3,b: Vector3) -> bool:
    return Vector2(a.x,a.z).distance_to(Vector2(b.x,b.z)) <= RADIUS

func try_interact(actor: Node3D, module_record: Dictionary) -> Dictionary:
    if actor == null:
        return {"handled":false}
    if not crew_aboard and _close(actor.global_position, BOARDING):
        crew_aboard = true
        airlock_open = true
        actor.global_position = DOCK + Vector3(0,1.30,5.1)
        _refresh(module_record)
        boarded.emit()
        return {"handled":true,"message":"NEXUS EXPLORER: Du bist an Bord. Cockpit und Kabine sind begehbar"}
    if crew_aboard and _close(actor.global_position,DOCK+Vector3(0,0,6.1)):
        crew_aboard = false
        airlock_open = false
        actor.global_position = EXIT_POINT + Vector3(0,1.0,0)
        return {"handled":true,"message":"Luftschleuse verlassen. Zurueck auf Terra"}
    if crew_aboard and _close(actor.global_position,CONSOLE):
        _refresh(module_record)
        return {"handled":true,"message":module_screen.text}
    return {"handled":false}

func _refresh(record: Dictionary) -> void:
    modules = record.duplicate(true)
    var ready: Array[String] = []
    for key in ["scanner","cargo","medbay"]:
        if bool(modules.get(key,false)):
            ready.append(key.to_upper())
    module_screen.text = "SCHIFFSMODULE: "+(", ".join(ready) if not ready.is_empty() else "GRUNDAUSSTATTUNG")

func _process(delta: float) -> void:
    if door != null:
        door.position.y = move_toward(door.position.y,4.15 if airlock_open else 2.2,delta*4.5)

func get_data() -> Dictionary:
    return {"crew_aboard":crew_aboard}

func restore_data(data: Dictionary) -> void:
    # We deliberately reopen outside after loading; the player position is restored separately.
    crew_aboard = false
    airlock_open = false
