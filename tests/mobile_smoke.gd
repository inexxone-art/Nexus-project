extends SceneTree
## Validates touch UI input actions without requiring a touchscreen in CI.
const CONTROLS = preload("res://scripts/nexus_mobile_controls.gd")

func _initialize() -> void:
    call_deferred("_run")

func _failed(message: String) -> void:
    push_error("NEXUS TOUCH FAILED: " + message)
    quit(1)

func _run() -> void:
    var mobile: NexusMobileControls = CONTROLS.new()
    root.add_child(mobile)
    mobile.visible = true
    if mobile.controls.size() != 12:
        _failed("Expected twelve distinct touch controls")
        return
    var forward: Button = mobile.controls["up"]
    forward.button_down.emit()
    if not Input.is_action_pressed("move_forward"):
        _failed("Touch button did not press movement action")
        return
    forward.button_up.emit()
    if Input.is_action_pressed("move_forward"):
        _failed("Movement input remained held after release")
        return
    var sprint: Button = mobile.controls["sprint"]
    sprint.button_down.emit()
    mobile.visible = false
    sprint.visible = false
    if Input.is_action_pressed("sprint"):
        _failed("Hiding controls did not release movement action")
        return
    print("NEXUS TOUCH PASS: 12 responsive controls, press/release and visibility cleanup")
    quit(0)
