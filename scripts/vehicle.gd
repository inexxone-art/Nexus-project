extends CharacterBody3D
class_name NexusVehicle
## Shared vehicle driving controller for the full catalog.
## V1.7: distinct procedural visual assemblies, working steering/wheels,
## helicopter rotors, excavator boom, running lights, model-sized collision.
## Arcade handling is intentional; not a certified vehicle dynamics simulator.

const VISUAL_SCRIPT = preload("res://scripts/nexus_vehicle_visuals.gd")
const DRIVE_MODEL = preload("res://scripts/nexus_drive_model.gd")
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
var weather_code: int = 0
var distance_km: float = 0.0
var tire_grip: float = 1.0
var tune_motor: int = 0
var tune_tires: int = 0
var tune_brakes: int = 0

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
    var kind: String = str(definition.get("kind","car"))
    tire_grip = DRIVE_MODEL.grip_factor(kind,weather_code) * (1.0 + 0.06*float(tune_tires))
    var top_speed: float = DRIVE_MODEL.maximum_speed_kmh(definition,condition,fuel)*(1.0+0.045*float(tune_motor))/3.6
    var accel: float = maxf(0.5,float(definition.get("acceleration",6.0)))*(1.0+0.075*float(tune_motor))
    var handling: float = clampf(float(definition.get("handling",0.72)),0.3,1.8)
    var steer_input: float = 0.0
    if controlled and fuel > 0.0 and condition > 0.0:
        var throttle: float = Input.get_axis("move_backward","move_forward")
        steer_input = Input.get_axis("move_left","move_right")
        var target_speed: float = throttle * top_speed * (0.42 if throttle < 0 else 1.0)
        var health_factor: float = clampf(condition/100.0,0.25,1.0)
        var acceleration: float = accel*health_factor*tire_grip
        if absf(target_speed) < absf(speed):
            acceleration *= 1.8
        speed = move_toward(speed,target_speed,delta*acceleration)
        if Input.is_action_pressed("jump") and category != "Helikopter":
            speed = move_toward(speed,0.0,delta*(20.0+float(tune_brakes)*5.0)*tire_grip)
        steer_angle = move_toward(steer_angle,steer_input,delta*(2.1+tire_grip))
        if absf(speed) > 0.2:
            var steering_authority: float = clampf(tire_grip*(1.0-absf(speed)/maxf(30.0,top_speed*2.1)),0.25,1.0)
            rotate_y(-steer_angle*delta*handling*steering_authority*signf(speed))
        fuel = maxf(0.0,fuel-absf(speed)*delta*0.006)
        distance_km += absf(speed)*delta/1000.0
        condition = maxf(0.0,condition - absf(speed)*delta*0.000025)
    else:
        speed = move_toward(speed,0.0,delta*7.0*tire_grip)
        steer_angle = move_toward(steer_angle,0.0,delta*3.0)
    if category == "Helikopter" and controlled and fuel > 0.0:
        var lift: float = (1.0 if Input.is_action_pressed("jump") else 0.0)-(1.0 if Input.is_action_pressed("sprint") else 0.0)
        velocity.y = move_toward(velocity.y,lift*7.0,delta*8.0)
    elif not is_on_floor():
        velocity.y -= 18.0*delta
    else:
        velocity.y = -0.3
    var forward: Vector3 = -global_transform.basis.z
    velocity.x = forward.x*speed
    velocity.z = forward.z*speed
    move_and_slide()
    # Reduced integrity when a moving vehicle strikes solid objects.
    if controlled and get_slide_collision_count() > 0 and absf(speed) > 8.0:
        condition = maxf(0.0,condition - delta*minf(absf(speed)*0.6,12.0))
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
