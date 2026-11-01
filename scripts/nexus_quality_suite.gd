extends Node3D
class_name NexusQualitySuite
## V2.0 integrated vertical-slice systems: accessible interior, daily NPC routines,
## destructible/repairable world objects, target practice and hidden discoveries.
## Primitive geometry is original placeholder art, not photorealistic licensed assets.

signal interaction_result(message: String, credit_delta: int)
const HUB := Vector3(-17.0, 0.0, 31.0)
const NPC_NAMES: Array[String] = ["Mara | Einsatzleitung", "Noah | Mechaniker", "Lina | Forscherin", "Tarek | Rettung"]
const NPC_DIALOG: Array[String] = [
    "Wir verfolgen die Lage auf allen sechs Planeten. Finde die drei Datenkapseln.",
    "Fahrzeuge lassen sich bei der Werkstatt reparieren. Bei Naesse sinkt die Haftung.",
    "Auf Umbra liegen noch unerkannte Signaturen. Die Sternenkarte bleibt wichtig.",
    "Bei Schnee und Sturm veraendern sich Rettungswege. Achte auf die Einsatzzentrale.",
]
const SECRET_POSITIONS: Array[Vector3] = [Vector3(-81, 0, 113), Vector3(133, 0, 37), Vector3(-132, 0, -104)]
const INFRA_POSITIONS: Array[Vector3] = [Vector3(8, 0, 41), Vector3(-76, 0, 39), Vector3(65, 0, -22)]
const TRAINING_POSITIONS: Array[Vector3] = [Vector3(-24,0,60), Vector3(-17,0,62), Vector3(-10,0,60)]

var world: Node3D
var civilian_nodes: Array[Node3D] = []
var infrastructure: Array[Dictionary] = []
var secrets: Array[Dictionary] = []
var targets: Array[Dictionary] = []
var door: Node3D
var door_open: bool = false
var score: int = 0
var elapsed: float = 0.0
var enabled_scenery: bool = true

func _ready() -> void:
    name = "NEXUS | Integrated Living World 2.0"
    _build_hub()
    _build_civilians()
    _build_infrastructure()
    _build_secrets()
    _build_training()

func bind_world(source: Node3D) -> void:
    world = source

func _material(tint: Color, texture_name: String = "", emission: bool = false) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = tint
    m.roughness = 0.58
    if texture_name != "" and ResourceLoader.exists("res://assets/%s.png" % texture_name):
        m.albedo_texture = load("res://assets/%s.png" % texture_name)
        m.uv1_scale = Vector3(2,2,1)
    if emission:
        m.emission_enabled = true
        m.emission = tint
        m.emission_energy_multiplier = 1.3
    return m

func _block(parent: Node3D, title: String, at: Vector3, size: Vector3, material: Material, solid: bool = false) -> Node3D:
    var node: Node3D = StaticBody3D.new() if solid else Node3D.new()
    node.name = title
    node.position = at
    parent.add_child(node)
    var mesh := MeshInstance3D.new()
    var box := BoxMesh.new()
    box.size = size
    mesh.mesh = box
    mesh.material_override = material
    node.add_child(mesh)
    if solid:
        var collision := CollisionShape3D.new()
        var shape := BoxShape3D.new()
        shape.size = size
        collision.shape = shape
        node.add_child(collision)
    return node

func _build_hub() -> void:
    var hub := Node3D.new()
    hub.name = "Begehbare NEXUS Einsatzzentrale"
    hub.position = HUB
    add_child(hub)
    var concrete := _material(Color("aebac1"),"nexus_pbr_stone")
    var steel := _material(Color("3d4d59"),"metal")
    var glass := _material(Color("5f9bb2"))
    glass.metallic = 0.22
    glass.roughness = 0.19
    var luminous := _material(Color("66cbea"),"",true)
    _block(hub,"Begehbarer Fussboden",Vector3(0,0.12,0),Vector3(14,0.25,12),concrete,true)
    _block(hub,"Hinterwand",Vector3(0,2.55,-5.9),Vector3(14,5.1,0.3),steel,true)
    _block(hub,"Linke Wand",Vector3(-6.9,2.55,0),Vector3(0.3,5.1,12),steel,true)
    _block(hub,"Rechte Wand",Vector3(6.9,2.55,0),Vector3(0.3,5.1,12),steel,true)
    _block(hub,"Front links",Vector3(-4.5,2.55,5.9),Vector3(5.0,5.1,0.3),concrete,true)
    _block(hub,"Front rechts",Vector3(4.5,2.55,5.9),Vector3(5.0,5.1,0.3),concrete,true)
    _block(hub,"Front Fenster",Vector3(-4.0,2.65,6.08),Vector3(3,1.7,0.09),glass)
    _block(hub,"Dach",Vector3(0,5.3,0),Vector3(14.5,0.32,12.5),steel,true)
    _block(hub,"Leuchtband",Vector3(0,4.65,-5.5),Vector3(9.0,0.20,0.16),luminous)
    for i in range(4):
        _block(hub,"Arbeitsplatz %d" % i,Vector3(-4.7+i*3.2,0.9,-2.3),Vector3(2.4,0.14,1.15),concrete)
        _block(hub,"Monitor %d" % i,Vector3(-4.7+i*3.2,1.54,-2.55),Vector3(1.65,0.9,0.12),luminous)
    door = Node3D.new()
    door.name = "Schwingtuer"
    door.position = Vector3(-1.85,0,5.9)
    hub.add_child(door)
    _block(door,"Tuerblatt",Vector3(0.92,1.3,0),Vector3(1.84,2.6,0.12),glass)
    var sign := Label3D.new()
    sign.text = "NEXUS OPS  |  E: TUER"
    sign.position = Vector3(0,3.5,6.2)
    sign.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    sign.font_size = 35
    sign.pixel_size = 0.009
    hub.add_child(sign)

