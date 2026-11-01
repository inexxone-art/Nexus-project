extends CanvasLayer
class_name NexusPerformancePanel
## Mobile-friendly quality control; displays measured FPS, never fabricated results.
signal quality_changed(mode: int)
var panel: PanelContainer
var label: Label
var mode: int = 1
var visible_stats: bool = false
const QUALITY_NAMES: Array[String] = ["MOBILE", "BALANCED", "CINEMATIC"]

func _ready() -> void:
    name = "NEXUS | Performance Monitor"
    layer = 20
    panel = PanelContainer.new()
    panel.position = Vector2(14, 105)
    panel.custom_minimum_size = Vector2(220,70)
    add_child(panel)
    var column := VBoxContainer.new()
    panel.add_child(column)
    label = Label.new()
    column.add_child(label)
    var cycle := Button.new()
    cycle.text = "Grafikprofil wechseln"
    cycle.pressed.connect(cycle_quality)
    column.add_child(cycle)
    panel.visible = false
    set_process(true)

func _process(_delta: float) -> void:
    if visible_stats:
        label.text = "FPS: %d | %s\n3D: %s" % [Engine.get_frames_per_second(),QUALITY_NAMES[mode],"Forward+ / Compatibility"]

func cycle_quality() -> void:
    mode = (mode+1)%QUALITY_NAMES.size()
    quality_changed.emit(mode)

func toggle() -> void:
    visible_stats = not visible_stats
    panel.visible = visible_stats

func quality_is_high() -> bool:
    return mode == 2
