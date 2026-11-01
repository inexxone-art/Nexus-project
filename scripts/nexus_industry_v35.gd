extends Node3D
class_name NexusIndustryV35
## Supply-chain gameplay slice: quarry -> ore/stone -> smelter/cement -> roads,
## offshore oil rig -> refinery -> bitumen/diesel -> asphalt. Deterministic transactions.
signal inventory_changed
const SITES: Dictionary = {
    "quarry": {"name":"Steinbruch","position":Vector3(-115,0,-78),"wood":2,"iron":1,"cash":120},
    "smelter": {"name":"Schmelzofen","position":Vector3(-89,0,-60),"wood":3,"iron":2,"cash":240},
    "oilrig": {"name":"Oelbohrplattform","position":Vector3(-178,0,166),"wood":3,"iron":2,"cash":430},
    "refinery": {"name":"Raffinerie","position":Vector3(-102,0,65),"wood":2,"iron":2,"cash":280},
    "cement": {"name":"Zementwerk","position":Vector3(-52,0,-43),"wood":2,"iron":2,"cash":240},
    "asphalt": {"name":"Asphaltmischanlage","position":Vector3(-39,0,-43),"wood":2,"iron":2,"cash":260}
}
const ACTIONS: Dictionary = {
    "quarry": {"label":"Gestein abbauen","site":"quarry","input":{},"output":{"iron_ore":4,"limestone":3,"sand":2,"gravel":3}},
    "smelter": {"label":"Eisenerz schmelzen","site":"smelter","input":{"iron_ore":3},"wood":1,"output":{"iron":3}},
    "oilrig": {"label":"Rohoel foerdern","site":"oilrig","input":{},"output":{"crude":5}},
    "refinery": {"label":"Rohoel raffinieren","site":"refinery","input":{"crude":3},"output":{"bitumen":2,"diesel":2}},
    "cement": {"label":"Zement herstellen","site":"cement","input":{"limestone":3,"sand":1},"output":{"cement":3}},
    "asphalt": {"label":"Asphalt mischen","site":"asphalt","input":{"gravel":3,"bitumen":1},"output":{"asphalt":4}}
}
const INITIAL: Dictionary = {"iron_ore":0,"limestone":0,"sand":0,"gravel":0,"crude":0,"diesel":0,"bitumen":0,"cement":0,"asphalt":0}
var inventory: Dictionary = INITIAL.duplicate(true)
var built: Dictionary = {}
var site_nodes: Dictionary = {}
var last_action: String = ""

func _ready() -> void:
    name = "NEXUS | Six-stage industrial supply chain"
    for id in SITES.keys():
        var site: Dictionary = SITES[id]
        var stage := Node3D.new()
        stage.name = "Industrial site | "+str(site["name"])
        stage.position = site["position"]
        add_child(stage)
        site_nodes[id] = stage
        _show_site(id)

func _box(parent: Node3D, label: String, p: Vector3, size: Vector3, color: Color) -> void:
    var mesh := BoxMesh.new()
    mesh.size = size
    var visual := MeshInstance3D.new()
    visual.name = label
    visual.mesh = mesh
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = 0.35
    m.roughness = 0.65
    visual.material_override = m
    visual.position = p
    parent.add_child(visual)

func _show_site(id: String) -> void:
    var root: Node3D = site_nodes[id]
    for child in root.get_children():
        child.queue_free()
    var done := built.has(id)
    _box(root,"Work pad",Vector3(0,0.12,0),Vector3(12,0.24,10),Color("535554"))
    if not done:
        _box(root,"Construction stakes",Vector3(-4,1,0),Vector3(0.25,2.0,0.25),Color("c98c38"))
        return
    _box(root,"Industrial building",Vector3(0,2.5,0),Vector3(9,4.8,7),Color("727b80"))
    _box(root,"Steel roof",Vector3(0,5.1,0),Vector3(10,0.4,8),Color("424950"))
    if id == "oilrig":
        _box(root,"Drilling derrick",Vector3(0,14,0),Vector3(1.1,18,1.1),Color("b18645"))
        _box(root,"Pump arm",Vector3(0,21,0),Vector3(8,0.45,0.65),Color("c19b54"))
    elif id == "smelter":
        _box(root,"Furnace chimney",Vector3(2,9,1),Vector3(2.3,10,2.3),Color("54483f"))
    elif id == "cement":
        for x in [-2.0,2.0]:
            _box(root,"Cement silo",Vector3(x,9,0),Vector3(3,9,3),Color("d0c8b7"))
    elif id == "refinery":
        for x in [-2.0,2.0]:
            _box(root,"Distillation column",Vector3(x,10,0),Vector3(2,11,2),Color("a2abb2"))
    elif id == "asphalt":
        _box(root,"Mixer drum",Vector3(0,7.0,0),Vector3(4,3.5,4),Color("454c53"))

