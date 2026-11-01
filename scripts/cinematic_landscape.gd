extends Node3D
class_name NexusCinematicLandscape
## V1.1: authored procedural scenic landscape. Non-colliding scenery outside the core play area.
## Intentionally no downloaded assets or fabricated photorealistic claims.

const SEED: int = 20261101
var rng := RandomNumberGenerator.new()
var mountain_root: Node3D
var wind_time: float = 0.0
var water_material: StandardMaterial3D
var water_plane: MeshInstance3D

func _ready() -> void:
    name = "NEXUS | Cinematic Alpine Landscape"
    rng.seed = SEED
    mountain_root = Node3D.new()
    mountain_root.name = "Gebirge (gemeinsames Hintergrund-Mesh)"
    add_child(mountain_root)
    _mountain_masses()
    _scenic_forest()
    _rock_clusters()
    _wetlands_and_river()
    _trail_details()

func _material(color: Color, roughness: float = 0.9, metallic: float = 0.0) -> StandardMaterial3D:
    var m := StandardMaterial3D.new()
    m.albedo_color = color
    m.roughness = roughness
    m.metallic = metallic
    return m

func _mountain_masses() -> void:
    # Faceted but smooth-lit mountain walls, snow line and ridgelines.
    # All ridges start outside the mission areas; the playfield stays flat and navigable.
    var mat := StandardMaterial3D.new()
    mat.vertex_color_use_as_albedo = true
    mat.roughness = 0.98
    mat.cull_mode = BaseMaterial3D.CULL_DISABLED
    var radial: Array[float] = [221.0, 242.0, 264.0, 289.0, 324.0, 365.0, 417.0]
    var segments: int = 192
    var heights: Array = []
    for ring in range(radial.size()):
        var values := PackedFloat32Array()
        for i in range(segments + 1):
            var a: float = float(i) / float(segments) * TAU
            var broad: float = sin(a * 5.0 + 0.3) * 16.0 + sin(a * 11.0 - 1.7) * 10.0
            var jagged: float = absf(sin(a * 29.0 + float(ring) * 0.19)) * 14.0
            var base: float = [0.0, 11.0, 37.0, 77.0, 112.0, 140.0, 125.0][ring]
            var elevation: float = maxf(0.0, base + broad * float(ring) * 0.35 + jagged * float(ring) * 0.3)
            values.append(elevation)
        heights.append(values)
    var st := SurfaceTool.new()
    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    for ring in range(radial.size() - 1):
        for j in range(segments):
            var v00 := _mountain_point(radial[ring], heights[ring][j], j, segments)
            var v01 := _mountain_point(radial[ring], heights[ring][j + 1], j + 1, segments)
            var v10 := _mountain_point(radial[ring + 1], heights[ring + 1][j], j, segments)
            var v11 := _mountain_point(radial[ring + 1], heights[ring + 1][j + 1], j + 1, segments)
            _mountain_triangle(st, v00, v10, v01, ring, j)
            _mountain_triangle(st, v01, v10, v11, ring, j)
    st.generate_normals()
    var mi := MeshInstance3D.new()
    mi.name = "Verbundener Gebirgskamm | Graufels + Schnee"
    mi.mesh = st.commit()
    mi.material_override = mat
    mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    mountain_root.add_child(mi)

func _mountain_point(radius: float, y: float, index: int, count: int) -> Vector3:
    var a: float = float(index) / float(count) * TAU
    var shaped_radius: float = radius + sin(a * 23.0) * 3.8
    return Vector3(cos(a) * shaped_radius, y - 0.4, sin(a) * shaped_radius)

func _mountain_triangle(st: SurfaceTool, a: Vector3, b: Vector3, c: Vector3, ring: int, segment: int) -> void:
    for v in [a, b, c]:
        var variance: float = 0.92 + 0.08 * sin(float(segment) * 3.17 + float(ring))
        var rock := Color(0.41 * variance, 0.43 * variance, 0.42 * variance)
        var alpine := Color(0.30 * variance, 0.40 * variance, 0.32 * variance)
        var snow := Color(0.89 * variance, 0.91 * variance, 0.94 * variance)
        var snow_amount: float = smoothstep(91.0, 120.0, v.y + 9.0 * sin(v.x * 0.055 + v.z * 0.032))
        var color := alpine.lerp(rock, smoothstep(6.0, 53.0, v.y)).lerp(snow, snow_amount)
        st.set_color(color)
        st.add_vertex(v)

