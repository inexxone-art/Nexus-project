extends Node
class_name NexusWeatherSurface
## Rain builds a wet-road layer over time; ground dries after precipitation.
## Uses the current weather clock rather than independent/random weather.

const SHADER = preload("res://shaders/nexus_wet_asphalt.gdshader")
const FALLBACK_ALBEDO = preload("res://assets/nexus_pbr_wet_street.png")
const FALLBACK_NORMAL = preload("res://assets/nexus_pbr_wet_street_normal.png")
const ASSETS = preload("res://scripts/nexus_production_assets.gd")

var road: ShaderMaterial
var clock: NexusWorldClock
var wetness: float = 0.0
var tick: float = 0.0

func make_road_material(tiling: float = 16.0) -> ShaderMaterial:
    road = ShaderMaterial.new()
    road.shader = SHADER
    var color_tex: Texture2D = ASSETS.surface_texture("asphalt", "albedo")
    var normal_tex: Texture2D = ASSETS.surface_texture("asphalt", "normal")
    road.set_shader_parameter("albedo_tex", color_tex if color_tex != null else FALLBACK_ALBEDO)
    road.set_shader_parameter("normal_tex", normal_tex if normal_tex != null else FALLBACK_NORMAL)
    road.set_shader_parameter("uv_tile", tiling)
    road.set_shader_parameter("wetness", wetness)
    return road

func set_clock(source: NexusWorldClock) -> void:
    clock = source

func _process(delta: float) -> void:
    if clock == null or road == null:
        return
    tick += delta
    if tick < 0.10:
        return
    var step: float = tick
    tick = 0.0
    var target: float = 1.0 if clock.weather == 2 else (0.18 if clock.weather == 3 else 0.0)
    wetness = move_toward(wetness, target, step * (0.14 if target > wetness else 0.045))
    road.set_shader_parameter("wetness", wetness)
