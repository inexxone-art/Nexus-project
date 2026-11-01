extends Node3D
## V1.7 procedural vehicle art. Original meshes/materials: no external 3D-asset licensing.
## Details scale from catalog dimensions and family. High-level game-ready blockout,
## NOT photogrammetry or production AAA vehicle assets.

var spec: Dictionary = {}
var kind: String = "car"
var family: String = "sedan"
var base_color: Color = Color("496f83")
var wheel_spinners: Array[Node3D] = []
var front_steer: Array[Node3D] = []
var rotor_main: Node3D
var rotor_tail: Node3D
var boom_pivot: Node3D
var bucket_pivot: Node3D
var emergency_lights: Array[OmniLight3D] = []
var lamps: Array[SpotLight3D] = []
var running_time: float = 0.0
var wheel_radius: float = 0.49
var width: float = 1.85
var length: float = 4.6
var mats: Dictionary = {}
const HERO_DETAILS = preload("res://scripts/nexus_hero_vehicles.gd")
var hero_details: Node3D

func set_vehicle(definition: Dictionary, vehicle_category: String) -> void:
    spec = definition.duplicate(true)
    kind = str(spec.get("kind", _infer_kind(vehicle_category)))
    family = str(spec.get("family", "sedan"))
    length = clampf(float(spec.get("length", 4.7)), 2.6, 15.0)
    width = clampf(float(spec.get("width", 1.95)), 1.4, 4.6)
    var palette := {"Panzer":"66705c", "Bagger":"e6ac32", "Helikopter":"b9c7ce", "LKW":"b6a08a", "Rettung":"f2efe6", "Sportwagen":"a73732", "Traktor":"4a6b3e"}
    base_color = Color(str(spec.get("color", palette.get(vehicle_category,"496f83"))))

func _infer_kind(category: String) -> String:
    if category == "Panzer": return "tank"
    if category == "Bagger": return "excavator"
    if category == "Helikopter": return "helicopter"
    if category in ["LKW","Traktor","Rettung"]: return "utility"
    return "car"

func _ready() -> void:
    name = "NEXUS Fahrzeugdesign | " + str(spec.get("name",kind))
    match kind:
        "tank": _build_tank()
        "excavator": _build_excavator()
        "helicopter": _build_helicopter()
        "utility": _build_utility()
        _: _build_car()
    if str(spec.get("id", "")) in HERO_DETAILS.FEATURE_IDS:
        hero_details = HERO_DETAILS.new()
        hero_details.call("configure", spec, self)
        add_child(hero_details)

func _mat(color: Color, metallic: float = 0.0, roughness: float = 0.42, emission: bool = false) -> StandardMaterial3D:
    var key := "%s-%0.2f-%0.2f-%s" % [color.to_html(),metallic,roughness,str(emission)]
    if mats.has(key): return mats[key]
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.metallic = metallic
    m.roughness = roughness
    if emission:
        m.emission_enabled = true
        m.emission = color
        m.emission_energy_multiplier = 3.0
    if metallic > 0.1 and roughness < 0.5:
        m.clearcoat_enabled = true
        m.clearcoat = 0.42
        m.clearcoat_roughness = 0.18
    mats[key] = m
    return m

func _box(parent: Node3D, label: String, dim: Vector3, pos: Vector3, mat: Material, rot: Vector3 = Vector3.ZERO) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = label
    var mesh := BoxMesh.new()
    mesh.size = dim
    node.mesh = mesh
    node.material_override = mat
    node.position = pos
    node.rotation = rot
    parent.add_child(node)
    return node

func _ball(parent: Node3D, label: String, radius: float, pos: Vector3, mat: Material) -> void:
    var n := MeshInstance3D.new()
    n.name = label
    var mesh := SphereMesh.new()
    mesh.radius = radius
    mesh.height = radius * 2.0
    mesh.radial_segments = 12
    mesh.rings = 6
    n.mesh = mesh
    n.position = pos
    n.material_override = mat
    parent.add_child(n)

func _cylinder(parent: Node3D, label: String, radius: float, height: float, pos: Vector3, mat: Material, rot: Vector3 = Vector3.ZERO, sides: int = 18) -> MeshInstance3D:
    var n := MeshInstance3D.new()
    n.name = label
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = sides
    n.mesh = mesh
    n.position = pos
    n.rotation = rot
    n.material_override = mat
    parent.add_child(n)
    return n

