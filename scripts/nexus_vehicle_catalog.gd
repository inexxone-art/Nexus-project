extends RefCounted
class_name NexusVehicleCatalog
## Data-driven playable prototypes: 70 cars, 20 armored, 10 helicopters, 3 excavators, 20 service machines.
## Unique vehicle meshes, high-fidelity handling and manufacturer licenses are NOT included.
const CATALOG_PATH = "res://data/vehicle_catalog.json"
static var _cache: Array[Dictionary] = []

static func all() -> Array[Dictionary]:
    if _cache.is_empty():
        var parsed = JSON.parse_string(FileAccess.get_file_as_string(CATALOG_PATH))
        if parsed is Dictionary:
            for record in parsed.get("vehicles", []):
                if record is Dictionary:
                    _cache.append(record)
    return _cache

static func categories() -> Array[String]:
    return ["Alle", "Autos", "Panzer", "Helikopter", "Bagger", "Nutzfahrzeuge"]

static func by_id(vehicle_id: String) -> Dictionary:
    for record in all():
        if str(record.get("id", "")) == vehicle_id:
            return record
    return {}

static func filtered(category: String, needle: String = "") -> Array[Dictionary]:
    var found: Array[Dictionary] = []
    for record in all():
        if category != "Alle" and str(record.get("group", "")) != category:
            continue
        if needle != "" and not str(record.get("name", "")).to_lower().contains(needle.to_lower()):
            continue
        found.append(record)
    return found
