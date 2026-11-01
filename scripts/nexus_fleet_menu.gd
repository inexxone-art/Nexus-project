extends CanvasLayer
class_name NexusFleetMenu
signal spawn_requested(definition: Dictionary)
const CATALOG = preload("res://scripts/nexus_vehicle_catalog.gd")
const PAGE_SIZE: int = 10
var pane: PanelContainer
var select_group: OptionButton
var search: LineEdit
var list_view: VBoxContainer
var stats: Label
var page_label: Label
var page: int = 0
var _was_mouse_captured: bool = false

func _ready() -> void:
    name = "NEXUS Fahrzeugkatalog"
    layer = 20
    pane = PanelContainer.new()
    pane.set_anchors_preset(Control.PRESET_TOP_LEFT)
    pane.position = Vector2(25, 48)
    pane.custom_minimum_size = Vector2(455, 0)
    add_child(pane)
    var main = VBoxContainer.new()
    main.add_theme_constant_override("separation", 7)
    pane.add_child(main)
    var title = Label.new()
    title.text = "NEXUS // FAHRZEUGHALLE  ·  123 MODELLE"
    title.add_theme_font_size_override("font_size", 21)
    main.add_child(title)
    var explanation = Label.new()
    explanation.text = "70 Autos  |  20 Panzer  |  10 Helikopter  |  3 Bagger  |  20 Nutzfahrzeuge"
    explanation.add_theme_font_size_override("font_size", 13)
    main.add_child(explanation)
    var filters = HBoxContainer.new()
    main.add_child(filters)
    select_group = OptionButton.new()
    select_group.custom_minimum_size.x = 180
    for cat in CATALOG.categories():
        select_group.add_item(cat)
    select_group.item_selected.connect(_on_filter_group)
    filters.add_child(select_group)
    search = LineEdit.new()
    search.placeholder_text = "Fahrzeug suchen ..."
    search.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    search.text_changed.connect(_on_filter_text)
    filters.add_child(search)
    list_view = VBoxContainer.new()
    list_view.custom_minimum_size.y = 355
    main.add_child(list_view)
    var nav = HBoxContainer.new()
    main.add_child(nav)
    var previous = Button.new()
    previous.text = "◀ Vorherige"
    previous.pressed.connect(_on_previous)
    nav.add_child(previous)
    page_label = Label.new()
    page_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    nav.add_child(page_label)
    var next = Button.new()
    next.text = "Naechste ▶"
    next.pressed.connect(_on_next)
    nav.add_child(next)
    stats = Label.new()
    stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    main.add_child(stats)
    var close = Button.new()
    close.text = "SCHLIESSEN  /  F6"
    close.pressed.connect(toggle)
    main.add_child(close)
    visible = false
    _update()

func toggle() -> void:
    visible = not visible
    if visible:
        _was_mouse_captured = Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        _update()
    elif _was_mouse_captured:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _update() -> void:
    if list_view == null:
        return
    for child in list_view.get_children():
        list_view.remove_child(child)
        child.queue_free()
    var records = CATALOG.filtered(select_group.get_item_text(select_group.selected), search.text.strip_edges())
    var total_pages: int = maxi(1, ceili(float(records.size()) / float(PAGE_SIZE)))
    page = clampi(page, 0, total_pages - 1)
    for index in range(page * PAGE_SIZE, mini(records.size(), (page + 1) * PAGE_SIZE)):
        var record: Dictionary = records[index]
        var button = Button.new()
        button.custom_minimum_size.y = 32
        button.text = "%s  |  %s  |  %d km/h" % [record["id"], record["name"], record["top_kmh"]]
        button.pressed.connect(_pick.bind(str(record["id"])))
        list_view.add_child(button)
    page_label.text = "%d / %d" % [page + 1, total_pages]
    stats.text = "%d Treffer.  Modell antippen, um es in deiner Naehe zu spawnen. F einsteigen.\nDies sind unterschiedliche Fahrprofile mit prozeduralen Prototyp-Karosserien, keine fotorealistischen Einzelmodelle." % records.size()

func _pick(id: String) -> void:
    var record = CATALOG.by_id(id)
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
    page = maxi(0, page - 1)
    _update()

func _on_next() -> void:
    page += 1
    _update()
