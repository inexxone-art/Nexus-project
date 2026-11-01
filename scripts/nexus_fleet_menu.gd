extends CanvasLayer
class_name NexusFleetMenu
## V1.7 vehicle selector: mobile-friendly searchable catalogue, actual 3D showroom,
## detailed specifications, and separate spawn confirmation.
signal spawn_requested(definition: Dictionary)
const CATALOG = preload("res://scripts/nexus_vehicle_catalog.gd")
const VISUALS = preload("res://scripts/nexus_vehicle_visuals.gd")
const PAGE_SIZE: int = 6
var pane: PanelContainer
var select_group: OptionButton
var search: LineEdit
var list_view: VBoxContainer
var stats: Label
var page_label: Label
var details: Label
var spawn_button: Button
var page: int = 0
var _was_mouse_captured: bool = false
var selected_id: String = ""
var preview_viewport: SubViewport
var preview_root: Node3D
var vehicle_visual: Node3D
var preview_camera: Camera3D
var preview_spin_pause: float = 0.0
var preview_zoom_factor: float = 1.0

func _ready() -> void:
    name = "NEXUS Fahrzeughalle | V1.7"
    layer = 20
    pane = PanelContainer.new()
    pane.set_anchors_preset(Control.PRESET_TOP_LEFT)
    pane.position = Vector2(12,12)
    var visible_size: Vector2 = get_viewport().get_visible_rect().size
    pane.custom_minimum_size = Vector2(minf(570.0,maxf(280.0,visible_size.x-24)),0)
    add_child(pane)
    var main := VBoxContainer.new()
    main.add_theme_constant_override("separation",5)
    pane.add_child(main)
    var title := Label.new()
    title.text = "NEXUS // FAHRZEUGHANGAR"
    title.add_theme_font_size_override("font_size",20)
    main.add_child(title)
    var explanation := Label.new()
    explanation.text = "123 Fahrzeugprofile · 3D-Vorschau · F6"
    main.add_child(explanation)
    var filters := HBoxContainer.new()
    main.add_child(filters)
    select_group = OptionButton.new()
    select_group.custom_minimum_size.x = 135
    for cat in CATALOG.categories(): select_group.add_item(cat)
    select_group.item_selected.connect(_on_filter_group)
    filters.add_child(select_group)
    search = LineEdit.new()
    search.placeholder_text = "Suche ..."
    search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    search.text_changed.connect(_on_filter_text)
    filters.add_child(search)
    _make_preview(main)
    _make_showcase_buttons(main)
    details = Label.new()
    details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    main.add_child(details)
    list_view = VBoxContainer.new()
    main.add_child(list_view)
    var nav := HBoxContainer.new()
    main.add_child(nav)
    var previous := Button.new()
    previous.text = "◀ Zurueck"
    previous.pressed.connect(_on_previous)
    nav.add_child(previous)
    page_label = Label.new()
    page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    nav.add_child(page_label)
    var next := Button.new()
    next.text = "Weiter ▶"
    next.pressed.connect(_on_next)
    nav.add_child(next)
    var actions := HBoxContainer.new()
    main.add_child(actions)
    spawn_button = Button.new()
    spawn_button.text = "FAHRZEUG SPAWNEN"
    spawn_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    spawn_button.pressed.connect(_spawn_selected)
    actions.add_child(spawn_button)
    var close := Button.new()
    close.text = "SCHLIESSEN"
    close.pressed.connect(toggle)
    actions.add_child(close)
    stats = Label.new()
    stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    stats.add_theme_font_size_override("font_size",11)
    main.add_child(stats)
    visible = false
    _update()

