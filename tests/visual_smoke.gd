extends SceneTree
## Verify runtime assembly and renderer preset switching without requiring a physical GPU.
const WORLD = preload("res://scenes/main.tscn")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var world = WORLD.instantiate()
    root.add_child(world)
    await process_frame
    await process_frame
    if world.visual_polish == null or world.living == null or world.living_panel == null:
        push_error("V1.4 visual pass or simulation nodes missing")
        quit(1)
        return
    if world.visual_polish.get_child_count() < 60:
        push_error("Expected detailed cinematic geometry")
        quit(2)
        return
    world.visual_polish.set_graphics_quality(false)
    if world.visual_polish.quality_high:
        push_error("Graphics preset did not switch to performance")
        quit(3)
        return
    world.visual_polish.set_graphics_quality(true)
    if not world.visual_polish.quality_high:
        push_error("Graphics preset did not switch to cinematic")
        quit(4)
        return
    for _tick in range(4):
        world.living.advance(30.0)
    world.living_panel.refresh()
    if world.living.pending.is_empty():
        push_error("No mission from the Living Universe")
        quit(5)
        return
    world.coins = 500
    world._on_living_decision(1)
    if world.living.completed != 1:
        push_error("Incident UI connection failed")
        quit(6)
        return
    world.save_state()
    world.living.completed = 0
    world.load_state()
    if world.living.completed != 1:
        push_error("World state not restored in save/load")
        quit(7)
        return
    print("NEXUS V1.4 VISUAL SMOKE PASS: visuals, quality modes, incident UI, save/load")
    quit(0)
