extends Node
class_name NexusLegacy
## Persistent player career, progression, vehicle upgrades, property, crew,
## modular ship investment and a bounded story chronicle.
## Economy is authoritative in world.gd; this module only proposes signed deltas.

signal state_changed(summary: String)

const VERSION: int = 1
const MAX_HISTORY: int = 100
const XP_PER_LEVEL: int = 180
const CAREERS: Array[String] = ["Rettung", "Technik", "Forschung", "Sicherheit", "Handel", "Pilot"]
const STYLES: Array[String] = ["Explorer", "Einsatzkraft", "Ingenieur", "Pilot", "Feldforscher"]
const TUNES: Array[String] = ["motor", "reifen", "bremsen"]
const PROPERTY_PRICES: Dictionary = {"garage": 850, "house": 1250, "outpost": 2200}
const SHIP_PRICES: Dictionary = {"scanner": 700, "cargo": 1050, "medbay": 1200}
const TUNE_BASE_PRICES: Dictionary = {"motor": 175, "reifen": 120, "bremsen": 110}

var callsign: String = "Explorer"
var style: String = "Explorer"
var career: String = "Rettung"
var level: int = 1
var xp: int = 0
var skill_points: int = 0
var skills: Dictionary = {"driving":0, "rescue":0, "research":0, "trade":0}
var relationships: Dictionary = {}
var properties: Dictionary = {}
var ship_modules: Dictionary = {}
var vehicle_tuning: Dictionary = {}
var discoveries: Dictionary = {}
var events: Array[Dictionary] = []
var achievements: Dictionary = {}
var milestones: Dictionary = {}
var world_days: int = 0

func _ready() -> void:
    name = "NEXUS | Legacy & Progression"

func set_identity(new_callsign: String, new_style: String) -> Dictionary:
    var cleaned: String = new_callsign.strip_edges()
    if cleaned.length() < 2 or cleaned.length() > 24:
        return _error("Rufname: 2 bis 24 Zeichen")
    if not STYLES.has(new_style):
        return _error("Unbekannter Charakterstil")
    callsign = cleaned
    style = new_style
    _chronicle("avatar", "Charakter aktualisiert: %s (%s)" % [callsign,style])
    return _success("Charakter gespeichert",0)

func choose_career(value: String) -> Dictionary:
    if not CAREERS.has(value):
        return _error("Unbekannte Karriere")
    if career == value:
        return _error("Diese Karriere ist bereits aktiv")
    career = value
    _chronicle("career", "Neue Karriere: " + value)
    return _success("Karriere gewechselt: " + value,0)

func award_activity(kind: String, label: String, amount: int) -> Dictionary:
    if amount <= 0 or amount > 300 or label.strip_edges().is_empty():
        return _error("Ungueltige Aktivitaet")
    xp = clampi(xp + amount,0,999999)
    var levels_gained: int = 0
    while xp >= required_xp() and level < 50:
        xp -= required_xp()
        level += 1
        skill_points += 1
        levels_gained += 1
    if level >= 50:
        xp = mini(xp, required_xp()-1)
    _chronicle(kind,label)
    return _success("+%d XP%s" % [amount," | Level +%d" % levels_gained if levels_gained > 0 else ""],0)

func required_xp() -> int:
    return XP_PER_LEVEL + (level-1)*65

func invest_skill(skill: String) -> Dictionary:
    if not skills.has(skill):
        return _error("Unbekannte Faehigkeit")
    if skill_points <= 0:
        return _error("Keine freien Talentpunkte")
    if int(skills[skill]) >= 5:
        return _error("Talent bereits auf Stufe 5")
    skills[skill] = int(skills[skill])+1
    skill_points -= 1
    _chronicle("talent","%s: Stufe %d" % [skill,int(skills[skill])])
    return _success("Talent verbessert",0)

func meet_npc(npc_id: String) -> Dictionary:
    if npc_id.is_empty() or npc_id.length() > 40:
        return _error("Ungueltige NPC-ID")
    var old: int = int(relationships.get(npc_id,0))
    if old >= 1:
        return _success("Gespräch fortgesetzt: " + npc_id,0)
    relationships[npc_id] = 1
    _chronicle("relationship", "Kontakt geknuepft: " + npc_id)
    return award_activity("social","Neue Bekanntschaft: " + npc_id,20)

