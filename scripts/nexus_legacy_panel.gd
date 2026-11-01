extends CanvasLayer
class_name NexusLegacyPanel
## Accessible touch/keyboard-friendly gameplay hub for career, investments and chronicle.
signal request(action: String, target: String)
var legacy: NexusLegacy
var pane: PanelContainer
var info: Label
var journal: RichTextLabel
var vehicle_id: LineEdit
var call_sign: LineEdit
var style_select: OptionButton
var career_select: OptionButton
var buttons: Dictionary = {}

func _ready() -> void:
    name = "NEXUS | Spielerprofil und Chronik"
    layer = 22
    pane = PanelContainer.new()
    pane.set_anchors_preset(Control.PRESET_CENTER)
    pane.custom_minimum_size = Vector2(485,520)
    pane.position = Vector2(30,70)
    add_child(pane)
    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left",12)
    margin.add_theme_constant_override("margin_top",12)
    margin.add_theme_constant_override("margin_right",12)
    margin.add_theme_constant_override("margin_bottom",12)
    pane.add_child(margin)
    var layout := VBoxContainer.new()
    layout.add_theme_constant_override("separation",6)
    margin.add_child(layout)
    var title := Label.new()
    title.text = "NEXUS LEGACY | KARRIERE, GARAGE, BESITZ"
    title.add_theme_font_size_override("font_size",18)
    layout.add_child(title)
    info = Label.new()
    info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    layout.add_child(info)
    var identity := HBoxContainer.new()
    layout.add_child(identity)
    call_sign = LineEdit.new()
    call_sign.placeholder_text = "Rufname"
    call_sign.custom_minimum_size.x = 120
    identity.add_child(call_sign)
    style_select = OptionButton.new()
    for s in NexusLegacy.STYLES: style_select.add_item(s)
    identity.add_child(style_select)
    _button(identity,"Profil speichern","profile","")
    var career_row := HBoxContainer.new()
    layout.add_child(career_row)
    career_select = OptionButton.new()
    for s in NexusLegacy.CAREERS: career_select.add_item(s)
    career_row.add_child(career_select)
    _button(career_row,"Karriere waehlen","career","")
    var rows := TabContainer.new()
    rows.custom_minimum_size = Vector2(450,280)
    rows.size_flags_vertical = Control.SIZE_EXPAND_FILL
    layout.add_child(rows)
    var garage := _tab(rows,"Fahrzeug")
    _line(garage,"Fahrzeug-ID: In der Fahrzeughalle auswahlen")
    vehicle_id = LineEdit.new()
    vehicle_id.placeholder_text = "Katalog-ID (aus der Fahrzeughalle)"
    garage.add_child(vehicle_id)
    var tune := HBoxContainer.new()
    garage.add_child(tune)
    _button(tune,"Motor","tune","motor")
    _button(tune,"Reifen","tune","reifen")
    _button(tune,"Bremsen","tune","bremsen")
    var property := _tab(rows,"Eigentum")
    _line(property,"Gebaeude werden im Besitzregister gespeichert")
    _button(property,"Werkstatt | 850 EUR","property","garage")
    _button(property,"Eigenes Haus | 1250 EUR","property","house")
    _button(property,"Aussenposten | 2200 EUR","property","outpost")
    var ship := _tab(rows,"Raumschiff")
    _line(ship,"Schiffsupgrades: Forschungs- und Frachtlogik")
    _button(ship,"Scanner | 700 EUR","ship","scanner")
    _button(ship,"Frachtraum | 1050 EUR","ship","cargo")
    _button(ship,"Krankenstation | 1200 EUR","ship","medbay")
    var talents := _tab(rows,"Talente")
    _line(talents,"Ein Talentpunkt pro Levelaufstieg")
    var talent_row := HBoxContainer.new()
    talents.add_child(talent_row)
    _button(talent_row,"Fahren","skill","driving")
    _button(talent_row,"Rettung","skill","rescue")
    var talent_row2 := HBoxContainer.new()
    talents.add_child(talent_row2)
    _button(talent_row2,"Forschung","skill","research")
    _button(talent_row2,"Handel","skill","trade")
    var history := _tab(rows,"Chronik")
    journal = RichTextLabel.new()
    journal.custom_minimum_size = Vector2(410,230)
    journal.size_flags_vertical = Control.SIZE_EXPAND_FILL
    history.add_child(journal)
    var close := Button.new()
    close.text = "SCHLIESSEN | F2"
    close.pressed.connect(toggle)
    layout.add_child(close)
    visible = false

func _tab(tabs: TabContainer, caption: String) -> VBoxContainer:
    var scroller := ScrollContainer.new()
    scroller.name = caption
    tabs.add_child(scroller)
    var box := VBoxContainer.new()
    box.add_theme_constant_override("separation",7)
    box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    scroller.add_child(box)
    return box

func _line(parent: VBoxContainer, label: String) -> void:
    var t := Label.new()
    t.text = label
    t.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    parent.add_child(t)

func _button(parent: Container, caption: String, action: String, target: String) -> void:
    var b := Button.new()
    b.text = caption
    b.custom_minimum_size.y = 39
    b.pressed.connect(func():
        var actual: String = target
        match action:
            "profile": actual = call_sign.text + "|" + NexusLegacy.STYLES[style_select.selected]
            "career": actual = NexusLegacy.CAREERS[career_select.selected]
            "tune": actual = vehicle_id.text.strip_edges() + "|" + target
        request.emit(action,actual)
    )
    parent.add_child(b)

func bind_state(source: NexusLegacy) -> void:
    legacy = source
    call_sign.text = legacy.callsign
    style_select.select(maxi(0,NexusLegacy.STYLES.find(legacy.style)))
    career_select.select(maxi(0,NexusLegacy.CAREERS.find(legacy.career)))
    legacy.state_changed.connect(func(_message: String): refresh())
    refresh()

func refresh() -> void:
    if not is_instance_valid(legacy) or info == null: return
    info.text = legacy.summary()
    if journal == null: return
    var lines: PackedStringArray = []
    for i in range(legacy.events.size()-1,maxi(-1,legacy.events.size()-26),-1):
        var event: Dictionary = legacy.events[i]
        lines.append("Tag %d | %s" % [int(event.get("day",0)),str(event.get("text",""))])
    journal.text = "\n".join(lines) if not lines.is_empty() else "Deine Weltgeschichte beginnt jetzt."

func toggle() -> void:
    visible = not visible
    if visible:
        var screen: Vector2 = get_viewport().get_visible_rect().size
        pane.custom_minimum_size = Vector2(minf(485.0,maxf(280.0,screen.x-12.0)),minf(520.0,maxf(350.0,screen.y-20.0)))
        pane.position = Vector2(maxf(6.0,(screen.x-pane.custom_minimum_size.x)*0.5),maxf(6.0,(screen.y-pane.custom_minimum_size.y)*0.5))
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        refresh()