func _build_civilians() -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = 186513
    for i in range(NPC_NAMES.size()):
        var npc := Node3D.new()
        npc.name = NPC_NAMES[i]
        npc.position = HUB + Vector3(-4.0 + float(i)*2.7,0,0)
        add_child(npc)
        var body := MeshInstance3D.new()
        var shape := CapsuleMesh.new()
        shape.radius = 0.35
        shape.height = 1.68
        body.mesh = shape
        body.position.y = 0.9
        body.material_override = _material(Color.from_hsv(float(i)*0.19+0.05,0.30,0.67))
        npc.add_child(body)
        var face := MeshInstance3D.new()
        var head := SphereMesh.new()
        head.radius = 0.25
        head.height = 0.50
        face.mesh = head
        face.position.y = 1.86
        face.material_override = _material(Color("bc9078"))
        npc.add_child(face)
        var title := Label3D.new()
        title.text = NPC_NAMES[i]
        title.position.y = 2.44
        title.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        title.font_size = 24
        title.pixel_size = 0.008
        npc.add_child(title)
        civilian_nodes.append(npc)

func _build_infrastructure() -> void:
    for i in range(INFRA_POSITIONS.size()):
        var base := Node3D.new()
        base.name = ["Umspannwerk", "Wasserpumpstation", "Kommunikationsmast"][i]
        base.position = INFRA_POSITIONS[i]
        add_child(base)
        _block(base,"Fundament",Vector3(0,0.3,0),Vector3(3.1,0.6,3.0),_material(Color("777d83"),"city_concrete"))
        var machine := _block(base,"Technik",Vector3(0,1.2,0),Vector3(1.6,1.5,1.3),_material(Color("617881"),"metal"))
        var display := Label3D.new()
        display.text = base.name + " | E: PRUEFEN"
        display.position.y = 3.1
        display.billboard = BaseMaterial3D.BILLBOARD_ENABLED
        display.font_size = 24
        display.pixel_size = 0.009
        base.add_child(display)
        infrastructure.append({"node":base,"machine":machine,"label":display,"condition":35+i*20})

func _build_secrets() -> void:
    for i in range(SECRET_POSITIONS.size()):
        var holder := Node3D.new()
        holder.name = "Geheimer NEXUS Datenspeicher %d" % (i+1)
        holder.position = SECRET_POSITIONS[i]
        add_child(holder)
        _block(holder,"Schutzbox",Vector3(0,0.65,0),Vector3(1.3,1.3,1.3),_material(Color("526d78"),"metal"))
        _block(holder,"Signalkern",Vector3(0,1.46,0),Vector3(0.7,0.23,0.7),_material(Color("68d7ea"),"",true))
        secrets.append({"node":holder,"found":false})

func _build_training() -> void:
    for i in range(TRAINING_POSITIONS.size()):
        var target := StaticBody3D.new()
        target.name = "Uebungsziel %d" % (i+1)
        target.position = TRAINING_POSITIONS[i]
        target.set_meta("nexus_target",i)
        add_child(target)
        var mesh := MeshInstance3D.new()
        var disc := CylinderMesh.new()
        disc.top_radius = 0.6
        disc.bottom_radius = 0.6
        disc.height = 0.16
        mesh.mesh = disc
        mesh.rotation.x = PI/2
        mesh.position.y = 1.65
        mesh.material_override = _material(Color("e69b55"))
        target.add_child(mesh)
        _block(target,"Zielstaender",Vector3(0,0.72,0),Vector3(0.12,1.45,0.12),_material(Color("5c6469"),"metal"))
        var collision := CollisionShape3D.new()
        var bounds := BoxShape3D.new()
        bounds.size = Vector3(1.25,1.3,0.5)
        collision.shape = bounds
        collision.position.y = 1.5
        target.add_child(collision)
        targets.append({"node":target,"hits":0})

