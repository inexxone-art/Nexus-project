extends Node
## NEXUS gameplay domain model (Godot 4.4). Add as an Autoload named NexusEconomy.
## Currency is fictional in-game EUR. All mutations validate funds and ownership.
signal changed
signal discovery_added(id: String)
signal mission_unlocked(id: String)
const SAVE_PATH := "user://nexus_economy_v1.json"
const HOUR_SECONDS := 3600.0
var cash: int = 1500
var owned: Dictionary = {"starter_home": true}
var discovered: Dictionary = {"intro_bridge": true, "intro_training": true, "intro_jobs": true}
var completed: Dictionary = {}
var stock: Dictionary = {}
var active_research: Dictionary = {}
var elapsed_seconds: float = 0.0
var properties: Dictionary = {
    "starter_home": {"name":"Haus Adlerklamm", "price":0, "rent":0, "upkeep":12, "world":"earth"},
    "village_house": {"name":"Dorfhaus", "price":45000, "rent":180, "upkeep":35, "world":"earth"},
    "city_flat": {"name":"Stadtwohnung", "price":82000, "rent":360, "upkeep":65, "world":"earth"},
    "ice_base": {"name":"Eisplanet-Basis", "price":175000, "rent":0, "upkeep":120, "world":"ice"}
}
var goods: Dictionary = {
    "wood": {"price":18}, "stone": {"price":12}, "gravel": {"price":15},
    "cement": {"price":30}, "concrete": {"price":48}, "iron": {"price":32},
    "steel": {"price":75}, "gold": {"price":300}, "oil": {"price":55},
    "meteorite": {"price":8000}, "food": {"price":8}
}
var quests: Dictionary = {
    "intro_bridge": {"title":"Brückenunglück", "reward":500, "needs":{}},
    "intro_training": {"title":"Grundausbildung", "reward":250, "needs":{}},
    "intro_jobs": {"title":"Erster Lieferauftrag", "reward":120, "needs":{"wood":3}},
    "bridge_rebuild": {"title":"Brücke wiederaufbauen", "reward":4500, "needs":{"concrete":20, "steel":12}},
    "meteorite_delivery": {"title":"Meteoritenprobe abgeben", "reward":9000, "needs":{"meteorite":1}}
}
var recipes: Dictionary = {
    "gravel": {"stone":2}, "cement": {"stone":3},
    "concrete": {"gravel":2, "cement":1}, "steel": {"iron":2}
}
var research: Dictionary = {
    "lava_suit": {"name":"Lava-Schutzanzug", "cost":12000, "needs":{"meteorite":1, "steel":3}, "hours":4.0},
    "ice_suit": {"name":"Kälteschutzanzug", "cost":7000, "needs":{"steel":2}, "hours":3.0}
}
func _ready() -> void:
    load_state()

func discover(id: String) -> void:
    if discovered.has(id):
        return
    discovered[id] = true
    discovery_added.emit(id)
    if quests.has(id):
        mission_unlocked.emit(id)
    changed.emit()

func board_entries() -> Array[Dictionary]:
    var entries: Array[Dictionary] = []
    for id in quests:
        if discovered.has(id) and not completed.has(id):
            var entry: Dictionary = quests[id].duplicate(true)
            entry["id"] = id
            entries.append(entry)
    return entries

func add_item(id: String, amount: int = 1) -> bool:
    if amount <= 0 or not goods.has(id):
        return false
    stock[id] = int(stock.get(id, 0)) + amount
    changed.emit()
    return true

func _has_materials(needs: Dictionary) -> bool:
    for id in needs:
        if int(stock.get(id, 0)) < int(needs[id]):
            return false
    return true

func _consume(needs: Dictionary) -> void:
    for id in needs:
        stock[id] = int(stock.get(id, 0)) - int(needs[id])

func buy_item(id: String, amount: int = 1) -> bool:
    if amount <= 0 or not goods.has(id):
        return false
    var cost: int = int(goods[id]["price"]) * amount
    if cash < cost:
        return false
    cash -= cost
    add_item(id, amount)
    changed.emit()
    return true

func sell_item(id: String, amount: int = 1) -> bool:
    if amount <= 0 or not goods.has(id) or int(stock.get(id, 0)) < amount:
        return false
    stock[id] = int(stock[id]) - amount
    cash += int(goods[id]["price"]) * amount
    changed.emit()
    return true

func manufacture(id: String, amount: int = 1) -> bool:
    if amount <= 0 or not recipes.has(id):
        return false
    var needs: Dictionary = {}
    for material in recipes[id]:
        needs[material] = int(recipes[id][material]) * amount
    if not _has_materials(needs):
        return false
    _consume(needs)
    add_item(id, amount)
    return true

func buy_property(id: String) -> bool:
    if not properties.has(id) or owned.has(id):
        return false
    var cost: int = int(properties[id]["price"])
    if cash < cost:
        return false
    cash -= cost
    owned[id] = true
    changed.emit()
    return true

func finish_quest(id: String) -> bool:
    if not discovered.has(id) or completed.has(id) or not quests.has(id):
        return false
    var quest: Dictionary = quests[id]
    if not _has_materials(quest["needs"]):
        return false
    _consume(quest["needs"])
    cash += int(quest["reward"])
    completed[id] = true
    if id == "intro_bridge":
        discover("bridge_rebuild")
    changed.emit()
    return true

func start_research(id: String) -> bool:
    if not research.has(id) or active_research.has(id) or completed.has("research_" + id):
        return false
    var spec: Dictionary = research[id]
    if cash < int(spec["cost"]) or not _has_materials(spec["needs"]):
        return false
    cash -= int(spec["cost"])
    _consume(spec["needs"])
    active_research[id] = float(spec["hours"]) * HOUR_SECONDS
    changed.emit()
    return true

func advance_time(seconds: float) -> void:
    if seconds <= 0.0:
        return
    elapsed_seconds += seconds
    for id in active_research.keys():
        active_research[id] = float(active_research[id]) - seconds
        if float(active_research[id]) <= 0.0:
            active_research.erase(id)
            completed["research_" + id] = true
    # Deterministic, capped in-game time; no unbounded real-world offline earnings.
    while elapsed_seconds >= HOUR_SECONDS:
        elapsed_seconds -= HOUR_SECONDS
        for id in owned:
            if properties.has(id):
                cash += int(properties[id]["rent"]) - int(properties[id]["upkeep"])
    changed.emit()

func save_state() -> bool:
    var data := {"cash":cash, "owned":owned, "discovered":discovered,
        "completed":completed, "stock":stock, "active_research":active_research,
        "elapsed_seconds":elapsed_seconds}
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(data))
    return true

func load_state() -> bool:
    if not FileAccess.file_exists(SAVE_PATH):
        return false
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    if file == null:
        return false
    var parsed: Variant = JSON.parse_string(file.get_as_text())
    if not parsed is Dictionary:
        return false
    cash = maxi(0, int(parsed.get("cash", cash)))
    for key in ["owned", "discovered", "completed", "stock", "active_research"]:
        var value: Variant = parsed.get(key)
        if value is Dictionary:
            set(key, value)
    elapsed_seconds = clampf(float(parsed.get("elapsed_seconds", 0.0)), 0.0, HOUR_SECONDS)
    changed.emit()
    return true
