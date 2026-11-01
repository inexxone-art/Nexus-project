extends CanvasLayer
class_name NexusV35Operations
## Companion overlay for the existing world. Respects old inputs and saves.
const RESCUE_SCRIPT = preload("res://scripts/nexus_adlerklamm_rescue_v35.gd")
const INDUSTRY_SCRIPT = preload("res://scripts/nexus_industry_v35.gd")
var world
var rescue: NexusAdlerklammRescueV35
var industry: NexusIndustryV35
var role_dialog: PanelContainer
var industry_panel: PanelContainer
var inventory_label: Label
var mission_label: Label
var loadout_label: Label
var equipped: int = 0
const SLOTS: PackedStringArray = ["Sturmgewehr","Pistole","Rettungswerkzeug","Bauwerkzeug"]
var triggered: bool = false
var radio_pending: bool = false

func setup(owner_world: Node3D) -> void:
    world = owner_world
    rescue = RESCUE_SCRIPT.new()
    world.add_child(rescue)
    industry = INDUSTRY_SCRIPT.new()
    world.add_child(industry)
    rescue.radio_call.connect(_radio)
    _build_ui()

func _build_ui() -> void:
    layer = 4
    role_dialog = PanelContainer.new()
    role_dialog.name = "Adlerklamm rescue role choice"
    role_dialog.position = Vector2(420,140)
    role_dialog.custom_minimum_size = Vector2(480,220)
    add_child(role_dialog)
    var stack := VBoxContainer.new()
    role_dialog.add_child(stack)
    var title := Label.new()
    title.text = "NOTRUF ADLERKLAMM: Ist hier ein Sanitaeter oder Pilot?"
    title.add_theme_font_size_override("font_size",20)
    stack.add_child(title)
    for entry in [["sanitaeter","Sanitaeter – Menschen zu Fuss versorgen"],["pilot","Pilot – Helikopter-Bergung"],["bodensuche","Suchteam – Vermisste zu Fuss finden"]]:
        var button := Button.new()
        button.text = str(entry[1])
        button.pressed.connect(_select_role.bind(str(entry[0])))
        stack.add_child(button)
    role_dialog.hide()
    mission_label = Label.new()
    mission_label.position = Vector2(24,610)
    mission_label.add_theme_font_size_override("font_size",18)
    add_child(mission_label)
    loadout_label = Label.new()
    loadout_label.position = Vector2(980,700)
    loadout_label.add_theme_font_size_override("font_size",17)
    add_child(loadout_label)
    industry_panel = PanelContainer.new()
    industry_panel.position = Vector2(790,80)
    industry_panel.custom_minimum_size = Vector2(370,500)
    add_child(industry_panel)
    var industry_stack := VBoxContainer.new()
    industry_panel.add_child(industry_stack)
    var heading := Label.new()
    heading.text = "NEXUS INDUSTRIE | Bauplaetze und Produktionsketten"
    industry_stack.add_child(heading)
    inventory_label = Label.new()
    industry_stack.add_child(inventory_label)
    for id in NexusIndustryV35.SITES.keys():
        var row := HBoxContainer.new()
        industry_stack.add_child(row)
        var build := Button.new()
        build.text = "Bau: "+str(NexusIndustryV35.SITES[id]["name"])
        build.pressed.connect(_industry_action.bind(str(id),true))
        row.add_child(build)
        var operate := Button.new()
        operate.text = "Produzieren"
        operate.pressed.connect(_industry_action.bind(str(id),false))
        row.add_child(operate)
    var dismiss := Button.new()
    dismiss.text = "Schliessen (F12)"
    dismiss.pressed.connect(toggle_industry)
    industry_stack.add_child(dismiss)
    industry_panel.hide()
    _refresh()

