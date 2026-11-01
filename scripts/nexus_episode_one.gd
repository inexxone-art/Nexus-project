extends Node3D
class_name NexusEpisodeOne
## Playable mission vertical slice. The AI is deliberately basic and local, not a
## full open-world combat, multiplayer or 48-hour campaign implementation.
signal objective_changed(message: String)
signal chapter_completed(reward: int)
signal player_hit(damage: float)

const CHAPTER_ID := "episode_berglicht"
const HUB := Vector3(-17.0,0.0,31.0)
const SUBSTATION := Vector3(8.0,0.0,41.0)
const RESCUE_SITE := Vector3(77.0,0.0,75.0)
const TRANSMITTER := Vector3(117.0,0.0,109.0)
const PORT := Vector3(55.0,0.0,66.0)
const OBJECTIVES: Array[String] = [
    "Einsatzbesprechung in der NEXUS-Zentrale (E)",
    "Umspannwerk untersuchen und Notstrom einschalten (E)",
    "Vermisste Person im Canyon finden (E)",
    "Verletzte Person stabilisieren (E)",
    "Sektor 31: Zwei feindliche Drohnen ausschalten (Linksklick / FEUER)",
    "Sektor 31: Den verschluesselten Datentraeger sichern (E)",
    "Raumhafen: Das NEXUS-Signal kalibrieren (E)",
    "Zur Einsatzzentrale zur Nachbesprechung (E)",
    "Kapitel abgeschlossen: Freies Spiel und weitere Missionen"
]
const WAYPOINTS: Array[Vector3] = [HUB,SUBSTATION,RESCUE_SITE,RESCUE_SITE,TRANSMITTER,TRANSMITTER,PORT,HUB,HUB]
const REWARD := 950
const INTERACT_RANGE := 5.5
const ENEMY_COUNT := 2

var stage: int = 0
var completed: bool = false
var rescued: bool = false
var emergency_power: bool = false
var evidence: bool = false
var calibrated: bool = false
var enemy_hp: Array[int] = [3,3]
var enemies: Array[StaticBody3D] = []
var enemy_meshes: Array[MeshInstance3D] = []
var attack_cooldown: float = 1.8
var elapsed: float = 0.0
var waypoint: Node3D
var ring: MeshInstance3D
var waypoint_label: Label3D
var world_player: CharacterBody3D
var environment_group: Node3D
var injury_label: Label3D
var mission_flags: Dictionary = {}

func _ready() -> void:
    name = "NEXUS | Operation Berglicht"
    _create_story_locations()
    _create_enemies()
    _create_waypoint()
    _apply_visual_state()

func bind_player(actor: CharacterBody3D) -> void:
    world_player = actor

func _material(color: Color, metal: float = 0.0, lit: bool = false) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = color
    mat.metallic = metal
    mat.roughness = 0.44 if metal > 0.0 else 0.72
    if lit:
        mat.emission_enabled = true
        mat.emission = color
        mat.emission_energy_multiplier = 1.8
    return mat

func _cube(parent: Node3D, title: String, position: Vector3, size: Vector3, material: Material, collidable: bool = false) -> Node3D:
    var object: Node3D = StaticBody3D.new() if collidable else Node3D.new()
    object.name = title
    object.position = position
    parent.add_child(object)
    var mesh := MeshInstance3D.new()
    var shape := BoxMesh.new()
    shape.size = size
    mesh.mesh = shape
    mesh.material_override = material
    object.add_child(mesh)
    if collidable:
        var collision := CollisionShape3D.new()
        var box := BoxShape3D.new()
        box.size = size
        collision.shape = box
        object.add_child(collision)
    return object

func _label(parent: Node3D, title: String, at: Vector3, color: Color = Color("aee7ff")) -> Label3D:
    var tag := Label3D.new()
    tag.text = title
    tag.position = at
    tag.billboard = BaseMaterial3D.BILLBOARD_ENABLED
    tag.font_size = 33
    tag.pixel_size = 0.008
    tag.modulate = color
    parent.add_child(tag)
    return tag