func _make_preview(main: VBoxContainer) -> void:
    var subcontainer := SubViewportContainer.new()
    subcontainer.custom_minimum_size = Vector2(240,190)
    subcontainer.stretch = true
    subcontainer.mouse_filter = Control.MOUSE_FILTER_STOP
    subcontainer.gui_input.connect(_on_preview_input)
    main.add_child(subcontainer)
    preview_viewport = SubViewport.new()
    preview_viewport.size = Vector2i(512,240)
    preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    preview_viewport.transparent_bg = false
    subcontainer.add_child(preview_viewport)
    preview_root = Node3D.new()
    preview_viewport.add_child(preview_root)
    var environment := WorldEnvironment.new()
    var env := Environment.new()
    env.background_mode = Environment.BG_COLOR
    env.background_color = Color("222b35")
    env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    env.ambient_light_color = Color("9aaec5")
    env.ambient_light_energy = 0.75
    env.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.environment = env
    preview_root.add_child(environment)
    var floor := MeshInstance3D.new()
    var platform := CylinderMesh.new()
    platform.top_radius = 5.5
    platform.bottom_radius = 5.6
    platform.height = 0.20
    floor.mesh = platform
    floor.position.y = -0.10
    var metal := StandardMaterial3D.new()
    metal.albedo_color = Color("343d45")
    metal.metallic = 0.55
    metal.roughness = 0.39
    floor.material_override = metal
    preview_root.add_child(floor)
    var key := DirectionalLight3D.new()
    key.light_energy = 2.0
    key.rotation_degrees = Vector3(-42,-35,0)
    preview_root.add_child(key)
    var fill := DirectionalLight3D.new()
    fill.light_energy = 0.65
    fill.light_color = Color("91b7ff")
    fill.rotation_degrees = Vector3(-27,130,0)
    preview_root.add_child(fill)
    var camera := Camera3D.new()
    camera.position = Vector3(7.8,5.3,10.0)
    camera.fov = 47.0
    preview_root.add_child(camera)
    camera.look_at(Vector3(0,1.6,0),Vector3.UP)
    camera.current = true
    preview_camera = camera

func _make_showcase_buttons(main: VBoxContainer) -> void:
    var title := Label.new()
    title.text = "V1.8 HERO-DETAILMODELLE · 3 aufwendig ausgearbeitete Prototypen"
    title.add_theme_font_size_override("font_size", 11)
    main.add_child(title)
    var buttons := HBoxContainer.new()
    main.add_child(buttons)
    for entry in [{"id":"CAR_041","label":"Sportwagen"},{"id":"HELI_01","label":"Rettungsheli"},{"id":"EXC_02","label":"Bagger 14t"}]:
        var b := Button.new()
        b.text = str(entry["label"])
        b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        b.pressed.connect(_jump_to_showcase.bind(str(entry["id"])))
        buttons.add_child(b)

func _jump_to_showcase(id: String) -> void:
    select_group.select(0)
    search.text = ""
    page = 0
    var records := CATALOG.filtered("Alle")
    for i in range(records.size()):
        if str(records[i].get("id", "")) == id:
            page = int(i / PAGE_SIZE)
            break
    _select(id)

func _on_preview_input(event: InputEvent) -> void:
    if vehicle_visual == null:
        return
    if event is InputEventScreenDrag:
        vehicle_visual.rotation.y += event.relative.x * 0.014
        preview_spin_pause = 5.0
    elif event is InputEventMouseMotion and (event.button_mask & MOUSE_BUTTON_MASK_LEFT):
        vehicle_visual.rotation.y += event.relative.x * 0.010
        preview_spin_pause = 5.0
    elif event is InputEventMouseButton and event.pressed:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP:
            preview_zoom_factor = clampf(preview_zoom_factor*0.90, 0.6, 1.5)
            _position_preview_camera()
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
            preview_zoom_factor = clampf(preview_zoom_factor*1.10, 0.6, 1.5)
            _position_preview_camera()

