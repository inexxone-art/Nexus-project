extends Node3D
class_name NexusCoopPreview
## EXPERIMENTAL LAN avatar synchronization (host + four friends). Not authoritative gameplay coop.
## Mission/economy/combat cross-player state, NAT traversal and security still outstanding.
const PORT: int = 24561
const MAX_FRIENDS: int = 4
var actor: Node3D = null
var avatars: Dictionary = {}
var avatar_targets: Dictionary = {}
var avatar_headings: Dictionary = {}
var elapsed: float = 0.0
var layer: CanvasLayer
var panel: PanelContainer
var status: Label
var ip_text: LineEdit
var peer: ENetMultiplayerPeer

func _ready() -> void:
    name = "NEXUS COOP PREVIEW"
    multiplayer.peer_connected.connect(_on_peer_joined)
    multiplayer.peer_disconnected.connect(_on_peer_left)
    multiplayer.connected_to_server.connect(_on_connected)
    multiplayer.connection_failed.connect(_on_failed)
    _make_menu()

func set_actor(who: Node3D) -> void:
    actor = who

func _make_menu() -> void:
    layer = CanvasLayer.new()
    layer.layer = 24
    add_child(layer)
    panel = PanelContainer.new()
    panel.position = Vector2(22,115)
    panel.custom_minimum_size = Vector2(355,0)
    layer.add_child(panel)
    var column = VBoxContainer.new()
    panel.add_child(column)
    var title = Label.new()
    title.text = "NEXUS KOOP PREVIEW  //  LAN"
    title.add_theme_font_size_override("font_size",18)
    column.add_child(title)
    var explanation = Label.new()
    explanation.text = "Bis zu vier Freunde. Nur Avatar-Positionen werden synchronisiert."
    column.add_child(explanation)
    var host = Button.new()
    host.text = "LOKALE SITZUNG HOSTEN"
    host.pressed.connect(host_session)
    column.add_child(host)
    ip_text = LineEdit.new()
    ip_text.placeholder_text = "IP des Hosts, z.B. 192.168.1.42"
    ip_text.text = "127.0.0.1"
    column.add_child(ip_text)
    var join = Button.new()
    join.text = "LOKALER SITZUNG BEITRETEN"
    join.pressed.connect(join_session)
    column.add_child(join)
    var disconnect_button = Button.new()
    disconnect_button.text = "TRENNEN"
    disconnect_button.pressed.connect(disconnect_session)
    column.add_child(disconnect_button)
    status = Label.new()
    status.text = "OFFLINE - KEIN ONLINE-MATCHMAKING"
    column.add_child(status)
    var close = Button.new()
    close.text = "SCHLIESSEN / F7"
    close.pressed.connect(_toggle)
    column.add_child(close)
    panel.visible = false

func _toggle() -> void:
    panel.visible = not panel.visible
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if panel.visible else Input.MOUSE_MODE_CAPTURED

func host_session() -> void:
    disconnect_session()
    peer = ENetMultiplayerPeer.new()
    var err = peer.create_server(PORT,MAX_FRIENDS)
    if err == OK:
        multiplayer.multiplayer_peer = peer
        status.text = "HOST AKTIV - PORT %d - FREUNDE IM SELBEN NETZWERK" % PORT
    else:
        status.text = "Host konnte nicht gestartet werden (Code %d)" % err

func join_session() -> void:
    disconnect_session()
    peer = ENetMultiplayerPeer.new()
    var err = peer.create_client(ip_text.text.strip_edges(),PORT)
    if err == OK:
        multiplayer.multiplayer_peer = peer
        status.text = "Verbinde ..."
    else:
        status.text = "Verbindung nicht moeglich (Code %d)" % err

func disconnect_session() -> void:
    multiplayer.multiplayer_peer = OfflineMultiplayerPeer.new()
    if peer != null:
        peer.close()
        peer = null
    for p in avatars.values():
        if is_instance_valid(p):
            p.queue_free()
    avatars.clear()
    avatar_targets.clear()
    avatar_headings.clear()
    if status != null:
        status.text = "OFFLINE"

func _on_connected() -> void:
    status.text = "VERBUNDEN - AVATARE WERDEN SYNCHRONISIERT"

func _on_failed() -> void:
    status.text = "Verbindung fehlgeschlagen"

func _on_peer_joined(_id: int) -> void:
    if status != null:
        status.text = "Teilnehmer verbunden: %d" % multiplayer.get_peers().size()

func _on_peer_left(id: int) -> void:
    if avatars.has(id):
        avatars[id].queue_free()
        avatars.erase(id)
    avatar_targets.erase(id)
    avatar_headings.erase(id)

func _process(delta: float) -> void:
    for id in avatars.keys():
        var avatar: Node3D = avatars[id]
        if is_instance_valid(avatar) and avatar_targets.has(id):
            var desired: Vector3 = avatar_targets[id]
            avatar.global_position = avatar.global_position.lerp(desired,clampf(delta*9.0,0.0,1.0))
            avatar.rotation.y = lerp_angle(avatar.rotation.y,float(avatar_headings.get(id,0.0)),clampf(delta*10.0,0.0,1.0))
    if actor == null or multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
        return
    elapsed += delta
    if elapsed > 0.09:
        elapsed = 0.0
        _send_pose.rpc(actor.global_position,actor.rotation.y)

@rpc("any_peer","unreliable_ordered")
func _send_pose(pos: Vector3, heading: float) -> void:
    var id = multiplayer.get_remote_sender_id()
    if id == 0 or not pos.is_finite() or not is_finite(heading):
        return
    if pos.length() > 5000.0 or absf(heading) > 10000.0:
        return
    if avatar_targets.has(id) and avatar_targets[id].distance_to(pos) > 55.0:
        return # drop implausible single-tick movement, do not teleport remote avatars
    if not avatars.has(id):
        var model = Node3D.new()
        model.name = "Koop-Spieler-%d" % id
        add_child(model)
        var capsule = MeshInstance3D.new()
        var bodymesh = CapsuleMesh.new()
        bodymesh.radius = 0.38
        bodymesh.height = 1.78
        capsule.mesh = bodymesh
        capsule.position.y = 0.9
        var mat = StandardMaterial3D.new()
        mat.albedo_color = Color.from_hsv(float(id%8)/8.0,0.6,0.82)
        capsule.material_override = mat
        model.add_child(capsule)
        avatars[id] = model
    var avatar: Node3D = avatars[id]
    if not avatar_targets.has(id):
        avatar.global_position = pos
        avatar.rotation.y = heading
    avatar_targets[id] = pos
    avatar_headings[id] = heading

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F7:
        _toggle()
        get_viewport().set_input_as_handled()