func _create_story_locations() -> void:
    environment_group = Node3D.new()
    environment_group.name = "Handgefertigte Episodenschauplaetze"
    add_child(environment_group)
    var steel := _material(Color("637b82"),0.7)
    var concrete := _material(Color("87959b"))
    var danger := _material(Color("e94f3e"),0.1,true)
    var blue := _material(Color("58bfe6"),0.1,true)
    # Functional scenery: transformer, relay panel, crashed field equipment.
    var station := Node3D.new()
    station.position = SUBSTATION + Vector3(4,0,0)
    station.name = "Umspannwerk Notstromanlage"
    environment_group.add_child(station)
    for i in range(3):
        _cube(station,"Transformator-%d"%i,Vector3(float(i)*1.35,0.9,0),Vector3(1.0,1.8,1.3),steel,true)
        _cube(station,"Warnlicht-%d"%i,Vector3(float(i)*1.35,1.85,0),Vector3(0.42,0.12,0.35),danger)
    _label(station,"NOTSTROM / E",Vector3(1.2,3.2,0))
    var rescue := Node3D.new()
    rescue.name = "Bergrettung Berglicht"
    rescue.position = RESCUE_SITE
    environment_group.add_child(rescue)
    _cube(rescue,"Rettungstrage",Vector3(1.5,0.42,0),Vector3(2.15,0.18,0.7),concrete)
    _cube(rescue,"Erste Hilfe Kasten",Vector3(-1.3,0.48,1.1),Vector3(0.55,0.45,0.35),danger)
    _cube(rescue,"Verletzte Person",Vector3(1.5,0.64,0),Vector3(1.5,0.24,0.46),_material(Color("c39875")))
    injury_label = _label(rescue,"SOS - SIGNAL EMPFANGEN",Vector3(1,2.4,0))
    var transmitter := Node3D.new()
    transmitter.name = "Sektor 31 Ermittlung"
    transmitter.position = TRANSMITTER
    environment_group.add_child(transmitter)
    _cube(transmitter,"Datenkonsole",Vector3(0,1.0,0),Vector3(2.3,2.0,1.1),steel,true)
    _cube(transmitter,"Signalpanel",Vector3(0,1.3,0.59),Vector3(1.5,0.95,0.1),blue)
    _label(transmitter,"SEKTOR 31 / DATEN",Vector3(0,3.0,0))
    var pad := Node3D.new()
    pad.name = "Raumhafen Signalknoten"
    pad.position = PORT + Vector3(4,0,0)
    environment_group.add_child(pad)
    _cube(pad,"Antennenfuss",Vector3(0,0.55,0),Vector3(3,1.1,3),concrete,true)
    for i in range(3):
        _cube(pad,"Antennenarm %d"%i,Vector3((i-1)*0.8,2.25,0),Vector3(0.2,3.0,0.3),steel)
    _cube(pad,"NEXUS Sendekern",Vector3(0,3.9,0),Vector3(0.75,0.8,0.75),blue)
    _label(pad,"NEXUS - FREQUENZ / E",Vector3(0,5.4,0))

func _create_enemies() -> void:
    var shell := _material(Color("b03d46"),0.75)
    var optic := _material(Color("faab61"),0.25,true)
    for i in range(ENEMY_COUNT):
        var drone := StaticBody3D.new()
        drone.name = "Abwehrdrohne %d" % (i+1)
        drone.position = TRANSMITTER + Vector3(-5.0 if i == 0 else 5.0,2.0, -6.0)
        drone.set_meta("episode_enemy_index",i)
        add_child(drone)
        var shape := CollisionShape3D.new()
        var collision := SphereShape3D.new()
        collision.radius = 0.95
        shape.shape = collision
        drone.add_child(shape)
        var body := MeshInstance3D.new()
        var sphere := SphereMesh.new()
        sphere.radius = 0.86
        sphere.height = 1.58
        body.mesh = sphere
        body.material_override = shell
        drone.add_child(body)
        var eye := MeshInstance3D.new()
        var cube := BoxMesh.new()
        cube.size = Vector3(0.46,0.18,0.16)
        eye.mesh = cube
        eye.material_override = optic
        eye.position = Vector3(0,0,-0.8)
        drone.add_child(eye)
        enemies.append(drone)
        enemy_meshes.append(body)

