extends CanvasLayer
class_name NexusLivingPanel
## Accessible mouse/touch incident decision panel. Does not resolve silently.
signal decision_requested(option: int)
var simulation: NexusLivingUniverse
var shell: PanelContainer
var heading: Label
var description: RichTextLabel
var summary: Label
var a_button: Button
var b_button: Button
var notice: Label
var is_open: bool = false
var previous_mouse_mode: int = Input.MOUSE_MODE_VISIBLE

func _ready() -> void:
    layer = 23
    name = "NEXUS LIVING UNIVERSE | Einsatzleitung"
    shell = PanelContainer.new()
    shell.set_anchors_preset(Control.PRESET_CENTER)
    shell.position = Vector2(160, 95)
    shell.custom_minimum_size = Vector2(575, 425)
    add_child(shell)
    var background := StyleBoxFlat.new()
    background.bg_color = Color(0.023,0.037,0.052,0.95)
    background.border_color = Color(0.22,0.46,0.59,0.95)
    background.set_border_width_all(2)
    background.set_corner_radius_all(12)
    background.set_content_margin_all(17)
    shell.add_theme_stylebox_override("panel",background)
    var content := VBoxContainer.new()
    content.add_theme_constant_override("separation",11)
    shell.add_child(content)
    heading = Label.new()
    heading.add_theme_font_size_override("font_size",24)
    content.add_child(heading)
    summary = Label.new()
    summary.add_theme_font_size_override("font_size",15)
    content.add_child(summary)
    description = RichTextLabel.new()
    description.custom_minimum_size = Vector2(535,120)
    description.bbcode_enabled = false
    description.fit_content = false
    content.add_child(description)
    a_button = Button.new()
    a_button.custom_minimum_size.y = 50
    a_button.pressed.connect(func(): decision_requested.emit(1))
    content.add_child(a_button)
    b_button = Button.new()
    b_button.custom_minimum_size.y = 50
    b_button.pressed.connect(func(): decision_requested.emit(2))
    content.add_child(b_button)
    notice = Label.new()
    notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content.add_child(notice)
    var close := Button.new()
    close.text = "Schliessen (F8 / ESC)"
    close.pressed.connect(toggle)
    content.add_child(close)
    visible = false

func bind_simulation(source: NexusLivingUniverse) -> void:
    simulation = source
    refresh()

func toggle() -> void:
    is_open = not is_open
    visible = is_open
    if is_open:
        previous_mouse_mode = Input.mouse_mode
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        refresh()
    elif previous_mouse_mode == Input.MOUSE_MODE_CAPTURED:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func refresh() -> void:
    if simulation == null or heading == null:
        return
    var open_incident: Dictionary = simulation.pending
    var has_incident := not open_incident.is_empty()
    heading.text = "NEXUS // EINSATZLEITUNG"
    summary.text = simulation.get_summary()
    if has_incident:
        description.text = str(open_incident["brief"]) + "\n\nEntscheide, wie deine Organisation reagiert. Jede Wahl beeinflusst Regionen, Ruf und Guthaben."
        a_button.text = "[1] %s  |  Kosten: %d EUR" % [str(open_incident["a"]),int(open_incident["cost_a"])]
        b_button.text = "[2] %s  |  Kosten: %d EUR" % [str(open_incident["b"]),int(open_incident["cost_b"])]
        notice.text = "Einsatz offen. Eine Entscheidung ist erforderlich."
    else:
        description.text = "Keine akuten Einsaetze. Die Welt entwickelt sich mit der Spielzeit weiter.\n\nBesuchte Regionen und Entscheidungen bleiben im Spielstand erhalten."
        a_button.text = "Keine offene Mission"
        b_button.text = "Weitere Ereignisse entstehen im Spiel"
        notice.text = "F8 schliesst die Einsatzleitung."
    a_button.disabled = not has_incident
    b_button.disabled = not has_incident

func show_feedback(result: Dictionary) -> void:
    refresh()
    notice.text = str(result.get("message", ""))

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_F8:
            toggle()
            get_viewport().set_input_as_handled()
        elif event.keycode == KEY_ESCAPE and is_open:
            toggle()
            get_viewport().set_input_as_handled()
