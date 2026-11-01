extends SceneTree
## Headless geometry and input regression. Does not certify visual realism.
const CATALOG = preload("res://scripts/nexus_vehicle_catalog.gd")
const VEHICLE = preload("res://scripts/vehicle.gd")

func _initialize() -> void:
    call_deferred("_run")

func _run() -> void:
    var sample: Dictionary = {}
    for record in CATALOG.all():
        if not sample.has(str(record["kind"])):
            sample[str(record["kind"])] = record
    if sample.size() != 5:
        push_error("Expected one sample for each of five vehicle kinds")
        quit(1)
        return
    for kind in ["car","tank","helicopter","excavator","utility"]:
        var v := VEHICLE.new()
        v.configure(sample[kind])
        root.add_child(v)
        await process_frame
        if v.visuals == null or v.visuals.get_child_count() < 8:
            push_error("Incomplete visual assembly: " + kind)
            quit(2)
            return
        if v.get_node_or_null("Fahrzeugkollision") == null or v.camera == null:
            push_error("Missing collision / camera: " + kind)
            quit(3)
            return
        if kind == "car" and v.visuals.wheel_spinners.size() != 4:
            push_error("Car must have four rotatable wheels")
            quit(4)
            return
        if kind == "tank" and v.visuals.get_node_or_null("Drehbarer Turm") == null:
            push_error("Tank turret missing")
            quit(5)
            return
        if kind == "helicopter" and (v.visuals.rotor_main == null or v.visuals.rotor_tail == null):
            push_error("Helicopter rotor parts missing")
            quit(6)
            return
        if kind == "excavator" and (v.visuals.boom_pivot == null or v.visuals.bucket_pivot == null):
            push_error("Excavator articulated arm missing")
            quit(7)
            return
        v.visuals.animate_vehicle(0.016,5.0,0.5,false,100.0)
        v.queue_free()
        await process_frame
    print("NEXUS V1.7 VEHICLE DETAIL SMOKE PASS: 5 classes, geometry, dynamics nodes")
    quit(0)