func _process(delta: float) -> void:
    elapsed += delta
    # Lightweight visible routines, no full NPC cognition or pathfinding claim.
    for i in range(civilian_nodes.size()):
        var npc: Node3D = civilian_nodes[i]
        if not is_instance_valid(npc):
            continue
        var angle: float = elapsed*0.19 + float(i)*1.7
        npc.position = HUB + Vector3(-3.8+float(i)*2.45 + sin(angle)*1.3,0,cos(angle)*1.1)
        npc.rotation.y = angle + PI*0.5
    if door != null:
        door.rotation.y = lerp_angle(door.rotation.y, -PI*0.58 if door_open else 0.0, delta*5.0)

func _distance(a: Vector3,b: Vector3) -> float:
    return Vector2(a.x,a.z).distance_to(Vector2(b.x,b.z))

func try_interact(at: Vector3, available_credits: int) -> Dictionary:
    if _distance(at,HUB+Vector3(0,0,5.9)) < 3.1:
        door_open = not door_open
        return {"handled":true,"money":0,"message":"Einsatzzentrale: Tuer %s" % ("geoeffnet" if door_open else "geschlossen")}
    for i in range(civilian_nodes.size()):
        if _distance(at,civilian_nodes[i].global_position) < 2.3:
            return {"handled":true,"money":0,"message":NPC_DIALOG[i]}
    for i in range(infrastructure.size()):
        var item: Dictionary = infrastructure[i]
        var hp: int = int(item["condition"])
        if _distance(at,(item["node"] as Node3D).global_position) < 4.0:
            if hp >= 100:
                return {"handled":true,"money":0,"message":"%s: voll funktionsfaehig" % (item["node"] as Node3D).name}
            if available_credits < 75:
                return {"handled":true,"money":0,"message":"Reparatur erfordert 75 EUR"}
            item["condition"] = 100
            (item["label"] as Label3D).text = "%s | INSTAND GESETZT" % (item["node"] as Node3D).name
            return {"handled":true,"money":-75,"message":"Infrastruktur repariert: %s (-75 EUR)" % (item["node"] as Node3D).name}
    for i in range(secrets.size()):
        var secret: Dictionary = secrets[i]
        if not bool(secret["found"]) and _distance(at,(secret["node"] as Node3D).global_position) < 3.0:
            secret["found"] = true
            (secret["node"] as Node3D).visible = false
            return {"handled":true,"money":115,"message":"NEXUS Datenfragment %d entdeckt! +115 EUR" % (i+1)}
    return {"handled":false}

func practice_shot(from: Vector3, to: Vector3, state: PhysicsDirectSpaceState3D) -> Dictionary:
    if state == null:
        return {"handled":false}
    var hit: Dictionary = state.intersect_ray(PhysicsRayQueryParameters3D.create(from,to))
    var body: Object = hit.get("collider")
    if body != null and body.has_meta("nexus_target"):
        var index: int = int(body.get_meta("nexus_target"))
        if index >= 0 and index < targets.size():
            targets[index]["hits"] = int(targets[index]["hits"]) + 1
            score += 10
            return {"handled":true,"message":"Trainingsziel getroffen! Punktestand: %d" % score}
    return {"handled":false}

func set_scenery_quality(high: bool) -> void:
    enabled_scenery = high
    # Hide expensive decorative labels in mobile performance mode, keep interactions.
    for npc in civilian_nodes:
        if npc.get_child_count() > 2:
            npc.get_child(2).visible = high

func get_data() -> Dictionary:
    var conditions: Array[int] = []
    var found: Array[bool] = []
    for item in infrastructure:
        conditions.append(int(item["condition"]))
    for item in secrets:
        found.append(bool(item["found"]))
    return {"conditions":conditions,"found":found,"score":score,"door_open":door_open}

func restore_data(data: Dictionary) -> void:
    var conditions: Array = data.get("conditions",[])
    for i in range(mini(conditions.size(),infrastructure.size())):
        infrastructure[i]["condition"] = clampi(int(conditions[i]),0,100)
    var found: Array = data.get("found",[])
    for i in range(mini(found.size(),secrets.size())):
        secrets[i]["found"] = bool(found[i])
        (secrets[i]["node"] as Node3D).visible = not bool(found[i])
    score = clampi(int(data.get("score",0)),0,1000000)
    door_open = bool(data.get("door_open",false))

func trigger_disaster(seed_value: int) -> void:
    if infrastructure.is_empty():
        return
    var i := posmod(seed_value,infrastructure.size())
    infrastructure[i]["condition"] = maxi(0,int(infrastructure[i]["condition"])-25)
    (infrastructure[i]["label"] as Label3D).text = "%s | STOERUNG" % (infrastructure[i]["node"] as Node3D).name
