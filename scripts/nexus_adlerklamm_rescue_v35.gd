extends Node3D
class_name NexusAdlerklammRescueV35
## Three reachable rescue targets, real choice and interactable objectives.
## Prototype staging; no medical simulation or automated NPC pathfinding.
signal radio_call(message: String)
signal rescue_finished(role: String, people: int)
const TARGETS: Array[Vector3] = [Vector3(164,1.0,205),Vector3(178,1.0,217),Vector3(189,1.0,206)]
const PAYOUT := 780
var phase: String = "dormant"
var role: String = ""
var rescued: Array[int] = []
var markers: Array[Node3D] = []
var reward_claimed: bool = false

func _ready() -> void:
    name = "Adlerklamm | Interactive rescue search + helicopter winch"
    for i in range(TARGETS.size()):
        var survivor := Node3D.new()
        survivor.name = "Civilian survivor %d" % (i+1)
        survivor.position = TARGETS[i]
        add_child(survivor)
        var torso := MeshInstance3D.new()
        var capsule := CapsuleMesh.new()
        capsule.height = 1.65
        capsule.radius = 0.38
        torso.mesh = capsule
        var material := StandardMaterial3D.new()
        material.albedo_color = Color("d88746") if i%2 == 0 else Color("447aa2")
        torso.material_override = material
        torso.position.y = 0.87
        survivor.add_child(torso)
        var label := Label3D.new()
        label.text = "UEBERLEBENDER %d  | E" % (i+1)
        label.position.y = 2.8
        label.font_size = 36
        label.pixel_size = 0.008
        label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        survivor.add_child(label)
        markers.append(survivor)
    _refresh()

func trigger() -> bool:
    if phase != "dormant":
        return false
    phase = "choice"
    radio_call.emit("NOTRUF ADLERKLAMM! IST HIER EIN SANITAETER ODER PILOT? Menschen sind im Canyon eingeschlossen!")
    _refresh()
    return true

func choose_role(value: String) -> bool:
    if phase != "choice" or not ["sanitaeter","pilot","bodensuche"].has(value):
        return false
    role = value
    phase = "active"
    radio_call.emit("Bergungsteam " + value + ": 3 Menschen finden und retten. Sanitaeter/Bodensuche: E bei Markierung. Pilot: Helikopter an den Rettungspunkten im Schwebeflug.")
    _refresh()
    return true

func try_rescue(at: Vector3, vehicle_category: String = "", speed: float = 0.0) -> Dictionary:
    if phase != "active":
        return {"handled":false}
    if role == "pilot" and vehicle_category != "Helikopter":
        return {"handled":true,"message":"Pilot: Besteige den Helikopter und fliege zu einem markierten Rettungspunkt."}
    if role != "pilot" and vehicle_category != "":
        return {"handled":true,"message":"Bodenteam: Fahrzeug verlassen und Ueberlebende zu Fuss versorgen."}
    var radius := 21.0 if role == "pilot" else 4.5
    for i in range(TARGETS.size()):
        if rescued.has(i):
            continue
        var horizontal := Vector2(at.x-TARGETS[i].x,at.z-TARGETS[i].z).length()
        if horizontal > radius:
            continue
        if role == "pilot":
            if at.y < TARGETS[i].y+4.0 or at.y > TARGETS[i].y+25.0 or absf(speed) > 7.0:
                return {"handled":true,"message":"Hover: 4 bis 25 m Hoehe, weniger als 7 m/s und innerhalb 21 m"}
        else:
            if absf(at.y-TARGETS[i].y) > 5.0:
                continue
        rescued.append(i)
        _refresh()
        if rescued.size() == TARGETS.size():
            phase = "completed"
            rescue_finished.emit(role,rescued.size())
            return {"handled":true,"complete":true,"message":"ALLE 3 GEBORGEN! Einsatzleitung bestaetigt erfolgreiche Rettung.","money":PAYOUT if not reward_claimed else 0}
        return {"handled":true,"message":"Person %d in Sicherheit! %d/3 geborgen" % [i+1,rescued.size()]}
    return {"handled":true,"message":"Suche einen noch nicht geretteten Menschen an den gelben Markierungen."}

func claim_reward() -> bool:
    if phase != "completed" or reward_claimed:
        return false
    reward_claimed = true
    return true

func remaining_objective() -> String:
    if phase == "dormant":
        return ""
    if phase == "choice":
        return "NOTRUF: Sanitaeter, Pilot oder Bodensuche waehlen (Auswahlfenster)"
    if phase == "active":
        return "RETTUNG %s | Personen %d/3 | E bei den Markierungen" % [role.to_upper(),rescued.size()]
    return "BERGUNG ERFOLGREICH | 3/3 gerettet"

func _refresh() -> void:
    for i in range(markers.size()):
        markers[i].visible = phase == "active" and not rescued.has(i)

func get_data() -> Dictionary:
    return {"phase":phase,"role":role,"rescued":rescued.duplicate(),"reward_claimed":reward_claimed}

func restore_data(data: Dictionary) -> void:
    phase = str(data.get("phase","dormant"))
    if not ["dormant","choice","active","completed"].has(phase):
        phase = "dormant"
    role = str(data.get("role",""))
    rescued.clear()
    for value in data.get("rescued",[]):
        var index := int(value)
        if index >= 0 and index < TARGETS.size() and not rescued.has(index):
            rescued.append(index)
    reward_claimed = bool(data.get("reward_claimed",false))
    _refresh()