func near_site(id: String, position: Vector3, radius: float = 23.0) -> bool:
    if not SITES.has(id):
        return false
    var target: Vector3 = SITES[id]["position"]
    return Vector2(position.x-target.x,position.z-target.z).length() <= radius

func build_site(id: String, position: Vector3, wood: int, iron: int, cash: int) -> Dictionary:
    if not SITES.has(id):
        return {"ok":false,"message":"Unbekannte Industrieanlage"}
    if built.has(id):
        return {"ok":false,"message":"Anlage existiert bereits"}
    var info: Dictionary = SITES[id]
    if not near_site(id,position):
        return {"ok":false,"message":"Fahre zum Bauplatz von "+str(info["name"])}
    if wood < int(info["wood"]) or iron < int(info["iron"]) or cash < int(info["cash"]):
        return {"ok":false,"message":"Bau benoetigt: %d Holz, %d Eisen, %d Credits" % [info["wood"],info["iron"],info["cash"]]}
    built[id] = true
    _show_site(id)
    inventory_changed.emit()
    return {"ok":true,"wood":-int(info["wood"]),"iron":-int(info["iron"]),"money":-int(info["cash"]),"message":str(info["name"])+" errichtet. Jetzt vor Ort produzieren."}

func operate(id: String, position: Vector3, wood: int) -> Dictionary:
    if not ACTIONS.has(id) or not SITES.has(id):
        return {"ok":false,"message":"Keine Produktionsanlage"}
    if not built.has(id):
        return {"ok":false,"message":"Zuerst Anlage bauen: "+str(SITES[id]["name"])}
    if not near_site(id,position):
        return {"ok":false,"message":"Fahre zur Anlage: "+str(SITES[id]["name"])}
    var recipe: Dictionary = ACTIONS[id]
    var wood_cost := int(recipe.get("wood",0))
    if wood < wood_cost:
        return {"ok":false,"message":"Schmelzofen braucht %d Holz als Brennstoff" % wood_cost}
    var needs: Dictionary = recipe["input"]
    for key in needs.keys():
        if int(inventory.get(key,0)) < int(needs[key]):
            return {"ok":false,"message":"Es fehlen %d %s" % [int(needs[key])-int(inventory.get(key,0)),str(key)]}
    for key in needs.keys():
        inventory[key] = int(inventory.get(key,0))-int(needs[key])
    var outputs: Dictionary = recipe["output"]
    var iron_gain := 0
    for key in outputs.keys():
        if key == "iron":
            iron_gain += int(outputs[key])
        else:
            inventory[key] = int(inventory.get(key,0))+int(outputs[key])
    last_action = str(recipe["label"])
    inventory_changed.emit()
    return {"ok":true,"wood":-wood_cost,"iron":iron_gain,"money":0,"message":last_action+" | Produktion abgeschlossen"}

func take_materials(cement_units: int, asphalt_units: int) -> bool:
    if cement_units < 0 or asphalt_units < 0:
        return false
    if int(inventory.get("cement",0)) < cement_units or int(inventory.get("asphalt",0)) < asphalt_units:
        return false
    inventory["cement"] = int(inventory["cement"])-cement_units
    inventory["asphalt"] = int(inventory["asphalt"])-asphalt_units
    inventory_changed.emit()
    return true

func summary() -> String:
    return "Erz %d Kalk %d Kies %d Rohoel %d Bitumen %d Diesel %d Zement %d Asphalt %d" % [inventory["iron_ore"],inventory["limestone"],inventory["gravel"],inventory["crude"],inventory["bitumen"],inventory["diesel"],inventory["cement"],inventory["asphalt"]]

func get_data() -> Dictionary:
    return {"inventory":inventory.duplicate(true),"built":built.duplicate(true),"last_action":last_action}

func restore_data(data: Dictionary) -> void:
    inventory = INITIAL.duplicate(true)
    var saved: Dictionary = data.get("inventory",{})
    for key in INITIAL.keys():
        inventory[key] = clampi(int(saved.get(key,0)),0,100000)
    built.clear()
    for id in data.get("built",{}).keys():
        if SITES.has(id) and bool(data["built"][id]):
            built[id] = true
    last_action = str(data.get("last_action",""))
    for id in SITES.keys():
        _show_site(id)
    inventory_changed.emit()
