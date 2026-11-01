extends Node
class_name NexusDirector
## Deterministic, data-driven event prototype. No generative AI or multiplayer.
signal event_started(description: String)

var elapsed: float = 0.0
var event_index: int = 0
var active_event: String = ""
var history: Array[String] = []
const INTERVAL: float = 180.0
const EVENTS = [
    {"id": "supply", "title": "Versorgungsengpass im Dorf", "min_wood": 0, "min_iron": 0},
    {"id": "repair", "title": "Werkstatt meldet einen Reparaturauftrag", "min_wood": 2, "min_iron": 1},
    {"id": "research", "title": "Forschungsteam sucht Materialproben", "min_wood": 0, "min_iron": 0},
    {"id": "rescue", "title": "Notruf aus dem Berggebiet", "min_wood": 0, "min_iron": 0}
]

func advance(delta: float, wood: int, iron: int) -> void:
    elapsed += delta
    if elapsed < INTERVAL:
        return
    elapsed = fmod(elapsed, INTERVAL)
    for offset in range(EVENTS.size()):
        var event: Dictionary = EVENTS[(event_index + offset) % EVENTS.size()]
        if wood >= int(event["min_wood"]) and iron >= int(event["min_iron"]):
            event_index = (event_index + offset + 1) % EVENTS.size()
            active_event = str(event["title"])
            history.append(str(event["id"]))
            if history.size() > 24:
                history.pop_front()
            event_started.emit(active_event)
            return
    event_index = (event_index + 1) % EVENTS.size()

func get_data() -> Dictionary:
    return {"elapsed": elapsed, "event_index": event_index, "active_event": active_event, "history": history.duplicate()}

func restore_data(data: Dictionary) -> void:
    elapsed = clampf(float(data.get("elapsed", 0.0)), 0.0, INTERVAL)
    event_index = posmod(int(data.get("event_index", 0)), EVENTS.size())
    active_event = str(data.get("active_event", ""))
    history.clear()
    var stored = data.get("history", [])
    if stored is Array:
        for item in stored.slice(maxi(0, stored.size() - 24)):
            history.append(str(item))
