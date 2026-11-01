extends Control
## Compact, low-overhead navigation map; world positions are real game coordinates.
var drone: Node3D
var player: Node3D
var vehicles: Array = []
var stations: Array = []
const SIZE = 238.0
const RANGE = 230.0

func _ready() -> void:
    custom_minimum_size = Vector2(SIZE, SIZE)
    size = Vector2(SIZE, SIZE)
    mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_delta: float) -> void:
    if visible:
        queue_redraw()

func _to_map(p: Vector3) -> Vector2:
    return Vector2(SIZE * 0.5 + p.x / RANGE * (SIZE * 0.46), SIZE * 0.5 + p.z / RANGE * (SIZE * 0.46))

func _draw() -> void:
    draw_rect(Rect2(0, 0, SIZE, SIZE), Color(0.03, 0.09, 0.13, 0.85), true)
    draw_rect(Rect2(1, 1, SIZE-2, SIZE-2), Color(0.55, 0.68, 0.72, 0.75), false, 1.5)
    var c = Vector2(SIZE * 0.5, SIZE * 0.5)
    draw_line(c + Vector2(-110, 0), c + Vector2(110, 0), Color(0.48, 0.52, 0.54), 3)
    draw_line(c + Vector2(-20, -20), c + Vector2(-20, 20), Color(0.48, 0.52, 0.54), 2)
    for station in stations:
        if not is_instance_valid(station["node"]):
            continue
        var q = _to_map(station["node"].global_position)
        var color = Color(0.96, 0.75, 0.29) if station["kind"] in ["oil", "mine", "refinery", "meteor"] else Color(0.53, 0.89, 0.61)
        draw_circle(q, 3.8, color)
    for v in vehicles:
        if is_instance_valid(v):
            draw_circle(_to_map(v.global_position), 2.4, Color(0.5, 0.7, 0.98))
    if is_instance_valid(drone):
        draw_circle(_to_map(drone.global_position), 4.1, Color(0.88, 0.52, 0.9))
    if is_instance_valid(player):
        var q = _to_map(player.global_position)
        draw_circle(q, 5.5, Color.WHITE)
        var f = -player.global_transform.basis.z
        draw_line(q, q + Vector2(f.x, f.z) * 12, Color(0.96, 0.29, 0.31), 2.5)
    draw_string(ThemeDB.fallback_font, Vector2(10, 17), "NEXUS / KARTE", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color.WHITE)
    draw_string(ThemeDB.fallback_font, Vector2(10, SIZE - 10), "N: Karte ein/aus", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.82,0.86,0.88))
