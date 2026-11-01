extends Node3D
class_name NexusWorldOperations
## V1.5: multi-stage field contracts: inspect -> resolve -> report.
## These are game interactions, not representations of full real-world workflows.
signal operation_completed(contract: Dictionary)

const CONTRACTS: Array[Dictionary] = [
    {"name":"Bergrettung: Vermisste im Canyon", "place":Vector3(77,0,75),
     "followup":Vector3(89,0,99), "base":Vector3(47,0,32), "region":"Alpental",
     "category":"Rettung", "payment":425,
     "steps":["Suche das letzte Funksignal", "Versorge die vermisste Person", "Uebergabe an die Bergrettung"]},
    {"name":"Sektor 31: Verschluesselte Nachricht", "place":Vector3(114,0,84),
     "followup":Vector3(117,0,109), "base":Vector3(57,0,72), "region":"Sektor 31",
     "category":"Forschung", "payment":520,
     "steps":["Pruefe die Sperrzone", "Sichere den Datentraeger", "Bringe die Daten zur Forschungsstation"]},
    {"name":"Stadt: Evakuierung eines Wohnblocks", "place":Vector3(-58,0,86),
     "followup":Vector3(-75,0,105), "base":Vector3(-44,0,58), "region":"NEXUS City",
     "category":"Rettung", "payment":480,
     "steps":["Erkunde den Fluchtweg", "Begleite die Bewohner zum Sammelpunkt", "Melde den Einsatz bei der Leitstelle"]},
    {"name":"Front: Versorgungskonvoi", "place":Vector3(-101,0,-104),
     "followup":Vector3(-83,0,-88), "base":Vector3(-36,0,-62), "region":"Bergwerke",
     "category":"Versorgung", "payment":650,
     "steps":["Finde den liegengebliebenen Konvoi", "Sichere die Versorgungsgueter", "Bringe den Lagebericht zur Basis"]},
    {"name":"Wald: Nach dem Waldbrand", "place":Vector3(-22,0,-47),
     "followup":Vector3(-7,0,-56), "base":Vector3(10,0,-13), "region":"Alpental",
     "category":"Natur", "payment":390,
     "steps":["Untersuche die Brandflaeche", "Markiere die Gefahrenzone", "Melde die Lage bei der Forstverwaltung"]},
    {"name":"Raumhafen: NEXUS-Signal", "place":Vector3(55,0,66),
     "followup":Vector3(70,0,90), "base":Vector3(47,0,32), "region":"Raumhafen",
     "category":"Forschung", "payment":580,
     "steps":["Finde die Senderanlage", "Kalibriere den Signalknoten", "Uebergabe an die Einsatzleitung"]},
]
const MAX_HISTORY: int = 40
const INTERACTION_RADIUS: float = 8.0

var index: int = 0
var stage: int = 0
var completed: int = 0
var consequences: Array[String] = []
var waypoint: Node3D
var waypoint_title: Label3D

func _ready() -> void:
    name = "NEXUS OPS | Mehrstufige Welteinsaetze"
    waypoint = Node3D.new()
    add_child(waypoint)
    var signal_mesh := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.bottom_radius = 0.16
    mesh.top_radius = 0.03
    mesh.height = 4.5
    signal_mesh.mesh = mesh
    signal_mesh.position.y = 2.4
    var material := StandardMaterial3D.new()
    material.albedo_color = Color("ffbf60")
    material.emission_enabled = true
    material.emission = Color("ffc46b")
    material.emission_energy_multiplier = 1.9
    signal_mesh.material_override = material
    waypoint.add_child(signal_mesh)
    waypoint_title = Label3D.new()
    waypoint_title.position.y = 5.1
    waypoint_title.text = "NEXUS OPS | E"
    waypoint_title.font_size = 30
    waypoint_title.pixel_size = 0.008
    waypoint_title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    waypoint.add_child(waypoint_title)
    _update_marker()

func current_contract() -> Dictionary:
    return CONTRACTS[index % CONTRACTS.size()]

func current_target() -> Vector3:
    var contract := current_contract()
    if stage == 1:
        return contract["followup"]
    if stage == 2:
        return contract["base"]
    return contract["place"]

func _update_marker() -> void:
    if waypoint == null:
        return
    waypoint.position = current_target()
    if waypoint_title != null:
        waypoint_title.text = "EINSATZ %d/3 | E" % (stage + 1)

func distance_to_target(p: Vector3) -> int:
    var t := current_target()
    return roundi(Vector2(p.x, p.z).distance_to(Vector2(t.x, t.z)))

func objective() -> String:
    var contract := current_contract()
    return "%s (%d/3): %s | %d EUR" % [str(contract["name"]), stage + 1,
        str(contract["steps"][stage]), int(contract["payment"])]

func try_interact(p: Vector3) -> Dictionary:
    var target := current_target()
    if Vector2(p.x, p.z).distance_to(Vector2(target.x, target.z)) > INTERACTION_RADIUS:
        return {"handled":false}
    var contract := current_contract()
    if stage < 2:
        var summary := str(contract["steps"][stage]) + " abgeschlossen. Naechstes Einsatzziel markiert."
        stage += 1
        _update_marker()
        return {"handled":true,"completed":false,"money":0,"message":summary}
    var finished := contract.duplicate(true)
    completed += 1
    var description := str(contract["category"]) + ": " + str(contract["name"]) + " abgeschlossen"
    consequences.append(description)
    while consequences.size() > MAX_HISTORY:
        consequences.pop_front()
    index += 1
    stage = 0
    _update_marker()
    operation_completed.emit(finished)
    return {"handled":true,"completed":true,"money":int(contract["payment"]),
        "message":description + "; +%d EUR" % int(contract["payment"]),
        "category":str(contract["category"]),"region":str(contract["region"])}

func get_data() -> Dictionary:
    return {"index":index,"stage":stage,"completed":completed,
        "consequences":consequences.duplicate()}

func restore_data(data: Dictionary) -> void:
    index = clampi(int(data.get("index", 0)), 0, 1000000)
    stage = clampi(int(data.get("stage", 0)), 0, 2)
    completed = clampi(int(data.get("completed", 0)), 0, 1000000)
    consequences.clear()
    var log = data.get("consequences", [])
    if log is Array:
        for entry in log.slice(maxi(0, log.size() - MAX_HISTORY)):
            consequences.append(str(entry).substr(0, 200))
    _update_marker()
