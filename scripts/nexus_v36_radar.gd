extends Control
class_name NexusV36Radar
## A real moving map instrument, not a baked photo of the reference.
var world
const EDGE := 168.0
const RADIUS := 77.0
const SCALE := 0.72
var elapsed := 0.0

func _ready() -> void:
    name = "Circular tactical radar"
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    custom_minimum_size = Vector2(EDGE,EDGE)
    size = Vector2(EDGE,EDGE)

func _process(delta: float) -> void:
    elapsed += delta
    if elapsed >= 0.12:
        elapsed = 0.0
        queue_redraw()

func _draw() -> void:
    var center := Vector2(EDGE*0.5,EDGE*0.5)
    draw_circle(center,RADIUS,Color(0.02,0.065,0.09,0.83))
    for radius in [24.0,49.0,75.0]:
        draw_arc(center,radius,0,TAU,96,Color(0.45,0.61,0.57,0.34),1.0)
    for i in range(8):
        var heading: float = float(i)*TAU/8.0
        var ray := Vector2(cos(heading),sin(heading))
        draw_line(center+ray*6,center+ray*RADIUS,Color(0.17,0.33,0.32,0.37),1.0)
    draw_arc(center,RADIUS,0,TAU,128,Color(0.85,0.91,0.84,0.9),2.0)
    var font := ThemeDB.fallback_font
    draw_string(font,Vector2(center.x-5,9),"N",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color.WHITE)
    draw_string(font,Vector2(center.x-5,EDGE-2),"S",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color.WHITE)
    draw_string(font,Vector2(3,center.y+4),"W",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color.WHITE)
    draw_string(font,Vector2(EDGE-12,center.y+4),"E",HORIZONTAL_ALIGNMENT_LEFT,-1,13,Color.WHITE)
    if world == null or world.player == null:
        return
    var pos: Vector3 = world.player.global_position
    if world.vehicle_in_use != null:
        pos = world.vehicle_in_use.global_position
    var gorge := Vector3(175,0,168)
    _pin(center,pos,gorge,Color("f8c74d"),9.0)
    if world.nexus_v35 != null:
        var m = world.nexus_v35.rescue
        if m != null and m.phase == "active":
            for i in range(m.TARGETS.size()):
                if not m.rescued.has(i):
                    _pin(center,pos,m.TARGETS[i],Color("f3b64d"),4.0)
        var industry = world.nexus_v35.industry
        if industry != null:
            for id in industry.SITES.keys():
                if industry.built.has(id):
                    _pin(center,pos,industry.SITES[id]["position"],Color("93cebb"),3.0)
    draw_circle(center,5.5,Color("eaf2f3"))
    var forward: Vector3 = -world.player.global_basis.z if world.vehicle_in_use == null else -world.vehicle_in_use.global_basis.z
    draw_colored_polygon(PackedVector2Array([center+Vector2(forward.x,-forward.z).normalized()*11.0,center+Vector2(-4,5),center+Vector2(4,5)]),Color("4ec8f7"))

func _pin(center: Vector2,origin: Vector3,position: Vector3,tint: Color,radius: float) -> void:
    var delta := Vector2(position.x-origin.x,origin.z-position.z)*SCALE
    var point := center+delta.limit_length(RADIUS-7.0)
    draw_circle(point,radius,tint)
    draw_arc(point,radius+2,0,TAU,24,Color.BLACK,1.0)
