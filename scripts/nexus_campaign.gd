extends RefCounted
class_name NexusCampaign
## Single-player story registry shared by the alpine world and the star system.
## A 48-hour campaign remains a production target, not an implemented claim.

const SAVE_PATH = "user://nexus_star_campaign_v12.json"
const PLANETS = [
    {"id":"terra", "name":"TERRA NOVA", "subtitle":"Alpine Heimatwelt", "biome":"alpine", "seed":12081,
     "color":Color("7fba97"), "size":2.5, "orbit":11.0, "period":80.0,
     "chapter":"AKT I: Das Signal im Eis", "objective":"Finde die verschollene Forschungskapsel."},
    {"id":"sahra", "name":"SAHRA IX", "subtitle":"Wuestenwelt der Sternenwracks", "biome":"desert", "seed":8332,
     "color":Color("d4a36c"), "size":2.1, "orbit":17.0, "period":115.0,
     "chapter":"AKT II: Das verschuettete Archiv", "objective":"Sichere den Datenspeicher im Sandsturm."},
    {"id":"nivora", "name":"NIVORA", "subtitle":"Eismond mit verlassener Station", "biome":"ice", "seed":34091,
     "color":Color("b8e8f4"), "size":1.85, "orbit":23.0, "period":144.0,
     "chapter":"AKT III: Funkspruch Null", "objective":"Reaktiviere den Sender der Eisstation."},
    {"id":"vesper", "name":"VESPER", "subtitle":"Biolumineszenter Dschungelplanet", "biome":"jungle", "seed":66801,
     "color":Color("3fbd8f"), "size":2.75, "orbit":30.0, "period":188.0,
     "chapter":"AKT IV: Der lebendige Code", "objective":"Untersuche die biologische Anomalie."},
    {"id":"ignis", "name":"IGNIS PRIME", "subtitle":"Vulkanische Industriewelt", "biome":"volcanic", "seed":90521,
     "color":Color("e47243"), "size":2.15, "orbit":38.0, "period":231.0,
     "chapter":"AKT V: Der Bruch im Kern", "objective":"Stoppe den Notfall am Energiekern."},
    {"id":"umbra", "name":"UMBRA", "subtitle":"Fremde Ruinen unter zwei Monden", "biome":"alien", "seed":44566,
     "color":Color("9e87db"), "size":2.3, "orbit":46.0, "period":290.0,
     "chapter":"AKT VI: Der NEXUS-Ursprung", "objective":"Berge das letzte Fragment aus den Ruinen."}
]

static func get_planet(pid: String) -> Dictionary:
    for planet in PLANETS:
        if str(planet["id"]) == pid:
            return planet
    return PLANETS[0]

static func default_data() -> Dictionary:
    return {"planet":"terra", "completed":[], "intel":0, "credits":200,
        "events":[], "choices":{}, "visits":{}, "planet_discoveries":{}, "mission_seed":42}

static func load_data() -> Dictionary:
    if not FileAccess.file_exists(SAVE_PATH):
        return default_data()
    var decoded = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
    if not decoded is Dictionary:
        return default_data()
    var clean = default_data()
    for k in clean.keys():
        if decoded.has(k) and typeof(decoded[k]) == typeof(clean[k]):
            clean[k] = decoded[k]
    return clean

static func save_data(data: Dictionary) -> bool:
    var f = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    if f == null:
        return false
    f.store_string(JSON.stringify(data, "  "))
    f.close()
    return true

static func complete_planet(data: Dictionary, pid: String, choice: int = 1) -> Dictionary:
    var output = data.duplicate(true)
    var done: Array = output.get("completed", [])
    if not done.has(pid):
        done.append(pid)
        output["intel"] = int(output.get("intel", 0)) + 1
        output["credits"] = int(output.get("credits", 0)) + 500
        var events: Array = output.get("events", [])
        events.append("%s: Kapitel abgeschlossen - Entscheidung %d" % [get_planet(pid)["name"], choice])
        if events.size() > 30:
            events.pop_front()
    var choices: Dictionary = output.get("choices", {})
    choices[pid] = choice
    output["choices"] = choices
    output["completed"] = done
    save_data(output)
    return output
