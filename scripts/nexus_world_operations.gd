extends Node3D
class_name NexusWorldOperations
## Repeatable contracts across the alpine map. Persistent state and deterministic sequence.
const CONTRACTS = [
    {"name":"Bergrettung: Notruf aus dem Canyon", "place":Vector3(77,0,75),"category":"Rettung","payment":425},
    {"name":"Sektor 31: Verschluesselte Nachricht sichern", "place":Vector3(114,0,84),"category":"Ermittlung","payment":520},
    {"name":"Stadt: Evakuierung eines Wohnblocks", "place":Vector3(-58,0,86),"category":"Einsatz","payment":480},
    {"name":"Militaer: Versorgungskonvoi finden", "place":Vector3(-101,0,-104),"category":"Konflikt","payment":650},
    {"name":"Wald: Nach Waldbrand aufraeumen", "place":Vector3(-22,0,-47),"category":"Natur","payment":390},
    {"name":"Raumhafen: NEXUS-Signal kalibrieren", "place":Vector3(55,0,66),"category":"Forschung","payment":580},
]
var index: int = 0
var completed: int = 0
var consequences: Array[String] = []
var waypoint: Node3D

func _ready() -> void:
    name = "NEXUS OPS // Wiederkehrende Auftraege"
    waypoint = Node3D.new()
    add_child(waypoint)
    var signal_mesh = MeshInstance3D.new()
    var mesh = CylinderMesh.new()
    mesh.bottom_radius = 0.16
    mesh.top_radius = 0.025
    mesh.height = 4.5
    signal_mesh.mesh = mesh
    signal_mesh.position.y = 2.4
    var m = StandardMaterial3D.new()
    m.albedo_color = Color("ffbf60")
    m.emission_enabled = true
    m.emission = Color("ffc46b")
    m.emission_energy_multiplier = 1.9
    signal_mesh.material_override = m
    waypoint.add_child(signal_mesh)
    _update_marker()

func _update_marker() -> void:
    var item: Dictionary = CONTRACTS[index % CONTRACTS.size()]
    waypoint.position = item["place"]

func objective() -> String:
    var item: Dictionary = CONTRACTS[index % CONTRACTS.size()]
    return "%s  |  %d EUR" % [item["name"], int(item["payment"])]

func try_interact(p: Vector3) -> Dictionary:
    var item: Dictionary = CONTRACTS[index % CONTRACTS.size()]
    var target: Vector3 = item["place"]
    if Vector2(p.x, p.z).distance_to(Vector2(target.x, target.z)) > 8.0:
        return {"handled":false}
    completed += 1
    var last = str(item["category"]) + " abgeschlossen; Weltzustand aktualisiert"
    consequences.append(last)
    if consequences.size() > 40:
        consequences.pop_front()
    index += 1
    _update_marker()
    return {"handled":true,"money":int(item["payment"]),"message":last}

func get_data() -> Dictionary:
    return {"index": index, "completed": completed, "consequences": consequences.duplicate()}

func restore_data(data: Dictionary) -> void:
    index = maxi(0, int(data.get("index", 0)))
    completed = maxi(0, int(data.get("completed", 0)))
    consequences.clear()
    for entry in data.get("consequences", []):
        consequences.append(str(entry))
    _update_marker()