func purchase_property(property_id: String, wallet: int) -> Dictionary:
    if not PROPERTY_PRICES.has(property_id):
        return _error("Unbekanntes Grundstueck")
    if properties.has(property_id):
        return _error("Bereits in deinem Besitz")
    var cost: int = int(PROPERTY_PRICES[property_id])
    if wallet < cost:
        return _error("Zu wenig Geld: %d EUR erforderlich" % cost)
    properties[property_id] = {"purchased":true,"condition":100,"level":1}
    _chronicle("property","Immobilie erworben: %s" % property_id)
    return _success("Eigentum erworben: %s (-%d EUR)" % [property_id,cost],-cost)

func purchase_ship_module(module_id: String, wallet: int) -> Dictionary:
    if not SHIP_PRICES.has(module_id):
        return _error("Unbekanntes Raumschiffmodul")
    if ship_modules.has(module_id):
        return _error("Modul bereits installiert")
    var cost: int = int(SHIP_PRICES[module_id])
    if wallet < cost:
        return _error("Zu wenig Geld: %d EUR erforderlich" % cost)
    ship_modules[module_id] = true
    _chronicle("space","Raumschiffmodul installiert: " + module_id)
    return _success("Modul installiert: %s" % module_id,-cost)

func upgrade_vehicle(vehicle_id: String, component: String, wallet: int) -> Dictionary:
    if vehicle_id.strip_edges().is_empty() or vehicle_id.length() > 96:
        return _error("Ungueltiges Fahrzeug")
    if not TUNES.has(component):
        return _error("Unbekanntes Fahrzeugteil")
    var parts: Dictionary = vehicle_tuning.get(vehicle_id,{})
    var rank: int = clampi(int(parts.get(component,0)),0,3)
    if rank >= 3:
        return _error("Maximale Tuning-Stufe erreicht")
    var cost: int = int(TUNE_BASE_PRICES[component])*(rank+1)
    if wallet < cost:
        return _error("Zu wenig Geld: %d EUR erforderlich" % cost)
    parts[component] = rank+1
    vehicle_tuning[vehicle_id] = parts
    _chronicle("garage","%s: %s auf Stufe %d" % [vehicle_id,component,rank+1])
    return _success("%s verbessert (+%d)" % [component,rank+1],-cost)

func tuning_for(vehicle_id: String) -> Dictionary:
    var tuning: Dictionary = vehicle_tuning.get(vehicle_id,{})
    return {"motor":clampi(int(tuning.get("motor",0)),0,3),
            "reifen":clampi(int(tuning.get("reifen",0)),0,3),
            "bremsen":clampi(int(tuning.get("bremsen",0)),0,3)}

func reveal_planet_secret(planet_id: String, secret_id: String) -> Dictionary:
    if planet_id.is_empty() or secret_id.is_empty():
        return _error("Ungueltige Entdeckung")
    var found: Array = discoveries.get(planet_id,[])
    if found.has(secret_id):
        return _error("Bereits entdeckt")
    found.append(secret_id)
    discoveries[planet_id] = found
    _chronicle("exploration", "%s: %s entdeckt" % [planet_id,secret_id])
    return award_activity("research","Planetenfund: %s" % planet_id,45)

func record_decision(event_id: String, title: String, reputation_delta: int = 0) -> Dictionary:
    if event_id.is_empty():
        return _error("Ungueltiges Ereignis")
    if milestones.has(event_id):
        return _error("Entscheidung bereits gespeichert")
    milestones[event_id] = {"title":title,"reputation":clampi(reputation_delta,-10,10)}
    _chronicle("decision",title)
    return _success("Entscheidung dauerhaft gespeichert",0)

func record_world_day() -> void:
    world_days = mini(world_days+1,99999)
    if world_days == 1 or world_days%7 == 0:
        _chronicle("world","Tag %d in der NEXUS-Welt" % world_days)

func _chronicle(category: String, detail: String) -> void:
    events.append({"category":category,"text":detail.substr(0,200),"day":world_days})
    while events.size() > MAX_HISTORY:
        events.pop_front()
    state_changed.emit(detail)

func _success(message: String, money_delta: int) -> Dictionary:
    state_changed.emit(message)
    return {"ok":true,"message":message,"money":money_delta}

func _error(message: String) -> Dictionary:
    return {"ok":false,"message":message,"money":0}

func summary() -> String:
    return "%s | %s | Level %d | XP %d/%d | Talentpunkte %d | Eigentum %d | Chronik %d" % [callsign,career,level,xp,required_xp(),skill_points,properties.size(),events.size()]

