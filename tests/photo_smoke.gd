extends SceneTree
## Camera activation and UI restoration, no screenshot capture in CI.
const PLAYER = preload("res://scripts/player.gd")
const PHOTO = preload("res://scripts/nexus_photo_mode.gd")

func _initialize() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    push_error("PHOTO MODE FAILED: " + message)
    quit(1)

func _run() -> void:
    var stage := Node3D.new()
    root.add_child(stage)
    var actor: NexusPlayer = PLAYER.new()
    stage.add_child(actor)
    var camera: Camera3D = actor.camera
    var photo: NexusPhotoMode = PHOTO.new()
    stage.add_child(photo)
    var hud := Label.new()
    hud.visible = true
    root.add_child(hud)
    var entered: bool = photo.enter(camera, actor, [hud])
    if not entered or not photo.active or actor.active or hud.visible:
        _fail("Capture mode activation and HUD hiding")
        return
    if not photo.photo_camera.current:
        _fail("Photo camera is not the active camera")
        return
    photo.exit()
    if photo.active or not actor.active or not hud.visible or not camera.current:
        _fail("Input, camera and UI were not restored")
        return
    print("NEXUS V1.5 PHOTO MODE PASS: free camera activation and restoration")
    quit(0)
