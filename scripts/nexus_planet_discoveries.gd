extends Node3D
class_name NexusPlanetDiscoveries
## Three secrets per planet; separate exploration from the linear mission objective.
## Persists each found secret in the shared star campaign save.
signal discovery_found(message: String)
const CAMPAIGN = preload("res://scripts/nexus_campaign.gd")
const OFFSETS: Array[Vector2] = [Vector2(-116,85),Vector2(105,107),Vector2(18,-124)]
var actor: Node3D
var pid: String = "terra"
var state: Dictionary = {}
var markers: Array[Node3D] = []
var elapsed: float = 0.0

func bind_planet(player_node: Node3D, planet_id: String, shared_campaign: Dictionary) -> void:
    actor = player_node
    pid = planet_id
    state = shared_campaign
    var collection: Dictionary = state.get("planet_discoveries",{})
    var found: Array = collection.get(pid,[])
    for i in range(OFFSETS.size()):
        var artifact := Node3D.new()
        artifact.name = "Versteckter Planetenfund %d" % (i+1)
        var p: Vector2 = OFFSETS[i]
        var terrain_y: float = 0.0
        if get_parent() != null and get_parent().has_method("height_at"):
            terrain_y = get_parent().height_at(p.x,p.y)
        artifact.position = Vector3(p.x,terrain_y+1.6,p.y)
        add_child(artifact)
        var visual := MeshInstance3D.new()
        var mesh := SphereMesh.new()
        mesh.radius = 0.58
        mesh.height = 1.16
        visual.mesh = mesh
        var mat := StandardMaterial3D.new()
        mat.albedo_color = Color("74c7eb")
        mat.metallic = 0.65
        mat.roughness = 0.18
        mat.emission_enabled = true
        mat.emission = Color("267b9a")
        visual.material_override = mat
        artifact.add_child(visual)
        artifact.visible = not found.has(i)
        markers.append(artifact)

func _process(delta: float) -> void:
    if actor == null:
        return
    elapsed += delta
    if elapsed < 0.2:
        return
    elapsed = 0.0
    for i in range(markers.size()):
        var marker: Node3D = markers[i]
        if marker.visible:
            marker.rotate_y(0.25)
            var pxz := Vector2(actor.global_position.x,actor.global_position.z)
            var mxyz := Vector2(marker.global_position.x,marker.global_position.z)
            if pxz.distance_to(mxyz) < 3.5:
                _collect(i)

func _collect(index: int) -> void:
    if index < 0 or index >= markers.size() or not markers[index].visible:
        return
    markers[index].visible = false
    var discoveries: Dictionary = state.get("planet_discoveries",{})
    var found: Array = discoveries.get(pid,[])
    if found.has(index):
        return
    found.append(index)
    discoveries[pid] = found
    state["planet_discoveries"] = discoveries
    state["credits"] = int(state.get("credits",0)) + 75
    var events: Array = state.get("events",[])
    events.append("%s: Geheimnis Nr. %d entdeckt" % [pid,index+1])
    while events.size() > 30:
        events.pop_front()
    state["events"] = events
    if CAMPAIGN.save_data(state):
        discovery_found.emit("Fund entdeckt: NEXUS-Fragment %d/3 | +75 Credits" % (index+1))
    else:
        discovery_found.emit("Datenfund erfasst; Speichern fehlgeschlagen")

func remaining() -> int:
    var count := 0
    for item in markers:
        if item.visible:
            count += 1
    return count
