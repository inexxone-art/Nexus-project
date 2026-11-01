extends Node
class_name NexusAudioDirector
## Original synthesized environmental soundtrack, no third-party samples.
## Placeholder for recorded engines, nature, footsteps and professional sound design.
var ambient: AudioStreamPlayer
var cue: AudioStreamPlayer
var muted: bool = false

func _ready() -> void:
    name = "NEXUS | Original Audio Prototype"
    ambient = AudioStreamPlayer.new()
    ambient.volume_db = -27.0
    ambient.stream = _make_wave(82.4,2.0,0.25,true)
    add_child(ambient)
    cue = AudioStreamPlayer.new()
    cue.volume_db = -16.0
    cue.stream = _make_wave(330.0,0.22,0.5,false)
    add_child(cue)
    if not Engine.is_editor_hint():
        ambient.play()

func _make_wave(frequency: float, duration: float, amplitude: float, looping: bool) -> AudioStreamWAV:
    var samples: int = int(22050 * duration)
    var bytes := PackedByteArray()
    bytes.resize(samples*2)
    for i in range(samples):
        var t: float = float(i)/22050.0
        var envelope: float = 1.0 if looping else maxf(0.0,1.0-t/duration)
        var wave: float = sin(TAU*frequency*t)*0.72 + sin(TAU*frequency*1.501*t)*0.20
        var val: int = clampi(int(wave * envelope * amplitude * 32000),-32768,32767)
        bytes[i*2] = val & 255
        bytes[i*2+1] = (val >> 8) & 255
    var stream := AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = 22050
    stream.stereo = false
    stream.data = bytes
    if looping:
        stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
        stream.loop_begin = 0
        stream.loop_end = samples
    return stream

func notify() -> void:
    if not muted and cue != null:
        cue.play()

func toggle_sound() -> bool:
    muted = not muted
    if ambient != null:
        ambient.stream_paused = muted
    return not muted