func _loft(parent: Node3D, label: String, sections: Array, paint: Material) -> void:
    # A continuous, closed, 12-sided longitudinal shell, unlike overlapping cubes.
    # Each section: [z, half width, lower height, shoulder height, top height].
    var rings: Array = []
    for s in sections:
        var z: float = float(s[0]); var w: float = float(s[1])
        var low: float = float(s[2]); var shoulder: float = float(s[3]); var high: float = float(s[4])
        rings.append([
            Vector3(-w * 0.83,low,z), Vector3(w * 0.83,low,z),
            Vector3(w,low+0.16,z), Vector3(w,shoulder-0.09,z),
            Vector3(w * 0.93,shoulder,z), Vector3(w * 0.78,high,z),
            Vector3(-w * 0.78,high,z), Vector3(-w * 0.93,shoulder,z),
            Vector3(-w,shoulder-0.09,z), Vector3(-w,low+0.16,z)
        ])
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    for r in range(rings.size()-1):
        for j in range(10):
            var k := (j+1)%10
            _triangle(st,rings[r][j],rings[r+1][k],rings[r+1][j])
            _triangle(st,rings[r][j],rings[r][k],rings[r+1][k])
    # Close front and rear with faces.
    var first: Array = rings[0]; var last: Array = rings[-1]
    var ca := Vector3(0,float(sections[0][3]),float(sections[0][0]))
    var cb := Vector3(0,float(sections[-1][3]),float(sections[-1][0]))
    for j in range(10):
        _triangle(st,ca,first[(j+1)%10],first[j])
        _triangle(st,cb,last[j],last[(j+1)%10])
    st.generate_normals()
    var node := MeshInstance3D.new()
    node.name = label
    node.mesh = st.commit()
    node.material_override = paint
    parent.add_child(node)

func _triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
    st.add_vertex(a)
    st.add_vertex(b)
    st.add_vertex(c)

func _wheel(x: float, z: float, radius: float, steerable: bool = false) -> void:
    var pivot := Node3D.new()
    pivot.name = "Lenkachse" if steerable else "Radaufhaengung"
    pivot.position = Vector3(x, radius+0.12,z)
    add_child(pivot)
    var spin := Node3D.new()
    spin.name = "Drehbares_Rad"
    pivot.add_child(spin)
    var side: float = signf(x)
    _cylinder(spin,"Reifen | Gummi",radius,0.26,Vector3.ZERO,_mat(Color("202226"),0.0,0.96),Vector3(0,0,PI/2),24)
    _cylinder(spin,"Alufelge | Bremsscheibe",radius*0.61,0.277,Vector3.ZERO,_mat(Color("90979b"),0.78,0.3),Vector3(0,0,PI/2),20)
    for i in range(5):
        var theta := TAU * i / 5.0
        _box(spin,"Felgenspeiche %d"%i,Vector3(0.025,0.09,radius*0.82),Vector3(side*0.155,sin(theta)*radius*0.21,cos(theta)*radius*0.21),_mat(Color("d3d5d2"),0.82,0.24),Vector3(theta,0,0))
    _cylinder(spin,"Radnabe",radius*0.13,0.3,Vector3.ZERO,_mat(Color("3b4247"),0.65,0.32),Vector3(0,0,PI/2),16)
    wheel_spinners.append(spin)
    if steerable: front_steer.append(pivot)

func _light(parent: Node3D, label: String, p: Vector3, color: Color, tail: bool = false, spot: bool = false) -> void:
    _box(parent,label,Vector3(0.30,0.125,0.075),p,_mat(color,0.02,0.22,true))
    if spot:
        var lamp := SpotLight3D.new()
        lamp.name = "Abblendlicht"
        lamp.position = p+Vector3(0,0,-0.08)
        lamp.rotation_degrees.x = -6.0
        lamp.spot_range = 19.0
        lamp.spot_angle = 40.0
        lamp.light_color = Color("ffecc9")
        lamp.light_energy = 0.0
        lamp.shadow_enabled = false
        parent.add_child(lamp)
        lamps.append(lamp)