func _create_waypoint() -> void:
    waypoint = Node3D.new()
    waypoint.name = "Aktuelles Story Ziel"
    add_child(waypoint)
    ring = MeshInstance3D.new()
    var cylinder := CylinderMesh.new()
    cylinder.top_radius = 1.1
    cylinder.bottom_radius = 1.1
    cylinder.height = 0.075
    ring.mesh = cylinder
    ring.position.y = 0.14
    ring.material_override = _material(Color("46d5de"),0.1,true)
    waypoint.add_child(ring)
    waypoint_label = _label(waypoint,"EPISODE 01",Vector3(0,3.6,0))
    _refresh_waypoint()

func _refresh_waypoint() -> void:
    if waypoint == null: return
    waypoint.position = WAYPOINTS[stage]
    waypoint.visible = not completed
    waypoint_label.text = "BERGLICHT %d/8" % mini(stage+1,8)

func objective() -> String:
    return OBJECTIVES[stage]

func distance_to_target(position: Vector3) -> int:
    var point := WAYPOINTS[stage]
    return roundi(Vector2(position.x,position.z).distance_to(Vector2(point.x,point.z)))

func _is_close(p: Vector3, point: Vector3) -> bool:
    return Vector2(p.x,p.z).distance_to(Vector2(point.x,point.z)) <= INTERACT_RANGE

func try_interact(p: Vector3) -> Dictionary:
    if completed or stage == 4 or not _is_close(p,WAYPOINTS[stage]):
        return {"handled":false}
    match stage:
        0:
            _advance("Einsatz gestartet: Umspannwerk und Rettungssignal untersuchen")
        1:
            emergency_power = true
            _advance("Notstrom wiederhergestellt. Ein Notsignal wurde empfangen")
        2:
            _advance("Vermisste Person gefunden. Versorgung erforderlich")
        3:
            rescued = true
            _advance("Verletzte Person stabilisiert. Unbekannte Drohnen bei Sektor 31")
        5:
            evidence = true
            _advance("Datentraeger gesichert. Frequenz zum Raumhafen verfolgen")
        6:
            calibrated = true
            _advance("Signal erfolgreich kalibriert. Zurueck zur Einsatzleitung")
        7:
            if not (emergency_power and rescued and evidence and calibrated):
                return {"handled":true,"message":"Unvollstaendiger Einsatz. Pruefe alle Auftraege","money":0}
            completed = true
            stage = 8
            mission_flags["chapter_complete"] = true
            _refresh_waypoint()
            chapter_completed.emit(REWARD)
            objective_changed.emit(OBJECTIVES[stage])
            return {"handled":true,"completed":true,"money":REWARD,"message":"OPERATION BERGLICHT ABGESCHLOSSEN | +%d EUR"%REWARD}
    return {"handled":true,"money":0,"message":OBJECTIVES[stage]}

func _advance(message: String) -> void:
    stage = mini(stage+1,8)
    mission_flags["last_event"] = message
    _apply_visual_state()
    _refresh_waypoint()
    objective_changed.emit(message)

func shoot(from: Vector3, to: Vector3, space: PhysicsDirectSpaceState3D) -> Dictionary:
    if completed or stage != 4 or space == null:
        return {"handled":false}
    var query := PhysicsRayQueryParameters3D.create(from,to)
    if world_player != null:
        query.exclude = [world_player.get_rid()]
    var hit: Dictionary = space.intersect_ray(query)
    var body: Object = hit.get("collider")
    if body == null or not body.has_meta("episode_enemy_index"):
        return {"handled":false}
    var i: int = int(body.get_meta("episode_enemy_index"))
    if i < 0 or i >= ENEMY_COUNT or enemy_hp[i] <= 0:
        return {"handled":false}
    return _damage_enemy(i)

