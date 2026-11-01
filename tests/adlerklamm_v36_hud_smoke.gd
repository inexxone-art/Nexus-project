extends SceneTree
## Real world test of the reference HUD. No static image is substituted.
func _initialize() -> void:
    call_deferred("_verify")

func _fail(why: String) -> void:
    push_error("V3.6 HUD: "+why)
    quit(1)

func _verify() -> void:
    var scene: PackedScene = load("res://scenes/main.tscn")
    if scene == null:
        _fail("Main world scene absent")
        return
    var world: Node3D = scene.instantiate()
    root.add_child(world)
    await process_frame
    await process_frame
    var hud: NexusV36ReferenceHUD = world.reference_hud
    if hud == null or hud.radar == null or hud.weapon_view == null:
        _fail("Reference HUD, tactical radar or first person equipment absent")
        return
    if not world.player.first_person:
        _fail("First person camera not activated")
        return
    if hud.resource_rows.size() != 8 or hud.mission_steps.size() != 5 or hud.rebuild_steps.size() != 4:
        _fail("Mission/production/rebuild widgets missing")
        return
    var original_wood: int = world.wood
    world.wood += 5
    hud._refresh()
    if hud.resource_rows["wood"].text != str(original_wood+5):
        _fail("Resource HUD does not reflect actual inventory")
        return
    world.nexus_v35.switch_slot(1)
    hud._refresh()
    if hud.weapon_view.equipped != 1 or hud.weapon_view.groups.size() != 4:
        _fail("Hotbar does not switch the visible weapon model")
        return
    world.nexus_v35.rescue.trigger()
    hud._refresh()
    if hud.role_buttons[0].disabled:
        _fail("Role choices not active when distress event arrives")
        return
    hud._choose_role("pilot")
    if world.nexus_v35.rescue.role != "pilot" or world.nexus_v35.rescue.phase != "active":
        _fail("Visible rescue button not connected to gameplay")
        return
    world.nexus_v35.industry.inventory["cement"] = 12
    hud._refresh()
    if hud.resource_rows["cement"].text != "12":
        _fail("Cement stock shows a decorative number rather than current materials")
        return
    print("NEXUS V3.6 HUD PASS | live resources, equipment model, rescue choice and reference layout")
    world.queue_free()
    await process_frame
    quit(0)
