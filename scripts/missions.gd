extends Node3D
class_name NexusMissions
## Small, repeatable single-player missions. No pathfinding or dedicated rescue AI yet.
var rescue_ready: bool = false
var sample_ready: bool = false
var front_captured: bool = false
var rescued_total: int = 0
var samples_total: int = 0
var fronts_total: int = 0
var repairs_total: int = 0
var objective: String = "Rette den Wanderer im Berggebiet (74, 72)"
var objective_label: Label3D

func _ready() -> void:
    name = "Missionen / V0.8"
    _mission_marker(Vector3(74, 3.0, 72), "BERGRETTUNG")
    _mission_marker(Vector3(117, 3.0, 109), "LABORPROBE")
    _mission_marker(Vector3(-101, 3.0, -111), "FRONTZIEL")
    _mission_marker(Vector3(-59, 3.0, 87), "WIEDERAUFBAU")

func _mission_marker(p: Vector3, label_text: String) -> void:
    var l = Label3D.new()
    l.text = "◆ " + label_text
    l.font_size = 48
    l.pixel_size = 0.006
    l.position = p
    l.modulate = Color("e7d4a5")
    l.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    add_child(l)

func interact_at(p: Vector3, wood: int, iron: int) -> Dictionary:
    if p.distance_to(Vector3(74, 0, 72)) < 5.0 and not rescue_ready:
        rescue_ready = true
        objective = "Bring den Wanderer zur Rettungsstation (47, 32)"
        return {"handled": true, "message": "Verletzten aufgenommen – zur Bergrettung bringen."}
    if p.distance_to(Vector3(47, 0, 32)) < 12.0 and rescue_ready:
        rescue_ready = false
        rescued_total += 1
        objective = "Bergrettung erledigt. Weitere Auftraege mit M ansehen."
        return {"handled": true, "money": 450, "message": "Rettungsmission abgeschlossen: +450 €"}
    if p.distance_to(Vector3(117, 0, 109)) < 7.0 and not sample_ready:
        sample_ready = true
        objective = "Bring die versiegelte Laborprobe zur Rettungsstation."
        return {"handled": true, "message": "Laborprobe gesichert – zur Klinik bringen."}
    if p.distance_to(Vector3(47, 0, 32)) < 12.0 and sample_ready:
        sample_ready = false
        samples_total += 1
        objective = "Laborprobe abgegeben. Die Forschungsstation bleibt gesperrt."
        return {"handled": true, "money": 350, "message": "Probenlieferung abgeschlossen: +350 €"}
    if p.distance_to(Vector3(-101, 0, -111)) < 9.0 and not front_captured:
        front_captured = true
        fronts_total += 1
        objective = "Frontstellung gesichert. Keine Zerstörung fremder Spielerbauten."
        return {"handled": true, "money": 250, "message": "Historisches Frontziel eingenommen: +250 €"}
    if p.distance_to(Vector3(-59, 0, 87)) < 12.0:
        if wood >= 4 and iron >= 2:
            repairs_total += 1
            objective = "Rohbau fertig – besorge neue Materialien."
            return {"handled": true, "wood": -4, "iron": -2, "money": 520, "message": "Baustelle versorgt (4 Holz + 2 Eisen): +520 €"}
        return {"handled": true, "message": "Baustelle braucht 4 Holz und 2 Eisen."}
    return {"handled": false}

func get_data() -> Dictionary:
    return {"rescue_ready": rescue_ready, "sample_ready": sample_ready, "front_captured": front_captured, "rescues": rescued_total, "samples": samples_total, "fronts": fronts_total, "repairs": repairs_total, "objective": objective}

func restore_data(d: Dictionary) -> void:
    rescue_ready = bool(d.get("rescue_ready", false))
    sample_ready = bool(d.get("sample_ready", false))
    front_captured = bool(d.get("front_captured", false))
    rescued_total = int(d.get("rescues", 0))
    samples_total = int(d.get("samples", 0))
    fronts_total = int(d.get("fronts", 0))
    repairs_total = int(d.get("repairs", 0))
    objective = str(d.get("objective", "Rette den Wanderer im Berggebiet (74, 72)"))