func _trim(parent: Node3D, zf: float, zr: float, w: float, roof: float, body: Color) -> void:
    var black := _mat(Color("202a30"),0.10,0.22)
    var glass := _mat(Color("284754"),0.22,0.14)
    var chrome := _mat(Color("afb8bf"),0.81,0.25)
    var cabin_front := zf * 0.34
    var cabin_rear := zr * 0.4
    _box(parent,"Dach | Karosserie",Vector3(w*0.78,0.085,abs(cabin_rear-cabin_front)*0.83),Vector3(0,roof,cabin_front+(cabin_rear-cabin_front)*0.5),_mat(body,0.48,0.25))
    _box(parent,"Frontscheibe",Vector3(w*0.71,roof-1.46,0.045),Vector3(0,(roof+1.45)*0.5,cabin_front),glass,Vector3(-0.22,0,0))
    _box(parent,"Heckscheibe",Vector3(w*0.70,roof-1.46,0.045),Vector3(0,(roof+1.45)*0.5,cabin_rear),glass,Vector3(0.28,0,0))
    for side in [-1.0,1.0]:
        _box(parent,"Seitenscheibe vorne",Vector3(0.04,roof-1.51,0.82),Vector3(side*w*0.405,(roof+1.52)*0.5,cabin_front+0.44),glass)
        _box(parent,"Seitenscheibe hinten",Vector3(0.04,roof-1.51,0.72),Vector3(side*w*0.405,(roof+1.52)*0.5,cabin_rear-0.37),glass)
        _box(parent,"Tuergriff",Vector3(0.035,0.042,0.19),Vector3(side*w*0.505,1.38,0.24),chrome)
        _box(parent,"Aussenspiegel",Vector3(0.28,0.15,0.19),Vector3(side*(w*0.52+0.14),1.71,cabin_front+0.03),black)
        _box(parent,"Schweller",Vector3(0.075,0.09,abs(zr-zf)*0.67),Vector3(side*w*0.49,0.78,0),black)
        _box(parent,"Tuerspalt",Vector3(0.018,0.55,0.03),Vector3(side*w*0.513,1.18,0.34),black)
    _box(parent,"Frontgrill",Vector3(w*0.48,0.27,0.09),Vector3(0,1.11,zf-0.055),black)
    _box(parent,"Kuehlergrill Chromrand",Vector3(w*0.51,0.035,0.11),Vector3(0,1.30,zf-0.07),chrome)
    _box(parent,"Frontstossfaenger",Vector3(w*0.92,0.20,0.21),Vector3(0,0.87,zf+0.02),black)
    _box(parent,"Heckstossfaenger",Vector3(w*0.92,0.20,0.20),Vector3(0,0.88,zr-0.02),black)
    _box(parent,"Kennzeichen vorne",Vector3(0.36,0.115,0.02),Vector3(0,0.94,zf-0.12),_mat(Color("e7e5dd")))
    _box(parent,"Kennzeichen hinten",Vector3(0.36,0.115,0.02),Vector3(0,0.94,zr+0.12),_mat(Color("e7e5dd")))
    for side in [-1.0,1.0]:
        _light(parent,"LED Scheinwerfer",Vector3(side*w*0.36,1.23,zf-0.13),Color("fff3d5"),false,true)
        _light(parent,"Rueckleuchte",Vector3(side*w*0.37,1.22,zr+0.14),Color("da3430"),true)
        _box(parent,"Blinker vorne",Vector3(0.12,0.075,0.07),Vector3(side*w*0.48,1.16,zf-0.11),_mat(Color("dd994b"),0.0,0.3,true))
    _interior(parent,roof,0.4,w)

func _interior(parent: Node3D,roof: float,cabin_center: float,w: float) -> void:
    var dark := _mat(Color("222326"),0.05,0.88)
    var leather := _mat(Color("373538"),0.0,0.72)
    _box(parent,"Cockpit Armaturenbrett",Vector3(w*0.73,0.19,0.4),Vector3(0,1.50,cabin_center-0.8),dark)
    for side in [-1.0,1.0]:
        _box(parent,"Sitzunterteil",Vector3(0.49,0.14,0.48),Vector3(side*0.40,1.21,cabin_center),leather)
        _box(parent,"Sitzlehne",Vector3(0.49,0.67,0.15),Vector3(side*0.40,1.54,cabin_center+0.18),leather,Vector3(-0.08,0,0))
    _cylinder(parent,"Lenkrad",0.22,0.055,Vector3(-0.44,1.76,cabin_center-0.55),dark,Vector3(PI/2,0,0),16)
    _box(parent,"Mittelkonsole",Vector3(0.18,0.15,0.7),Vector3(0,1.32,cabin_center-0.32),dark)

