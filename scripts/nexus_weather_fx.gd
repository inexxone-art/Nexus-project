extends Node3D
class_name NexusWeatherFX
## Camera-following local rain and snow. Intentionally lightweight: it does not simulate
## planet-scale weather, precipitation collisions or physically based wet surfaces.
var actor: Node3D
var clock: NexusWorldClock
var rain: CPUParticles3D
var snow: CPUParticles3D
var high_quality: bool = true
var update_elapsed: float = 0.0

func _ready() -> void:
    name = "NEXUS | Alpine Weather FX"
    rain = _create_precipitation(false)
    snow = _create_precipitation(true)
    add_child(rain)
    add_child(snow)
    rain.emitting = false
    snow.emitting = false

func bind_world(actor_node: Node3D, weather_clock: NexusWorldClock) -> void:
    actor = actor_node
    clock = weather_clock

func _create_precipitation(flakes: bool) -> CPUParticles3D:
    var particles := CPUParticles3D.new()
    particles.name = "Schneefall" if flakes else "Regen"
    particles.amount = 105 if flakes else 285
    particles.lifetime = 2.2 if flakes else 1.1
    particles.emission_shape = CPUParticles3D.EMISSION_SHAPE_BOX
    particles.emission_box_extents = Vector3(22,0.8,22)
    particles.direction = Vector3(0,-1,0)
    particles.spread = 16.0 if flakes else 5.0
    particles.gravity = Vector3(0,-3,0) if flakes else Vector3(0,-9,0)
    particles.initial_velocity_min = 1.5 if flakes else 18.0
    particles.initial_velocity_max = 3.8 if flakes else 24.0
    particles.local_coords = false
    var mesh := SphereMesh.new()
    mesh.radius = 0.055 if flakes else 0.018
    mesh.height = 0.12 if flakes else 0.18
    mesh.radial_segments = 5
    mesh.rings = 3
    var mat := StandardMaterial3D.new()
    mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    mat.albedo_color = Color(0.90,0.94,1.0,0.76) if flakes else Color(0.65,0.82,0.95,0.60)
    mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mesh.material = mat
    particles.mesh = mesh
    particles.visibility_aabb = AABB(Vector3(-28,-35,-28),Vector3(56,60,56))
    return particles

func _process(delta: float) -> void:
    update_elapsed += delta
    if update_elapsed < 0.15:
        return
    update_elapsed = 0.0
    if actor == null or clock == null:
        return
    global_position = actor.global_position + Vector3(0,14,0)
    var show_precipitation: bool = high_quality
    rain.emitting = show_precipitation and clock.weather == 2
    snow.emitting = show_precipitation and clock.weather == 3

func set_graphics_quality(high: bool) -> void:
    high_quality = high
    if not high:
        rain.emitting = false
        snow.emitting = false