func _process(_delta: float) -> void:
    if world == null or world.mega_map == null or world.mega_map.canyon_disaster == null:
        return
    var bridge: NexusAdlerklammDisaster = world.mega_map.canyon_disaster
    if bridge.stage == "ready" and not triggered and world.vehicle_in_use != null:
        var car: NexusVehicle = world.vehicle_in_use
        var point: Vector3 = car.global_position
        var on_exit: bool = absf(point.x-175.0) < 12.5 and ((point.z >= 210.0 and point.z <= 232.0) or (point.z <= 125.0 and point.z >= 103.0))
        if car.category != "Helikopter" and absf(car.speed) > 3.0 and on_exit:
            triggered = true
            if bridge.start_disaster():
                rescue.trigger()
                role_dialog.show()
                Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
                world._say("HINTER DIR! Die Bruecke bricht! Ein Bus stuerzt in den Canyon!")
                world.save_state()
    if rescue.phase == "choice" and radio_pending:
        role_dialog.show()
        radio_pending = false
    if mission_label != null:
        mission_label.text = rescue.remaining_objective()
    if loadout_label != null:
        loadout_label.text = "AUSRUESTUNG 3–6: " + SLOTS[equipped]

func _radio(message: String) -> void:
    if world != null:
        world._say(message)
    radio_pending = true

func _select_role(value: String) -> void:
    if rescue.choose_role(value):
        role_dialog.hide()
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        _refresh()
        world.save_state()

func interact() -> bool:
    if rescue.phase != "active":
        return false
    var position: Vector3 = world.player.global_position
    var category := ""
    var speed := 0.0
    if world.vehicle_in_use != null:
        position = world.vehicle_in_use.global_position
        category = world.vehicle_in_use.category
        speed = world.vehicle_in_use.speed
    # Only swallow E when within the rescue search zone, preserving normal gameplay elsewhere.
    if Vector2(position.x-175.0,position.z-210.0).length() > 48.0:
        return false
    var result: Dictionary = rescue.try_rescue(position,category,speed)
    if not bool(result.get("handled",false)):
        return false
    world._say(str(result.get("message","Rettung")))
    if bool(result.get("complete",false)) and rescue.claim_reward():
        world.coins += NexusAdlerklammRescueV35.PAYOUT
        world.completed_jobs += 1
        if world.legacy != null:
            world.legacy.award_activity("rescue","Adlerklamm: drei Menschen gerettet",180)
        world.save_state()
    return true

func toggle_industry() -> void:
    industry_panel.visible = not industry_panel.visible
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if industry_panel.visible else Input.MOUSE_MODE_CAPTURED
    _refresh()

func _industry_action(id: String, build: bool) -> void:
    if world == null:
        return
    var p: Vector3 = world.player.global_position if world.vehicle_in_use == null else world.vehicle_in_use.global_position
    var result: Dictionary = industry.build_site(id,p,world.wood,world.iron,world.coins) if build else industry.operate(id,p,world.wood)
    if bool(result.get("ok",false)):
        world.wood += int(result.get("wood",0))
        world.iron += int(result.get("iron",0))
        world.coins += int(result.get("money",0))
        world.save_state()
    world._say(str(result.get("message","Industrie")))
    _refresh()

func _refresh() -> void:
    if inventory_label != null and industry != null:
        inventory_label.text = industry.summary() + "\nHinweis: Arbeite vor Ort, keine Sofortproduktion aus der Ferne."

func switch_slot(slot: int) -> void:
    equipped = clampi(slot,0,SLOTS.size()-1)
    _refresh()

func get_data() -> Dictionary:
    return {"rescue":rescue.get_data(),"industry":industry.get_data(),"equipped":equipped,"triggered":triggered}

func restore_data(data: Dictionary) -> void:
    rescue.restore_data(data.get("rescue",{}))
    industry.restore_data(data.get("industry",{}))
    equipped = clampi(int(data.get("equipped",0)),0,SLOTS.size()-1)
    triggered = bool(data.get("triggered",rescue.phase != "dormant"))
    if rescue.phase == "choice":
        radio_pending = true
    role_dialog.hide()
    industry_panel.hide()
    _refresh()