func _build_car() -> void:
    var sports := family in ["supercar","coupe","roadster","electric"]
    var suv := family in ["suv","offroad","pickup","van","minibus"]
    wheel_radius = 0.52 if suv else (0.43 if sports else 0.47)
    var front: float = -length*0.5
    var rear: float = length*0.5
    var body_top: float = 1.44 if sports else (1.68 if suv else 1.55)
    var paint := _mat(base_color,0.49,0.26)
    _loft(self,"Durchgehende Karosserieform",[
        [front,width*0.41,0.68,1.00,body_top*0.75],
        [front+0.22,width*0.50,0.63,1.30,body_top*0.90],
        [-length*0.22,width*0.5,0.65,body_top,body_top],
        [length*0.21,width*0.49,0.65,body_top,body_top],
        [rear-0.20,width*0.48,0.67,1.30,body_top*0.88],
        [rear,width*0.40,0.73,1.04,body_top*0.75]
    ],paint)
    var roof: float = 2.17 if suv else (1.80 if sports else 2.02)
    _trim(self,front,rear,width,roof,base_color)
    if suv:
        _box(self,"Dachreling links",Vector3(0.07,0.12,1.7),Vector3(-width*0.39,roof+0.11,0.20),_mat(Color("242c30"),0.5,0.3))
        _box(self,"Dachreling rechts",Vector3(0.07,0.12,1.7),Vector3(width*0.39,roof+0.11,0.20),_mat(Color("242c30"),0.5,0.3))
    if sports:
        _box(self,"Heckspoiler",Vector3(width*0.93,0.08,0.33),Vector3(0,1.64,rear-0.28),_mat(Color("1c2227"),0.32,0.26))
    if family == "pickup":
        _box(self,"Offene Ladeflaeche",Vector3(width*0.79,0.08,length*0.30),Vector3(0,1.48,length*0.32),_mat(Color("343b3e")))
    var zfront: float = front+length*0.24
    var zrear: float = rear-length*0.21
    for side in [-1.0,1.0]:
        _wheel(side*(width*0.49),zfront,wheel_radius,true)
        _wheel(side*(width*0.49),zrear,wheel_radius)
    if family in ["emergency","police"]:
        _beacons(roof+0.10,0.3)

func _build_utility() -> void:
    var is_tractor := family in ["tractor","harvester"]
    var is_rescue := family in ["ambulance","rescue","firetruck","police"]
    wheel_radius = 0.78 if is_tractor else 0.60
    var front := -length*0.5
    var rear := length*0.5
    var paint := _mat(base_color,0.35,0.38)
    _loft(self,"Fahrgestell & Haube",[[front,width*0.40,0.66,1.42,1.59],[front+0.22,width*0.48,0.66,1.55,1.72],[rear-0.2,width*0.48,0.68,1.56,1.75],[rear,width*0.43,0.68,1.42,1.58]],paint)
    var cabin := 2.5 if not is_tractor else 2.85
    _box(self,"Fahrerhaus",Vector3(width*0.86,cabin-1.34,length*0.37),Vector3(0,(cabin+1.34)*0.5,front+length*0.22),paint)
    _box(self,"Verbundglas Front",Vector3(width*0.72,0.62,0.06),Vector3(0,cabin-0.48,front+length*0.035),_mat(Color("2d5667"),0.16,0.21))
    for side in [-1.0,1.0]:
        _box(self,"Kabinenfenster",Vector3(0.05,0.62,length*0.19),Vector3(side*width*0.44,cabin-0.5,front+length*0.23),_mat(Color("2a5468"),0.16,0.19))
        _box(self,"Seitenspiegel",Vector3(0.20,0.22,0.27),Vector3(side*(width*0.5+0.15),cabin-0.48,front+length*0.06),_mat(Color("252d30")))
        _wheel(side*width*0.49,front+length*0.20,wheel_radius,true)
        _wheel(side*width*0.49,rear-length*0.20,wheel_radius*1.08 if is_tractor else wheel_radius)
        _light(self,"Arbeitsscheinwerfer",Vector3(side*width*0.33,1.53,front-0.11),Color("fff3d5"),false,true)
        _light(self,"Ruecklicht",Vector3(side*width*0.34,1.31,rear+0.1),Color("cc302c"))
    if family in ["truck","tipper","mixer","firetruck","ambulance","rescue","van","bus"]:
        var cargo_mat := _mat(base_color.darkened(0.10),0.23,0.48)
        _box(self,"Aufbau",Vector3(width*0.9,1.48,length*0.50),Vector3(0,2.10,rear-length*0.27),cargo_mat)
        if family == "tipper":
            for i in range(5):
                _box(self,"Muldenrippe %d"%i,Vector3(width*0.92,0.09,0.08),Vector3(0,2.4,0.2+i*0.42),_mat(Color("6d7476"),0.5,0.58))
        if family == "mixer":
            _cylinder(self,"Mischertrommel",0.85,length*0.43,Vector3(0,2.65,1.05),_mat(Color("c5c5bf"),0.38,0.31),Vector3(PI/2,0,0),20)
        if family == "firetruck":
            for i in range(3):
                _box(self,"Geraetefach %d"%i,Vector3(0.06,0.74,0.69),Vector3(width*0.47,2.03,0.1+i*0.72),_mat(Color("a7aa9f"),0.62,0.3))
    else:
        _box(self,"Motorhaube & Ladeplattform",Vector3(width*0.7,0.23,length*0.34),Vector3(0,1.74,rear-length*0.24),_mat(base_color.darkened(0.1),0.3,0.44))
    if is_rescue: _beacons(cabin+0.12,front+length*0.20)