func _damage_enemy(i: int) -> Dictionary:
    if i < 0 or i >= ENEMY_COUNT or enemy_hp[i] <= 0 or stage != 4:
        return {"handled":false}
    enemy_hp[i] = maxi(0,enemy_hp[i]-1)
    _apply_visual_state()
    var all_disabled: bool = true
    for hp in enemy_hp:
        if hp > 0:
            all_disabled = false
            break
    if all_disabled:
        _advance("Beide Abwehrdrohnen deaktiviert. Sektor 31 ist zugaenglich")
        return {"handled":true,"message":"Abwehrdrohnen deaktiviert. Sichere jetzt die Daten"}
    return {"handled":true,"message":"Abwehrdrohne Treffer! Integritaet %d/3"%enemy_hp[i]}

func _process(delta: float) -> void:
    elapsed += delta
    if ring != null:
        ring.rotation.y += delta*0.55
    if world_player == null or stage != 4 or completed:
        return
    attack_cooldown -= delta
    var player_pos: Vector3 = world_player.global_position
    for i in range(ENEMY_COUNT):
        var drone := enemies[i]
        if enemy_hp[i] <= 0: continue
        var orbit: float = elapsed * (0.53 if i == 0 else -0.43) + i*PI
        drone.global_position = TRANSMITTER + Vector3((-5.0 if i==0 else 5.0)+sin(orbit)*2.4, 2.5+sin(elapsed*2.3+i)*0.38, -6.0+cos(orbit)*1.6)
        if drone.global_position.distance_to(player_pos) < 22.0:
            drone.look_at(player_pos+Vector3.UP,Vector3.UP)
    if attack_cooldown <= 0.0 and _is_close(player_pos,TRANSMITTER):
        var active: int = 0
        for hp in enemy_hp:
            if hp > 0: active += 1
        if active > 0:
            player_hit.emit(4.0*active)
            attack_cooldown = 2.6

func _apply_visual_state() -> void:
    for i in range(ENEMY_COUNT):
        if enemies.size() <= i: continue
        var is_alive: bool = stage >= 4 and stage <= 5 and enemy_hp[i] > 0
        enemies[i].visible = is_alive
        enemies[i].collision_layer = 1 if is_alive else 0
        enemies[i].collision_mask = 1 if is_alive else 0
    if injury_label != null:
        injury_label.text = "PATIENT STABILISIERT" if rescued else "SOS - SIGNAL EMPFANGEN"

func get_data() -> Dictionary:
    return {"version":1,"stage":stage,"completed":completed,"rescued":rescued,
        "emergency_power":emergency_power,"evidence":evidence,"calibrated":calibrated,
        "enemy_hp":enemy_hp.duplicate(),"mission_flags":mission_flags.duplicate(true)}

func restore_data(data: Dictionary) -> void:
    stage = clampi(int(data.get("stage",0)),0,8)
    completed = bool(data.get("completed",false)) or stage == 8
    if completed: stage = 8
    rescued = bool(data.get("rescued",false))
    emergency_power = bool(data.get("emergency_power",false))
    evidence = bool(data.get("evidence",false))
    calibrated = bool(data.get("calibrated",false))
    var saved: Array = data.get("enemy_hp",[3,3])
    for i in range(ENEMY_COUNT):
        enemy_hp[i] = clampi(int(saved[i]) if i < saved.size() else 3,0,3)
    var flags: Variant = data.get("mission_flags",{})
    mission_flags = flags.duplicate(true) if flags is Dictionary else {}
    _apply_visual_state()
    _refresh_waypoint()
