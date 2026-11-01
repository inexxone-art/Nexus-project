extends Node
class_name NexusLivingUniverse
## Deterministic gameplay simulation: regional stability, economic stocks, factions,
## decisions, and a bounded, persistent history. This is not a full city simulation.
signal incident_opened(title: String)
signal incident_resolved(summary: String)

const EVENT_PERIOD: float = 105.0
const HISTORY_LIMIT: int = 64
const REGIONS: Array[String] = ["Alpental", "NEXUS City", "Sektor 31", "Raumhafen", "Bergwerke", "Kolonien"]
const INCIDENTS: Array[Dictionary] = [
    {"id":"blackout", "title":"Stromausfall: Regionales Umspannwerk", "region":1,
     "brief":"Die Stromversorgung der Stadt ist unterbrochen. Einsatzteams und Industrie warten.",
     "a":"Notstromversorgung organisieren", "b":"Kraftwerksreparatur finanzieren", "cost_a":80,"cost_b":230,
     "payout_a":110,"payout_b":300,"delta_a":6,"delta_b":13,"faction":"Zivilschutz"},
    {"id":"rescue", "title":"Bergrettung: Suchaktion nach Unwetter", "region":0,
     "brief":"Wetter und Steinschlag blockieren eine Bergroute. Verschollene brauchen Hilfe.",
     "a":"Rettungstrupp entsenden", "b":"Hubschrauber und Bergrettung aktivieren", "cost_a":40,"cost_b":160,
     "payout_a":145,"payout_b":230,"delta_a":5,"delta_b":11,"faction":"Zivilschutz"},
    {"id":"convoy", "title":"Versorgungskonvoi: Kolonien melden Engpass", "region":5,
     "brief":"Ein Handelskonvoi ist verspätet; Werkstätten und Kolonien erwarten Ersatzteile.",
     "a":"Handelsroute sichern", "b":"Materialien über Raumhafen liefern", "cost_a":95,"cost_b":195,
     "payout_a":160,"payout_b":320,"delta_a":7,"delta_b":12,"faction":"Handelsbund"},
    {"id":"quarantine", "title":"Sektor 31: Unbekanntes Signal", "region":2,
     "brief":"Eine Forschungsstation meldet ein unbekanntes Energiesignal.",
     "a":"Forschungsteam unterstützen", "b":"Sektor absperren und untersuchen", "cost_a":75,"cost_b":175,
     "payout_a":145,"payout_b":225,"delta_a":5,"delta_b":9,"faction":"Forschungsrat"},
    {"id":"mine", "title":"Bergwerk: Förderanlage defekt", "region":4,
     "brief":"Ein Stollen ist unpassierbar. Der Ausfall verteuert die Versorgung der Stadt.",
     "a":"Werkstatt beauftragen", "b":"Schwere Bagger und Reparaturkolonne senden", "cost_a":65,"cost_b":210,
     "payout_a":125,"payout_b":310,"delta_a":6,"delta_b":12,"faction":"Handelsbund"},
    {"id":"port", "title":"Raumhafen: Dockalarm", "region":3,
     "brief":"Ein Versorgungsschiff musste den Anflug abbrechen. Ersatzteile fehlen.",
     "a":"Andockhilfe koordinieren", "b":"Techniker und Schlepper entsenden", "cost_a":55,"cost_b":185,
     "payout_a":150,"payout_b":290,"delta_a":5,"delta_b":11,"faction":"Forschungsrat"}
]

var regions: Dictionary = {}
var factions: Dictionary = {}
var market: Dictionary = {}
var pending: Dictionary = {}
var memories: Array[String] = []
var completed: int = 0
var field_operations: int = 0
var elapsed: float = 0.0
var turn: int = 0
var peaceful_mode: bool = false

func _init() -> void:
    reset()

func reset() -> void:
    regions.clear()
    factions.clear()
    market = {"timber": 100, "metal": 95, "energy": 100, "food": 100}
    for region in REGIONS:
        regions[region] = {"stability":85, "prosperity":65, "supply":80}
    for group in ["Zivilschutz", "Handelsbund", "Forschungsrat", "Grenzwache"]:
        factions[group] = 0
    pending.clear()
    memories.clear()
    completed = 0
    field_operations = 0
    elapsed = 0.0
    turn = 0
    peaceful_mode = false

func advance(delta: float) -> void:
    if delta <= 0.0:
        return
    elapsed += minf(delta, 30.0)
    if elapsed < EVENT_PERIOD:
        return
    elapsed = fmod(elapsed, EVENT_PERIOD)
    if not pending.is_empty():
        return
    var template: Dictionary = INCIDENTS[turn % INCIDENTS.size()]
    turn += 1
    var location: String = REGIONS[int(template["region"])]
    var state: Dictionary = regions[location]
    state["stability"] = maxi(20, int(state["stability"]) - 6)
    state["supply"] = maxi(15, int(state["supply"]) - 4)
    regions[location] = state
    pending = template.duplicate(true)
    _remember("Alarm in %s: %s" % [location, str(template["title"])])
    incident_opened.emit(str(template["title"]))