func _tracks(parent: Node3D, half_width: float, track_length: float, rad: float) -> void:
    var metal := _mat(Color("343833"),0.42,0.87)
    var rubber := _mat(Color("252724"),0.0,0.94)
    for side in [-1.0,1.0]:
        _box(parent,"Kettenfahrwerk",Vector3(0.35,0.68,track_length),Vector3(side*half_width,0.69,0),rubber)
        for j in range(7):
            var z := -track_length*0.41+j*track_length*0.82/6.0
            _cylinder(parent,"Laufrolle",rad,0.43,Vector3(side*(half_width+0.035),rad+0.15,z),metal,Vector3(0,0,PI/2),14)
        # Instanced track pads; no unnecessary separate draw calls for each cleat.
        var pad := BoxMesh.new()
        pad.size = Vector3(0.39,0.13,0.14)
        var multi := MultiMesh.new()
        multi.transform_format = MultiMesh.TRANSFORM_3D
        multi.mesh = pad
        multi.instance_count = 36
        for i in range(36):
            var zpos: float = -track_length*0.5 + (float(i)+0.5)*track_length/36.0
            multi.set_instance_transform(i,Transform3D(Basis.IDENTITY,Vector3(side*half_width,0.28,zpos)))
        var instance := MultiMeshInstance3D.new()
        instance.name = "Kettenglieder instanziert"
        instance.multimesh = multi
        instance.material_override = metal
        parent.add_child(instance)

func _build_tank() -> void:
    length = maxf(5.8,length)
    width = maxf(2.5,width)
    var p := _mat(base_color,0.41,0.65)
    _tracks(self,width*0.47,length*0.78,0.39)
    var front := -length*0.48
    var rear := length*0.48
    _loft(self,"Gepanzerte Schraegpanzerung",[[front,width*0.32,0.72,1.12,1.41],[front+0.58,width*0.48,0.74,1.42,1.85],[rear-0.36,width*0.47,0.75,1.45,1.85],[rear,width*0.36,0.79,1.12,1.45]],p)
    var turret := Node3D.new()
    turret.name = "Drehbarer Turm"
    turret.position = Vector3(0,1.78,-length*0.04)
    add_child(turret)
    _loft(turret,"Turmpanzerung",[[-1.25,width*0.30,0.05,0.48,0.59],[-0.75,width*0.39,0.05,0.60,0.77],[0.75,width*0.38,0.06,0.62,0.77],[1.13,width*0.27,0.07,0.46,0.55]],p)
    _cylinder(turret,"Hauptrohr",0.15,length*0.52,Vector3(0,0.42,-length*0.43),_mat(Color("424b45"),0.76,0.34),Vector3(PI/2,0,0),20)
    _cylinder(turret,"Rohrmuendung",0.21,0.16,Vector3(0,0.42,-length*0.69),_mat(Color("303834"),0.8,0.28),Vector3(PI/2,0,0))
    _cylinder(turret,"Kommandantenluke",0.44,0.17,Vector3(width*0.17,0.81,0.36),_mat(Color("525d52"),0.53,0.48))
    for side in [-1.0,1.0]:
        _box(self,"Kettenschutz",Vector3(0.18,0.25,length*0.79),Vector3(side*width*0.50,1.06,0),p)
        _box(self,"Beobachtungsperiskop",Vector3(0.18,0.08,0.13),Vector3(side*0.42,1.84,-0.74),_mat(Color("203c46"),0.31,0.18))
        _light(self,"Fahrtlicht",Vector3(side*width*0.28,1.28,front-0.06),Color("e9dfb4"),false,true)

