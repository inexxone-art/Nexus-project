extends Node3D
class_name NexusBusArtV37
## Secondary rescue bus detailing attached to a moving RigidBody3D.
## Curved roof/glass shapes, body seams and passenger seating remain lightweight
## procedural replacements. This is not a manufactured licensed bus scan.
var decorative_panels: int = 0

func _ready() -> void:
    name = "Detailed bus shell, windows, mirrors, seating and mechanical fittings"
    var trim := _mat(Color("313d42"),0.51,0.46)
    var paint := _mat(Color("e6e7e1"),0.37,0.43)
    var blue := _mat(Color("406c83"),0.27,0.49)
    var rubber := _mat(Color("252a2b"),0.01,0.94)
    var glass := _mat(Color(0.30,0.46,0.53,0.85),0.13,0.16)
    glass.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    glass.clearcoat_enabled = true
    var lamp := _mat(Color("fce3b6"),0.07,0.19)
    lamp.emission_enabled = true
    lamp.emission = Color("ead7a1")
    lamp.emission_energy_multiplier = 2.0
    _curved_roof(paint)
    _wraparound_front(glass,trim)
    _part("Lower aerodynamic bumper",Vector3(0,-1.29,-5.43),Vector3(2.35,0.34,0.21),trim)
    _part("Front illuminated destination display",Vector3(0,1.15,-5.41),Vector3(2.08,0.36,0.12),blue)
    _part("Radiator opening",Vector3(0,-1.05,-5.55),Vector3(1.21,0.38,0.10),rubber)
    _part("Roof HVAC",Vector3(0,1.91,-0.50),Vector3(1.55,0.36,2.30),trim)
    for side in [-1.0,1.0]:
        for i in range(7):
            var z := -3.58+float(i)*1.17
            _part("Window top metallic frame",Vector3(float(side)*1.38,1.03,z),Vector3(0.08,0.055,1.0),trim)
            _part("Window bottom metallic frame",Vector3(float(side)*1.38,-0.16,z),Vector3(0.08,0.07,1.0),trim)
            _part("Window vertical mullion",Vector3(float(side)*1.39,0.4,z+0.51),Vector3(0.07,1.15,0.045),trim)
            _part("Passenger interior seat",Vector3(float(side)*0.72,-0.42,z+0.2),Vector3(0.68,0.9,0.53),blue)
        var mirror := _part("Bus front side mirror",Vector3(float(side)*1.64,0.55,-4.64),Vector3(0.28,0.47,0.15),trim)
        mirror.rotation.z = float(side)*0.15
        for z in [-3.55,3.55]:
            _wheel_rim(float(side)*1.54,-1.34,z,trim,rubber)
        _part("Side safety stripe",Vector3(float(side)*1.376,-0.93,0.0),Vector3(0.025,0.17,10.3),blue)
    for z in [-4.7,4.7]:
        _part("Worn roof drip edge",Vector3(0,1.65,z),Vector3(2.4,0.06,0.14),trim)
    for x in [-0.80,0.80]:
        _part("Recessed headlamp surround",Vector3(x,-1.02,-5.52),Vector3(0.45,0.27,0.08),lamp)
    for i in range(5):
        _part("Body joint line",Vector3(0,-1.52,-3.75+float(i)*1.83),Vector3(2.64,0.035,0.055),trim)
    var sign := Label3D.new()
    sign.name = "Alpine rescue express destination lettering"
    sign.text = "NEXUS | ADLERKLAMM"
    sign.position = Vector3(0,1.14,-5.51)
    sign.pixel_size = 0.006
    sign.font_size = 37
    sign.modulate = Color("d9e8ea")
    add_child(sign)

func _mat(color: Color, metal: float, rough: float) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = metal
    material.roughness = rough
    return material

func _part(label: String,center: Vector3,dimensions: Vector3,material: Material) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = label
    var box := BoxMesh.new()
    box.size = dimensions
    node.mesh = box
    node.material_override = material
    node.position = center
    add_child(node)
    decorative_panels += 1
    return node

func _curved_roof(material: Material) -> void:
    var surface := SurfaceTool.new()
    surface.begin(Mesh.PRIMITIVE_TRIANGLES)
    for i in range(14):
        var a := -PI*0.5+PI*float(i)/14.0
        var b := -PI*0.5+PI*float(i+1)/14.0
        var xa := 1.34*sin(a)
        var xb := 1.34*sin(b)
        var ya := 1.54+0.23*cos(a)
        var yb := 1.54+0.23*cos(b)
        var points := [Vector3(xa,ya,-5.1),Vector3(xb,yb,-5.1),Vector3(xa,ya,5.1),
                       Vector3(xb,yb,-5.1),Vector3(xb,yb,5.1),Vector3(xa,ya,5.1)]
        for p in points:
            surface.set_uv(Vector2(p.x*0.22,p.z*0.2))
            surface.add_vertex(p)
    surface.generate_normals()
    var mesh := MeshInstance3D.new()
    mesh.name = "Curved roof shell instead of a rectangular box"
    mesh.mesh = surface.commit()
    mesh.material_override = material
    add_child(mesh)
    decorative_panels += 1

func _wraparound_front(glazing: Material,trim: Material) -> void:
    for i in range(8):
        var t := (float(i)+0.5)/8.0-0.5
        var glass_pane := _part("Curved windshield glass pane",Vector3(t*2.12,0.48,-5.44-0.23*(1.0-t*t)),Vector3(0.28,1.28,0.05),glazing)
        glass_pane.rotation.y = t*0.14
        _part("Thin structural windshield mullion",Vector3(t*2.12+0.14,0.49,-5.53),Vector3(0.024,1.4,0.035),trim)

func _wheel_rim(x: float,y: float,z: float,metal: Material,tire: Material) -> void:
    var ring := MeshInstance3D.new()
    ring.name = "Alloy wheel rim / brake assembly"
    var wheel := CylinderMesh.new()
    wheel.top_radius = 0.38
    wheel.bottom_radius = 0.38
    wheel.height = 0.04
    wheel.radial_segments = 16
    ring.mesh = wheel
    ring.position = Vector3(x,y,z)
    ring.rotation.z = PI*0.5
    ring.material_override = metal
    add_child(ring)
    decorative_panels += 1
    for j in range(7):
        var a := TAU*float(j)/7.0
        _part("Wheel lug",Vector3(x+0.02,y+cos(a)*0.16,z+sin(a)*0.16),Vector3(0.07,0.075,0.075),tire)
