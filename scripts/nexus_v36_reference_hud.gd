extends CanvasLayer
class_name NexusV36ReferenceHUD
## Live in-engine HUD faithful to the Adlerklamm concept composition.
## Every statistic comes from the Godot world; never display fake 12 survivors
## or fictional ammunition counts unsupported by gameplay.
const RADAR_SCRIPT = preload("res://scripts/nexus_v36_radar.gd")
const BASE_SIZE := Vector2(1600,900)
const TEXT := Color("f1f4f3")
const MUTED := Color("acb8b8")
const GOLD := Color("f6c33d")
var world
var ui_root: Control
var layout_root: Control
var compass: Label
var weather: Label
var mission_head: Label
var mission_steps: Array[Label] = []
var resource_rows: Dictionary = {}
var rebuild_steps: Array[Label] = []
var role_buttons: Array[Button] = []
var loadout_buttons: Array[Button] = []
var ammo_label: Label
var health_label: Label
var notice_label: Label
var radar: NexusV36Radar
var refresh_timer := 0.0

func setup(owner_world: Node3D) -> void:
    world = owner_world
    layer = 6
    _build()
    get_viewport().size_changed.connect(_layout)
    _layout()
    _refresh()

func _build() -> void:
    ui_root = Control.new()
    ui_root.name = "Cinematic HUD | live gameplay values"
    ui_root.set_anchors_preset(Control.PRESET_FULL_RECT)
    ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(ui_root)
    layout_root = Control.new()
    layout_root.name = "1600 x 900 reference composition"
    layout_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
    ui_root.add_child(layout_root)
    _label(layout_root,"N E X U S",Vector2(22,7),Vector2(280,40),30,TEXT)
    var mission := _panel("Mission panel",Vector2(18,45),Vector2(385,300))
    _label(mission,"◇  ADLERKLAMM – HAUPTMISSION",Vector2(16,9),Vector2(350,26),20,GOLD)
    _label(mission,"Brueckeneinsturz – Rettung & Sicherung",Vector2(16,37),Vector2(355,22),15,TEXT)
    for i in range(5):
        mission_steps.append(_label(mission,"",Vector2(19,74+i*26),Vector2(351,24),15,TEXT))
    _label(mission,"!  ENTSCHEIDUNG: RETTUNGSWEG",Vector2(16,211),Vector2(353,19),14,GOLD)
    var pilot := _button(mission,"HELIKOPTER",Vector2(15,235),Vector2(167,40))
    pilot.pressed.connect(_choose_role.bind("pilot"))
    role_buttons.append(pilot)
    var ground := _button(mission,"BODENRETTUNG",Vector2(190,235),Vector2(177,40))
    ground.pressed.connect(_choose_role.bind("bodensuche"))
    role_buttons.append(ground)

    compass = _label(layout_root,"",Vector2(580,4),Vector2(530,27),15,TEXT)
    compass.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    weather = _label(layout_root,"",Vector2(1270,9),Vector2(306,27),15,TEXT)
    weather.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

    var materials := _panel("Resource stock",Vector2(1345,53),Vector2(237,290))
    _label(materials,"ROHSTOFFE",Vector2(14,8),Vector2(215,30),21,TEXT)
    for i in range(8):
        var key: String = ["wood","iron","iron_ore","cement","asphalt","crude","diesel","coins"][i]
        var name: String = ["Holz","Stahl / Eisen","Eisenerz","Zement","Asphalt","Rohoel","Diesel","Credits"][i]
        _label(materials,name,Vector2(15,44+i*28),Vector2(138,26),14,MUTED)
        var value := _label(materials,"0",Vector2(139,44+i*28),Vector2(83,26),15,TEXT)
        value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        resource_rows[key] = value

    var repair := _panel("Reconstruction",Vector2(1307,533),Vector2(279,236))
    _label(repair,"WIEDERAUFBAU – BRUECKE",Vector2(12,9),Vector2(253,24),17,TEXT)
    _label(repair,"Baustufe / Fortschritt",Vector2(12,39),Vector2(245,22),14,MUTED)
    for i in range(4):
        rebuild_steps.append(_label(repair,"",Vector2(14,75+i*34),Vector2(249,29),15,TEXT))

    radar = RADAR_SCRIPT.new()
    radar.world = world
    radar.position = Vector2(26,688)
    layout_root.add_child(radar)
    _label(layout_root,"ADLERKLAMM",Vector2(27,670),Vector2(170,22),13,TEXT)
    var roles := _panel("Rescue team",Vector2(207,677),Vector2(224,185))
    _label(roles,"ROLLE WAEHLEN",Vector2(12,10),Vector2(200,22),16,GOLD)
    for i in range(3):
        var options := [["sanitaeter","+ SANITAETER"],["pilot","✈ PILOT"],["bodensuche","◇ SUCHTEAM"]]
        var btn := _button(roles,str(options[i][1]),Vector2(12,41+i*44),Vector2(200,38))
        btn.pressed.connect(_choose_role.bind(str(options[i][0])))
        role_buttons.append(btn)

    var loadout := _panel("Equipment quick bar",Vector2(536,818),Vector2(526,70))
    for i in range(4):
        var equipment_name: String = ["GEWEHR","PISTOLE","RETTUNG","BAU"][i]
        var slot := _button(loadout,"%d   %s" % [i+3,equipment_name],Vector2(7+i*129,8),Vector2(123,54))
        slot.pressed.connect(_select_slot.bind(i))
        loadout_buttons.append(slot)

    var ammo := _panel("Weapons and health",Vector2(1332,783),Vector2(249,105))
    ammo_label = _label(ammo,"",Vector2(13,12),Vector2(221,39),18,TEXT)
    health_label = _label(ammo,"",Vector2(13,66),Vector2(221,25),15,GOLD)
    notice_label = _label(layout_root,"",Vector2(469,718),Vector2(806,57),19,GOLD)
    notice_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _panel(label_text: String,where: Vector2,dimensions: Vector2) -> PanelContainer:
    var box := PanelContainer.new()
    box.name = label_text
    box.position = where
    box.size = dimensions
    box.custom_minimum_size = dimensions
    box.mouse_filter = Control.MOUSE_FILTER_IGNORE
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.018,0.028,0.038,0.83)
    style.border_color = Color(0.38,0.46,0.50,0.62)
    style.set_border_width_all(1)
    style.set_corner_radius_all(5)
    box.add_theme_stylebox_override("panel",style)
    layout_root.add_child(box)
    return box