func _build_helicopter() -> void:
    length = maxf(length,6.3)
    width = maxf(width,1.9)
    var paint := _mat(base_color,0.38,0.36)
    var dark := _mat(Color("273138"),0.42,0.33)
    _loft(self,"Stromlinien-Rumpf",[[-length*0.26,width*0.24,1.34,2.08,2.53],[-length*0.17,width*0.40,1.10,2.71,3.15],[0,width*0.45,1.03,2.91,3.19],[length*0.24,width*0.25,1.29,2.22,2.68]],paint)
    _box(self,"Panorama-Cockpitscheibe",Vector3(width*0.68,0.78,0.055),Vector3(0,2.55,-length*0.19),_mat(Color("325869"),0.24,0.16),Vector3(-0.28,0,0))
    for side in [-1.0,1.0]:
        _box(self,"Kabinenfenster",Vector3(0.045,0.64,1.35),Vector3(side*width*0.44,2.40,0),_mat(Color("31566b"),0.14,0.17))
        _box(self,"Landekufe",Vector3(0.12,0.14,length*0.64),Vector3(side*width*0.44,0.36,0.04),dark)
        for z in [-0.9,0.9]:
            _box(self,"Kufentraeger",Vector3(0.11,0.78,0.12),Vector3(side*width*0.44,0.78,z),dark)
    _box(self,"Heckausleger",Vector3(0.26,0.33,length*0.68),Vector3(0,2.49,length*0.45),paint)
    _box(self,"Seitenleitwerk",Vector3(0.10,1.24,0.85),Vector3(0,2.89,length*0.76),paint)
    rotor_main = Node3D.new()
    rotor_main.name = "Hauptrotor animiert"
    rotor_main.position = Vector3(0,3.40,-0.05)
    add_child(rotor_main)
    _cylinder(rotor_main,"Rotornabe",0.28,0.24,Vector3.ZERO,dark)
    var span := clampf(length*0.88,5.0,10.0)
    for i in range(4):
        var angle := TAU * i / 4.0
        _box(rotor_main,"Rotorblatt %d"%i,Vector3(0.22,0.045,span*0.47),Vector3(sin(angle)*span*0.235,0.04,cos(angle)*span*0.235),dark,Vector3(0,angle,0))
    rotor_tail = Node3D.new()
    rotor_tail.name = "Heckrotor animiert"
    rotor_tail.position = Vector3(width*0.13,2.9,length*0.81)
    add_child(rotor_tail)
    for i in range(3):
        var angle := i*TAU/3.0
        _box(rotor_tail,"Heckrotorblatt",Vector3(0.05,0.14,0.65),Vector3(0,sin(angle)*0.28,cos(angle)*0.28),dark,Vector3(angle,0,0))
    if family in ["rescue","police","medical","transport"]: _beacons(3.19,0.0)