func _scenic_forest() -> void:
    # MultiMesh foliage keeps the high forest count inexpensive. Decorative only.
    var bark := _material(Color("70523f"))
    var needles := _material(Color("345347"))
    needles.vertex_color_use_as_albedo = true
    var trunk_mesh := CylinderMesh.new()
    trunk_mesh.top_radius = 0.11
    trunk_mesh.bottom_radius = 0.19
    trunk_mesh.height = 1.0
    trunk_mesh.radial_segments = 6
    var leaf_mesh := CylinderMesh.new()
    leaf_mesh.top_radius = 0.0
    leaf_mesh.bottom_radius = 0.74
    leaf_mesh.height = 1.0
    leaf_mesh.radial_segments = 7
    var coords: Array[Transform3D] = []
    var colors: Array[Color] = []
    for i in range(920):
        var a := rng.randf_range(0.0, TAU)
        var r := rng.randf_range(120.0, 170.0)
        var x := cos(a) * r
        var z := sin(a) * r
        # Leave the castle, front, rescue region and quarantine compound open.
        if (x < -110.0 and z < -100.0) or (x > 65.0 and z > 72.0):
            continue
        if x > 70.0 and z < 10.0 and z > -95.0:
            continue
        var h := rng.randf_range(7.0, 17.0)
        var radius := rng.randf_range(0.70, 1.30)
        coords.append(Transform3D(Basis.IDENTITY, Vector3(x, 0.0, z)).scaled_local(Vector3(radius, h, radius)))
        colors.append(Color.from_hsv(rng.randf_range(0.28, 0.40), rng.randf_range(0.23, 0.44), rng.randf_range(0.53, 0.85)))
    var trunks := MultiMesh.new()
    trunks.transform_format = MultiMesh.TRANSFORM_3D
    trunks.mesh = trunk_mesh
    trunks.instance_count = coords.size()
    var crowns := MultiMesh.new()
    crowns.transform_format = MultiMesh.TRANSFORM_3D
    crowns.use_colors = true
    crowns.mesh = leaf_mesh
    crowns.instance_count = coords.size()
    for i in range(coords.size()):
        var t: Transform3D = coords[i]
        var h: float = t.basis.y.length()
        var p: Vector3 = t.origin
        trunks.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3(0.32, h * 0.7, 0.32)), p + Vector3(0, h * 0.35, 0)))
        crowns.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3(h * 0.28, h * 0.68, h * 0.28)), p + Vector3(0, h * 0.66, 0)))
        crowns.set_instance_color(i, colors[i])
    var wood := MultiMeshInstance3D.new()
    wood.name = "Dekorative Forststaemme"
    wood.multimesh = trunks
    wood.material_override = bark
    wood.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(wood)
    var trees := MultiMeshInstance3D.new()
    trees.name = "Dekorativer Nadelwald (instanziert)"
    trees.multimesh = crowns
    trees.material_override = needles
    trees.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(trees)

func _rock_clusters() -> void:
    var stone := _material(Color("737d75"))
    var stone2 := _material(Color("9d9f93"))
    for i in range(95):
        var angle := rng.randf_range(0.0, TAU)
        var r := rng.randf_range(119.0, 152.0)
        var p := Vector3(cos(angle) * r, 0.0, sin(angle) * r)
        if (p.x > 76.0 and p.z < 25.0) or (p.x < -80.0 and p.z < -65.0):
            continue
        var mesh := SphereMesh.new()
        mesh.radial_segments = 8
        mesh.rings = 4
        var size := rng.randf_range(1.4, 6.5)
        var node := MeshInstance3D.new()
        node.name = "Geroell / Fels"
        node.mesh = mesh
        node.material_override = stone if i % 3 else stone2
        node.position = p + Vector3(0, size * 0.23, 0)
        node.scale = Vector3(size * 1.2, size * 0.44, size * 0.85)
        node.rotation.y = rng.randf_range(0.0, TAU)
        add_child(node)

func _wetlands_and_river() -> void:
    # Visual lake at the western valley edge: does not modify ground collision.
    water_material = _material(Color(0.12, 0.34, 0.38, 0.80), 0.13, 0.15)
    water_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    water_material.cull_mode = BaseMaterial3D.CULL_DISABLED
    var mesh := PlaneMesh.new()
    mesh.size = Vector2(44.0, 96.0)
    water_plane = MeshInstance3D.new()
    water_plane.name = "Alpensee | reflektierendes Wasser (visuell)"
    water_plane.mesh = mesh
    water_plane.material_override = water_material
    water_plane.position = Vector3(-178.0, 0.055, 33.0)
    water_plane.rotation.y = -0.3
    add_child(water_plane)
    var gravel := _material(Color("afa995"))
    for i in range(60):
        var a := rng.randf_range(0.0, TAU)
        var r := rng.randf_range(22.0, 31.0)
        var shore := MeshInstance3D.new()
        var rock := SphereMesh.new()
        rock.radial_segments = 6
        rock.rings = 3
        shore.mesh = rock
        shore.material_override = gravel
        shore.position = Vector3(-178.0 + cos(a) * r, 0.1, 33.0 + sin(a) * r * 1.8)
        shore.scale = Vector3(rng.randf_range(0.4, 1.7), 0.30, rng.randf_range(0.7, 2.1))
        add_child(shore)

func _trail_details() -> void:
    var meadow := _material(Color("5b7950"))
    # Small grass tufts near the first-person spawn and along the western trail.
    var mesh := CylinderMesh.new()
    mesh.top_radius = 0.02
    mesh.bottom_radius = 0.15
    mesh.height = 0.45
    mesh.radial_segments = 3
    var mm := MultiMesh.new()
    mm.mesh = mesh
    mm.transform_format = MultiMesh.TRANSFORM_3D
    mm.instance_count = 1000
    for i in range(mm.instance_count):
        var x := rng.randf_range(-90.0, 73.0)
        var z := rng.randf_range(-73.0, 85.0)
        if absf(z) < 5.5 or absf(x - 55.0) < 7.0:
            x += 10.0
        var sc := rng.randf_range(0.7, 1.6)
        mm.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3(sc, sc, sc)), Vector3(x, 0.21, z)))
    var clumps := MultiMeshInstance3D.new()
    clumps.name = "Grasbueschel (instanziert)"
    clumps.multimesh = mm
    clumps.material_override = meadow
    clumps.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
    add_child(clumps)

func _process(delta: float) -> void:
    wind_time += delta
    if is_instance_valid(water_plane):
        water_plane.position.y = 0.055 + sin(wind_time * 0.65) * 0.009