func choices() -> Array[String]:
    if pending.is_empty():
        return []
    return [str(pending.get("a", "")), str(pending.get("b", ""))]

func resolve(choice: int, money: int) -> Dictionary:
    if pending.is_empty():
        return {"ok":false,"message":"Kein offener Welteinsatz."}
    if choice != 1 and choice != 2:
        return {"ok":false,"message":"Ungültige Entscheidung."}
    var suffix := "a" if choice == 1 else "b"
    var cost := int(pending["cost_" + suffix])
    if money < cost:
        return {"ok":false,"message":"Nicht genug Geld für den Einsatz (%d EUR)." % cost}
    var payout := int(pending["payout_" + suffix])
    var benefit := int(pending["delta_" + suffix])
    var location: String = REGIONS[int(pending["region"])]
    var state: Dictionary = regions[location]
    state["stability"] = clampi(int(state["stability"]) + benefit, 0, 100)
    state["supply"] = clampi(int(state["supply"]) + int(benefit / 2), 0, 100)
    state["prosperity"] = clampi(int(state["prosperity"]) + 2, 0, 100)
    regions[location] = state
    var faction: String = str(pending["faction"])
    factions[faction] = clampi(int(factions.get(faction, 0)) + (1 if choice == 1 else 3), -50, 50)
    var description := "%s: %s (%s, Ruf %d)" % [location, str(pending[suffix]), faction, int(factions[faction])]
    _remember(description)
    completed += 1
    pending.clear()
    incident_resolved.emit(description)
    return {"ok":true,"money":payout - cost,"message":description,"completed":completed}

func apply_field_operation(category: String, region: String) -> void:
    ## A completed physical mission improves the same persisted world state as an incident.
    if not regions.has(region):
        return
    var state: Dictionary = regions[region]
    state["stability"] = clampi(int(state["stability"]) + 4, 0, 100)
    state["supply"] = clampi(int(state["supply"]) + 5, 0, 100)
    state["prosperity"] = clampi(int(state["prosperity"]) + 2, 0, 100)
    regions[region] = state
    var group := "Zivilschutz"
    if category == "Forschung":
        group = "Forschungsrat"
    elif category == "Versorgung":
        group = "Handelsbund"
    elif category == "Konflikt":
        group = "Grenzwache"
    factions[group] = clampi(int(factions[group]) + 1, -50, 50)
    field_operations += 1
    _remember("Feldeinsatz %s in %s abgeschlossen" % [category, region])

func get_summary() -> String:
    if not pending.is_empty():
        return "ALARM: %s" % str(pending["title"])
    var minimum := 100
    var weak_region := ""
    for region in REGIONS:
        var stability := int(regions[region]["stability"])
        if stability < minimum:
            minimum = stability
            weak_region = region
    return "WELTLAGE: %s Stabilität %d/100 | Einsätze %d" % [weak_region, minimum, completed]

func region_status(region: String) -> Dictionary:
    return regions.get(region, {}).duplicate(true)

func _remember(entry: String) -> void:
    memories.append(entry)
    while memories.size() > HISTORY_LIMIT:
        memories.pop_front()

func get_data() -> Dictionary:
    return {"regions":regions.duplicate(true),"factions":factions.duplicate(true),"market":market.duplicate(true),
        "pending":pending.duplicate(true),"memories":memories.duplicate(),"completed":completed,"field_operations":field_operations,
        "elapsed":elapsed,"turn":turn,"peaceful_mode":peaceful_mode}

func restore_data(data: Dictionary) -> void:
    reset()
    if data.is_empty():
        return
    var original_regions = data.get("regions", {})
    if original_regions is Dictionary:
        for region in REGIONS:
            var candidate = original_regions.get(region, {})
            if candidate is Dictionary:
                for field in ["stability","prosperity","supply"]:
                    if candidate.has(field):
                        regions[region][field] = clampi(int(candidate[field]), 0, 100)
    var original_factions = data.get("factions", {})
    if original_factions is Dictionary:
        for faction in factions.keys():
            factions[faction] = clampi(int(original_factions.get(faction, 0)), -50, 50)
    var saved_pending = data.get("pending", {})
    if saved_pending is Dictionary and not saved_pending.is_empty():
        for incident in INCIDENTS:
            if incident["id"] == str(saved_pending.get("id", "")):
                pending = incident.duplicate(true)
                break
    var log = data.get("memories", [])
    if log is Array:
        for item in log.slice(maxi(0, log.size() - HISTORY_LIMIT)):
            memories.append(str(item))
    completed = maxi(0, int(data.get("completed", 0)))
    field_operations = maxi(0, int(data.get("field_operations", 0)))
    elapsed = clampf(float(data.get("elapsed", 0.0)), 0.0, EVENT_PERIOD)
    turn = maxi(0, int(data.get("turn", 0)))
    peaceful_mode = bool(data.get("peaceful_mode", false))