func _build_excavator() -> void:
    length = maxf(4.0,length)
    width = maxf(1.75,width)
    var size_factor := clampf(length / 5.3,0.65,2.3)
    var paint := _mat(base_color,0.3,0.43)
    var steel := _mat(Color("474e51"),0.67,0.47)
    _tracks(self,width*0.43,length*0.72,0.33*size_factor)
    _box(self,"Drehkranz",Vector3(width*0.80,0.25,length*0.62),Vector3(0,1.21,0),steel)
    _box(self,"Maschinenoberwagen",Vector3(width*0.88,0.55,length*0.63),Vector3(0,1.62,0.25),paint)
    _box(self,"Kabine",Vector3(width*0.42,1.35,length*0.32),Vector3(-width*0.21,2.56,0.11),paint)
    _box(self,"Kabine Frontglas",Vector3(width*0.35,0.89,0.055),Vector3(-width*0.21,2.65,-length*0.065),_mat(Color("376077"),0.26,0.16),Vector3(-0.09,0,0))
    for side in [-1.0,1.0]:
        _box(self,"Kabinenrahmen",Vector3(0.065,1.26,0.065),Vector3(-width*0.21+side*width*0.19,2.56,-length*0.06),steel)
    boom_pivot = Node3D.new()
    boom_pivot.name = "Schwenkbarer Ausleger"
    boom_pivot.position = Vector3(width*0.32,1.86,-length*0.20)
    add_child(boom_pivot)
    _box(boom_pivot,"Hydraulischer Hauptarm",Vector3(0.28*size_factor,0.41*size_factor,2.45*size_factor),Vector3(0,1.08*size_factor,-0.7*size_factor),paint,Vector3(-0.56,0,0))
    _cylinder(boom_pivot,"Hydraulikzylinder",0.085*size_factor,1.4*size_factor,Vector3(0,0.75*size_factor,-0.8*size_factor),steel,Vector3(-0.5,0,0),12)
    bucket_pivot = Node3D.new()
    bucket_pivot.name = "Bewegliche Schaufel"
    bucket_pivot.position = Vector3(0,2.0*size_factor,-2.12*size_factor)
    boom_pivot.add_child(bucket_pivot)
    _box(bucket_pivot,"Loeffelruecken",Vector3(0.9*size_factor,0.25*size_factor,0.65*size_factor),Vector3(0,0,0),steel,Vector3(-0.55,0,0))
    _box(bucket_pivot,"Loeffelboden",Vector3(1.0*size_factor,0.10*size_factor,0.48*size_factor),Vector3(0,-0.25*size_factor,-0.22*size_factor),steel)
    for i in range(4):
        _box(bucket_pivot,"Schaufelzahn %d"%i,Vector3(0.07*size_factor,0.15*size_factor,0.20*size_factor),Vector3((float(i)-1.5)*0.27*size_factor,-0.30*size_factor,-0.51*size_factor),steel)
    _light(self,"Arbeitslicht",Vector3(-width*0.28,3.18,-length*0.07),Color("fff3d5"),false,true)

func _beacons(height: float,z: float) -> void:
    for i in range(2):
        var blue := i == 0
        var pos := Vector3((-0.43 if blue else 0.43),height,z)
        _box(self,"Blaulicht" if blue else "Rotlicht",Vector3(0.35,0.13,0.19),pos,_mat(Color("2676ef") if blue else Color("e33430"),0.1,0.22,true))
        var light := OmniLight3D.new()
        light.name = "Rotierender Lichtkegel"
        light.position = pos
        light.omni_range = 9.0
        light.light_energy = 0.0
        light.shadow_enabled = false
        light.light_color = Color("327cff") if blue else Color("ed3731")
        add_child(light)
        emergency_lights.append(light)

func animate_vehicle(delta: float, speed: float, steering: float, controlled: bool, fuel: float) -> void:
    running_time += delta
    if hero_details != null:
        hero_details.call("animate_hero", delta, speed, steering, controlled)
    for spin in wheel_spinners:
        spin.rotate_x(-speed*delta/maxf(wheel_radius,0.2))
    for axle in front_steer:
        axle.rotation.y = lerpf(axle.rotation.y,-steering*0.38,clampf(delta*7.5,0,1))
    if rotor_main != null:
        rotor_main.rotate_y(delta*(20.0 if controlled and fuel>0 else 3.8))
    if rotor_tail != null:
        rotor_tail.rotate_x(delta*(30.0 if controlled and fuel>0 else 5.0))
    if boom_pivot != null and controlled:
        var arm_delta := Input.get_axis("build_next","build_rotate")
        boom_pivot.rotation.x = clampf(boom_pivot.rotation.x+arm_delta*delta*0.45,-0.42,0.72)
    if bucket_pivot != null and controlled:
        bucket_pivot.rotation.x = -0.3 + 0.2*sin(running_time*1.4)
    for i in range(emergency_lights.size()):
        emergency_lights[i].light_energy = 1.8 if int(running_time*5.0+i)%2==0 else 0.0
    for lamp in lamps:
        lamp.light_energy = 0.9 if controlled and fuel>0 else 0.0