func get_data() -> Dictionary:
    return {"version":VERSION,"callsign":callsign,"style":style,"career":career,
        "level":level,"xp":xp,"skill_points":skill_points,"skills":skills.duplicate(true),
        "relationships":relationships.duplicate(true),"properties":properties.duplicate(true),
        "ship_modules":ship_modules.duplicate(true),"vehicle_tuning":vehicle_tuning.duplicate(true),
        "discoveries":discoveries.duplicate(true),"events":events.duplicate(true),
        "achievements":achievements.duplicate(true),"milestones":milestones.duplicate(true),"world_days":world_days}

func restore_data(data: Dictionary) -> void:
    callsign = str(data.get("callsign","Explorer")).substr(0,24)
    if callsign.strip_edges().length() < 2:
        callsign = "Explorer"
    style = str(data.get("style","Explorer"))
    if not STYLES.has(style): style = "Explorer"
    career = str(data.get("career","Rettung"))
    if not CAREERS.has(career): career = "Rettung"
    level = clampi(int(data.get("level",1)),1,50)
    xp = clampi(int(data.get("xp",0)),0,required_xp()-1)
    skill_points = clampi(int(data.get("skill_points",0)),0,50)
    var raw_skills: Dictionary = data.get("skills",{}) if typeof(data.get("skills",{})) == TYPE_DICTIONARY else {}
    for key in skills.keys():
        skills[key] = clampi(int(raw_skills.get(key,0)),0,5)
    var raw_rels: Dictionary = data.get("relationships",{}) if typeof(data.get("relationships",{})) == TYPE_DICTIONARY else {}
    relationships.clear()
    for key in raw_rels.keys():
        if relationships.size() >= 64: break
        relationships[str(key).substr(0,40)] = clampi(int(raw_rels[key]),0,10)
    properties.clear()
    var raw_props: Dictionary = data.get("properties",{}) if typeof(data.get("properties",{})) == TYPE_DICTIONARY else {}
    for key in PROPERTY_PRICES.keys():
        if raw_props.has(key) and typeof(raw_props[key]) == TYPE_DICTIONARY:
            properties[key] = {"purchased":true,"condition":clampi(int(raw_props[key].get("condition",100)),0,100),"level":clampi(int(raw_props[key].get("level",1)),1,3)}
    ship_modules.clear()
    var raw_ship: Dictionary = data.get("ship_modules",{}) if typeof(data.get("ship_modules",{})) == TYPE_DICTIONARY else {}
    for key in SHIP_PRICES.keys():
        if bool(raw_ship.get(key,false)): ship_modules[key] = true
    vehicle_tuning.clear()
    var raw_tunes: Dictionary = data.get("vehicle_tuning",{}) if typeof(data.get("vehicle_tuning",{})) == TYPE_DICTIONARY else {}
    for key in raw_tunes.keys():
        if vehicle_tuning.size() >= 123: break
        if typeof(raw_tunes[key]) != TYPE_DICTIONARY: continue
        var tuned: Dictionary = {}
        for component in TUNES:
            tuned[component] = clampi(int(raw_tunes[key].get(component,0)),0,3)
        vehicle_tuning[str(key).substr(0,96)] = tuned
    discoveries.clear()
    var raw_discoveries: Dictionary = data.get("discoveries",{}) if typeof(data.get("discoveries",{})) == TYPE_DICTIONARY else {}
    for key in raw_discoveries.keys():
        if discoveries.size() >= 24: break
        if typeof(raw_discoveries[key]) == TYPE_ARRAY:
            discoveries[str(key).substr(0,40)] = raw_discoveries[key].slice(0,20)
    milestones = data.get("milestones",{}).duplicate(true) if typeof(data.get("milestones",{})) == TYPE_DICTIONARY else {}
    if milestones.size() > 256: milestones.clear()
    achievements = data.get("achievements",{}).duplicate(true) if typeof(data.get("achievements",{})) == TYPE_DICTIONARY else {}
    if achievements.size() > 256: achievements.clear()
    events.clear()
    var raw_events: Array = data.get("events",[]) if typeof(data.get("events",[])) == TYPE_ARRAY else []
    for record in raw_events.slice(maxi(0,raw_events.size()-MAX_HISTORY)):
        if typeof(record) == TYPE_DICTIONARY:
            events.append({"category":str(record.get("category","world")).substr(0,32),
                "text":str(record.get("text","")).substr(0,200),"day":clampi(int(record.get("day",0)),0,99999)})
    world_days = clampi(int(data.get("world_days",0)),0,99999)
    state_changed.emit("Chronik geladen")