func _label(parent: Node,text_value: String,at: Vector2,dimensions: Vector2,font_size: int,tint: Color) -> Label:
    var result := Label.new()
    result.text = text_value
    result.position = at
    result.size = dimensions
    result.mouse_filter = Control.MOUSE_FILTER_IGNORE
    result.add_theme_color_override("font_color",tint)
    result.add_theme_font_size_override("font_size",font_size)
    result.clip_text = true
    parent.add_child(result)
    return result

func _button(parent: Node,text_value: String,at: Vector2,dimensions: Vector2) -> Button:
    var button := Button.new()
    button.text = text_value
    button.position = at
    button.size = dimensions
    button.custom_minimum_size = dimensions
    button.mouse_filter = Control.MOUSE_FILTER_STOP
    button.add_theme_color_override("font_color",TEXT)
    var normal := StyleBoxFlat.new()
    normal.bg_color = Color(0.095,0.116,0.128,0.93)
    normal.border_color = Color(0.31,0.37,0.39)
    normal.set_border_width_all(1)
    normal.set_corner_radius_all(4)
    button.add_theme_stylebox_override("normal",normal)
    var hovered := normal.duplicate() as StyleBoxFlat
    hovered.bg_color = Color(0.22,0.23,0.2,0.98)
    hovered.border_color = GOLD
    button.add_theme_stylebox_override("hover",hovered)
    var focus := normal.duplicate() as StyleBoxFlat
    focus.border_color = GOLD
    button.add_theme_stylebox_override("focus",focus)
    parent.add_child(button)
    return button

