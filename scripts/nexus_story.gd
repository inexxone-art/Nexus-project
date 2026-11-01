extends Node3D
class_name NexusStory
## A complete, small playable narrative chain (not a 48-hour campaign).
## Permanent story memory and a single, accessible mission beacon.
signal story_changed(message: String)

const TARGETS: Array[Vector3] = [
    Vector3(74, 0, 72),
    Vector3(47, 0, 32),
    Vector3(117, 0, 82),
    Vector3(-59, 0, 87),
]
const TASKS: Array[String] = [
    "PROLOG: Finde den Vermissten im Gebirge (74, 72)",
    "Bring die verletzte Person zur Bergrettung (47, 32)",
    "Untersuche das Signal VOR Sektor 31 (117, 82)",
    "Bringe die Bergungsdaten zur Baustelle (-59, 87)",
    "PROLOG ABGESCHLOSSEN - freie Spielwelt",
]
var stage: int = 0
var reputation: int = 0
var recovered_truth: bool = false
var final_choice: int = 0
var memories: Array[String] = []
var beacon: Node3D
var beacon_lamp: OmniLight3D
var pulse_time: float = 0.0

func _ready() -> void:
    name = "NEXUS | Story, Konsequenzen und Weltgedaechtnis"
    beacon = Node3D.new()
    beacon.name = "Missionssignal"
    add_child(beacon)
    var shaft := MeshInstance3D.new()
    var cylinder := CylinderMesh.new()
    cylinder.height = 3.2
    cylinder.bottom_radius = 0.13
    cylinder.top_radius = 0.02
    shaft.mesh = cylinder
    var mat := StandardMaterial3D.new()
    mat.albedo_color = Color("6be7e1")
    mat.emission_enabled = true
    mat.emission = Color("36c4e1")
    mat.emission_energy_multiplier = 2.6
    shaft.material_override = mat
    shaft.position.y = 1.7
    beacon.add_child(shaft)
    var title := Label3D.new()
    title.name = "Auftragsname"
    title.text = "◆ NEXUS-STORY | E"
    title.position.y = 4.4
    title.pixel_size = 0.005
    title.font_size = 45
    title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    beacon.add_child(title)
    beacon_lamp = OmniLight3D.new()
    beacon_lamp.position.y = 3.0
    beacon_lamp.light_color = Color("49dcea")
    beacon_lamp.light_energy = 0.7
    beacon_lamp.omni_range = 8.0
    beacon.add_child(beacon_lamp)
    _update_beacon()

func _process(delta: float) -> void:
    pulse_time += delta
    if beacon.visible:
        beacon_lamp.light_energy = 0.7 + 0.4 * sin(pulse_time * 2.5)

func _update_beacon() -> void:
    if beacon == null:
        return
    beacon.visible = stage < TARGETS.size()
    if beacon.visible:
        beacon.position = TARGETS[stage]

func current_objective() -> String:
    return TASKS[clampi(stage, 0, TASKS.size() - 1)]

func target_distance(p: Vector3) -> int:
    if stage >= TARGETS.size():
        return 0
    return roundi(Vector2(p.x - TARGETS[stage].x, p.z - TARGETS[stage].z).length())

func interact(p: Vector3) -> Dictionary:
    if stage >= TARGETS.size() or Vector2(p.x - TARGETS[stage].x, p.z - TARGETS[stage].z).length() > 7.0:
        return {"handled": false}
    var message := ""
    var payout: int = 0
    match stage:
        0:
            memories.append("Ein Vermisster wurde aus einer Lawinenzone geborgen.")
            reputation += 2
            message = "Verletzten versorgt. Bring ihn zur Bergrettungsstation!"
        1:
            payout = 400
            memories.append("Bergrettung abgeschlossen. Unbekannter Sender an der Ausruestung gefunden.")
            reputation += 3
            message = "Rettung erfolgreich: +400 EUR. Ein Signal fuehrt zu Sektor 31."
        2:
            memories.append("Vor Sektor 31 wurde ein verschluesselter Datentraeger geborgen.")
            recovered_truth = true
            message = "Datentraeger gefunden. Entscheidung: [1] Behoerden informieren / [2] Daten oeffentlich machen."
            stage += 1
            _update_beacon()
            story_changed.emit(message)
            return {"handled": true, "money": 0, "message": message}
        3:
            payout = 700 if final_choice == 1 else 520
            reputation += 3 if final_choice == 1 else 1
            memories.append("Daten an Wiederaufbau-Team uebergeben; Stadtversorgung stabilisiert.")
            message = "STORY-PROLOG ABGESCHLOSSEN! +%d EUR. Die Welt erinnert sich an deine Entscheidungen." % payout
    stage += 1
    _update_beacon()
    story_changed.emit(message)
    return {"handled": true, "money": payout, "message": message}

func decide(option: int) -> String:
    if stage != 3 or final_choice != 0:
        return "Keine offene Story-Entscheidung."
    final_choice = clampi(option, 1, 2)
    if final_choice == 1:
        memories.append("Spieler hat die verschluesselten Daten den Behoerden anvertraut.")
        reputation += 2
        return "Du informierst die Einsatzleitung. Vertrauen +2."
    memories.append("Spieler hat die Daten transparent an die Oeffentlichkeit gegeben.")
    reputation -= 1
    return "Du veroeffentlichst die Daten. Die Fraktion reagiert misstrauisch."

func trigger_alert(title: String) -> void:
    memories.append("Weltmeldung: " + title)
    if memories.size() > 32:
        memories.pop_front()

func get_data() -> Dictionary:
    return {
        "stage": stage, "reputation": reputation, "recovered_truth": recovered_truth,
        "final_choice": final_choice, "memories": memories.duplicate()
    }

func restore_data(data: Dictionary) -> void:
    stage = clampi(int(data.get("stage", 0)), 0, TARGETS.size())
    reputation = int(data.get("reputation", 0))
    recovered_truth = bool(data.get("recovered_truth", false))
    final_choice = clampi(int(data.get("final_choice", 0)), 0, 2)
    memories.clear()
    var remembered = data.get("memories", [])
    if remembered is Array:
        for item in remembered.slice(maxi(0, remembered.size() - 32)):
            memories.append(str(item))
    _update_beacon()