func _position_preview_camera() -> void:
    if preview_camera == null or vehicle_visual == null:
        return
    var length_m: float = float(vehicle_visual.spec.get("length", 4.7))
    var d: float = maxf(7.0, length_m*1.65) * preview_zoom_factor
    preview_camera.position = Vector3(d*0.55, d*0.37, d*0.86)
    preview_camera.look_at(Vector3(0,1.55,0), Vector3.UP)

func _show_vehicle(record: Dictionary) -> void:
    if preview_root == null: return
    if vehicle_visual != null:
        preview_root.remove_child(vehicle_visual)
        vehicle_visual.queue_free()
    vehicle_visual = VISUALS.new()
    vehicle_visual.set_vehicle(record,str(record.get("group","Auto")))
    preview_root.add_child(vehicle_visual)
    vehicle_visual.rotation.y = 0.5
    preview_zoom_factor = 1.0
    preview_spin_pause = 0.0
    _position_preview_camera()
    details.text = "%s\n%s | %d km/h | %d Sitze\nLaenge %.2f m · Breite %.2f m · Leistung %.1f · Handling %.2f\nEinsatz: %s" % [
        record.get("name","Unbekannt"),record.get("family","Modell"),int(record.get("top_kmh",0)),
        int(record.get("seats",1)),float(record.get("length",4.5)),float(record.get("width",2.0)),
        float(record.get("acceleration",5.0)),float(record.get("handling",0.7)),str(record.get("role","Alltag"))]

func _process(delta: float) -> void:
    if visible and vehicle_visual != null:
        preview_spin_pause = maxf(0.0, preview_spin_pause-delta)
        if preview_spin_pause <= 0.0:
            vehicle_visual.rotation.y += delta*0.22
        vehicle_visual.animate_vehicle(delta,0.0,0.0,false,100.0)

func toggle() -> void:
    visible = not visible
    if visible:
        _was_mouse_captured = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        _update()
    elif _was_mouse_captured:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _update() -> void:
    if list_view == null: return
    for child in list_view.get_children():
        list_view.remove_child(child)
        child.queue_free()
    var records := CATALOG.filtered(select_group.get_item_text(select_group.selected),search.text.strip_edges())
    var total_pages: int = maxi(1,ceili(float(records.size())/float(PAGE_SIZE)))
    page = clampi(page,0,total_pages-1)
    var found_selected := false
    for record in records:
        if str(record.get("id","")) == selected_id: found_selected = true
    if not found_selected:
        selected_id = str(records[0].get("id","")) if not records.is_empty() else ""
        if not records.is_empty(): _show_vehicle(records[0])
    for index in range(page*PAGE_SIZE,mini(records.size(),(page+1)*PAGE_SIZE)):
        var record: Dictionary = records[index]
        var button := Button.new()
        button.custom_minimum_size.y = 29
        button.text = ("● " if str(record["id"])==selected_id else "   ")+str(record["name"])+" · "+str(record["top_kmh"])+" km/h"
        button.pressed.connect(_select.bind(str(record["id"])))
        list_view.add_child(button)
    page_label.text = "%d / %d" % [page+1,total_pages]
    spawn_button.disabled = selected_id == ""
    if selected_id == "": details.text = "Keine Treffer"
    stats.text = "%d Fahrzeuge | Eigenstaendige prozedurale Prototyp-Modelle, keine photogrammetrischen Serienfahrzeuge." % records.size()

func _select(id: String) -> void:
    selected_id = id
    var record := CATALOG.by_id(id)
    if not record.is_empty(): _show_vehicle(record)
    _update()

func _spawn_selected() -> void:
    var record := CATALOG.by_id(selected_id)
    if not record.is_empty():
        spawn_requested.emit(record)
        toggle()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_F6:
        toggle()
        get_viewport().set_input_as_handled()

func _on_filter_group(_value: int) -> void:
    page = 0
    _update()

func _on_filter_text(_value: String) -> void:
    page = 0
    _update()

func _on_previous() -> void:
    page = maxi(0,page-1)
    _update()

func _on_next() -> void:
    page += 1
    _update()
