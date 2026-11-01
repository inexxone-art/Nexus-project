extends CharacterBody3D
class_name NexusVehicle
## Shared vehicle driving controller for the full catalog.
## V1.7: distinct procedural visual assemblies, working steering/wheels,
## helicopter rotors, excavator boom, running lights, model-sized collision.
## Arcade handling is intentional; not a certified vehicle dynamics simulator.

const VISUAL_SCRIPT = preload("res://scripts/nexus_vehicle_visuals.gd")
var category: String = "Traktor"
var definition: Dictionary = {}
var model_name: String = ""
var controlled: bool = false
var speed: float = 0.0
var fuel: float = 85.0
var condition: float = 100.0
var steer_angle: float = 0.0
var camera: Camera3D
var chase_view: bool = true
var visuals: Node3D
var rotor_speed: float = 0.0

func configure(record: Dictionary) -> void:
    definition = record.duplicate(true)
    model_name = str(definition.get("name", ""))
    match str(definition.get("kind", "")):
        "tank": category = "Panzer"
        "helicopter": category = "Helikopter"
        "excavator": category = "Bagger"
        "utility":
            var family: String = str(definition.get("family", ""))
            category = "Rettung" if family in ["ambulance","firetruck","police","rescue"] else ("Traktor" if family in ["tractor","harvester"] else "LKW")
        "car":
            var family: String = str(definition.get("family", ""))
            category = "Rettung" if family == "emergency" else ("Sportwagen" if family in ["coupe","supercar"] else "Auto")

func _ready() -> void:
    name = model_name if model_name != "" else category
    var bounds := CollisionShape3D.new()
    bounds.name = "Fahrzeugkollision"
    var box := BoxShape3D.new()
    box.size = Vector3(clampf(float(definition.get("width",2.3)),1.5,4.9),
        2.3 if category != "Helikopter" else 3.2,
        clampf(float(definition.get("length",4.6)),2.8,15.5))
    bounds.shape = box
    bounds.position.y = 1.20 if category != "Helikopter" else 2.0
    add_child(bounds)
    visuals = VISUAL_SCRIPT.new()
    visuals.set_vehicle(definition,category)
    add_child(visuals)
    camera = Camera3D.new()
    camera.name = "Fahrzeugkamera"
    camera.position = Vector3(0,4.1,9.0)
    camera.fov = 75.0
    camera.current = false
    add_child(camera)
    camera.look_at(Vector3(0,1.65,-4.0),Vector3.UP)

func _physics_process(delta: float) -> void:
    var turn: float = 0.0
    var top_speed: float = 26.0 if category == "Sportwagen" else (15.0 if category == "LKW" else (18.0 if category == "Helikopter" else 13.0))
    var accel: float = 7.0
    var handling: float = 0.82
    if not definition.is_empty():
        top_speed = maxf(2.0,float(definition.get("top_kmh",85.0))/3.6)
        accel = maxf(0.5,float(definition.get("acceleration",6.0)))
        handling = clampf(float(definition.get("handling",0.72)),0.3,1.8)
    if controlled and fuel > 0 and condition > 0:
        var throttle: float = Input.get_axis("move_backward","move_forward")
        turn = Input.get_axis("move_left","move_right")
        var target_speed: float = throttle * top_speed * (0.48 if throttle < 0 else 1.0)
        var condition_factor: float = clampf(condition/100.0,0.25,1.0)
        speed = move_toward(speed,target_speed,delta*accel*condition_factor)
        if Input.is_action_pressed("jump") and category != "Helikopter":
            speed = move_toward(speed,0,delta*21.0)
        steer_angle = move_toward(steer_angle,turn,delta*3.4)
        if absf(speed)>0.2:
            rotate_y(-steer_angle*delta*handling*signf(speed)*minf(1.0,absf(speed)/4.0))
        fuel = maxf(0.0,fuel-absf(speed)*delta*0.006)
    else:
        speed = move_toward(speed,0.0,delta*8.0)
        steer_angle = move_toward(steer_angle,0.0,delta*3.4)
    if category == "Helikopter" and controlled and fuel>0:
        var lift: float = (1.0 if Input.is_action_pressed("jump") else 0.0)-(1.0 if Input.is_action_pressed("sprint") else 0.0)
        velocity.y = move_toward(velocity.y,lift*7.0,delta*8.0)
    elif not is_on_floor():
        velocity.y -= 18.0*delta
    else:
        velocity.y = -0.3
    var forward := -global_transform.basis.z
    velocity.x = forward.x*speed
    velocity.z = forward.z*speed
    move_and_slide()
    if visuals != null:
        visuals.animate_vehicle(delta,speed,steer_angle,controlled,fuel)

func set_control(value: bool) -> void:
    controlled = value
    if camera != null:
        camera.current = value

func switch_view() -> void:
    chase_view = not chase_view
    if camera == null: return
    camera.position = Vector3(0,2.24,0.58) if not chase_view else Vector3(0,4.1,9.0)
    camera.rotation = Vector3.ZERO
    camera.look_at(Vector3(0,1.9,-7.0) if not chase_view else Vector3(0,1.65,-4.0),Vector3.UP)