func _layout() -> void:
    if ui_root == null:
        return
    var viewport_size: Vector2 = get_viewport().get_visible_rect().size
    var factor: float = minf(viewport_size.x/BASE_SIZE.x,viewport_size.y/BASE_SIZE.y)
    layout_root.scale = Vector2.ONE*factor
    layout_root.position = (viewport_size-BASE_SIZE*factor)*0.5

func _process(delta: float) -> void:
    refresh_timer += delta
    if refresh_timer >= 0.16:
        refresh_timer = 0.0
        _refresh()

func _refresh() -> void:
    if world == null or world.nexus_v35 == null:
        return
    var rescue: NexusAdlerklammRescueV35 = world.nexus_v35.rescue
    var industry: NexusIndustryV35 = world.nexus_v35.industry
    if rescue == null or industry == null:
        return
    var rescued_count: int = rescue.rescued.size()
    var bridge: NexusAdlerklammDisaster = world.mega_map.canyon_disaster
    mission_steps[0].text = "%s  Ueberlebende lokalisieren (%d/3)" % [_tick(rescued_count==3),rescued_count]
    mission_steps[1].text = "%s  Medizinische Erstversorgung leisten" % _tick(rescue.phase=="completed" and rescue.role=="sanitaeter")
    mission_steps[2].text = "%s  Rettung per Helikopter oder Bodenroute" % _tick(rescue.phase=="completed")
    mission_steps[3].text = "%s  Brueckenbereich sichern" % _tick(bridge.stage=="aftermath" or rescue.phase=="completed")
    mission_steps[4].text = "%s  Wiederaufbau vorbereiten" % _tick(bridge.rebuild_progress>0 or (bridge.stage=="ready" and world.nexus_v35.triggered))
    mission_head = mission_steps[0]
    var label_weather: String = ["Sonne","Wolken","Regen","Schnee"][clampi(int(world.world_clock.weather),0,3)]
    weather.text = "%s   |   Tag %d   %02d:%02d" % [label_weather,world.legacy.world_days+1 if world.legacy != null else 1,int(world.world_clock.hour),int(fposmod(world.world_clock.hour*60.0,60.0))]
    compass.text = "SW    240      W    285    300       NW    330       N    015"
    resource_rows["wood"].text = str(world.wood)
    resource_rows["iron"].text = str(world.iron)
    resource_rows["iron_ore"].text = str(industry.inventory["iron_ore"])
    resource_rows["cement"].text = str(industry.inventory["cement"])
    resource_rows["asphalt"].text = str(industry.inventory["asphalt"])
    resource_rows["crude"].text = str(industry.inventory["crude"])
    resource_rows["diesel"].text = str(industry.inventory["diesel"])
    resource_rows["coins"].text = str(world.coins)
    var phases := ["Schutt raeumen","Stahltraeger montieren","Beton & Zement","Asphalt & Freigabe"]
    var done := 4 if bridge.stage=="ready" and world.nexus_v35.triggered else bridge.rebuild_progress
    for i in range(4):
        rebuild_steps[i].text = "%s  %s    %s" % [_tick(i<done),phases[i],"100%" if i<done else "0%"]
        rebuild_steps[i].add_theme_color_override("font_color",GOLD if i==done else (Color("92d6a5") if i<done else MUTED))
    for button in role_buttons:
        button.disabled = rescue.phase!="choice"
    for i in range(loadout_buttons.size()):
        loadout_buttons[i].modulate = GOLD if i==world.nexus_v35.equipped else Color.WHITE
    ammo_label.text = "AUSRUESTUNG\n"+world.nexus_v35.SLOTS[world.nexus_v35.equipped]
    health_label.text = "GESUNDHEIT  %d%%  |  %s" % [roundi(world.player.health),"FAHRT" if world.vehicle_in_use != null else "ZU FUSS"]
    notice_label.text = world.notice if world.notice_time>0.0 else ""

func _tick(done: bool) -> String:
    return "[X]" if done else "[ ]"

func _choose_role(value: String) -> void:
    if world != null and world.nexus_v35 != null:
        world.nexus_v35._select_role(value)

func _select_slot(index: int) -> void:
    if world != null and world.nexus_v35 != null:
        world.nexus_v35.switch_slot(index)
