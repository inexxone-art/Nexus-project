extends Node
class_name NexusWorldClock
## Stylised day/night and weather simulation. Not a climate or atmospheric physics model.
var hour: float = 9.0
var elapsed: float = 0.0
var weather: int = 0
var sun: DirectionalLight3D
var environment: WorldEnvironment
const LABELS = ["Klar", "Nebel", "Regen", "Schnee"]

func configure(light: DirectionalLight3D, env: WorldEnvironment) -> void:
    sun = light
    environment = env
    _refresh()

func _process(delta: float) -> void:
    if sun == null:
        return
    hour = fposmod(hour + delta * 0.045, 24.0)
    elapsed += delta
    if elapsed >= 100.0:
        elapsed = 0.0
        weather = (weather + 1) % LABELS.size()
    _refresh()

func _refresh() -> void:
    if sun == null or environment == null:
        return
    var phase = hour / 24.0 * TAU
    var daylight = clampf(sin(phase - PI * 0.5) * -1.0, 0.0, 1.0)
    # 12 noon -> high light; 00 midnight -> very low light
    daylight = clampf(-cos(phase), 0.0, 1.0)
    sun.rotation_degrees = Vector3(-15.0 - daylight * 65.0, -32.0, 0.0)
    sun.light_energy = 0.09 + 1.3 * daylight
    environment.environment.ambient_light_energy = 0.28 + daylight * 0.72
    environment.environment.fog_density = 0.014 if weather == 1 else (0.0048 if weather == 2 else (0.007 if weather == 3 else 0.0026))
    sun.light_color = Color("ccd5ea") if weather == 3 else Color("fff0d5")

func skip_hours(value: float) -> void:
    hour = fposmod(hour + value, 24.0)
    _refresh()

func describe() -> String:
    return "%02d:%02d | %s" % [int(hour), int((hour - floorf(hour)) * 60.0), LABELS[weather]]

func get_data() -> Dictionary:
    return {"hour": hour, "weather": weather}

func restore_data(d: Dictionary) -> void:
    hour = fposmod(float(d.get("hour", 9.0)), 24.0)
    weather = clampi(int(d.get("weather", 0)), 0, LABELS.size() - 1)
    _refresh()
