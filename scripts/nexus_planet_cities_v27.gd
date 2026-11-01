extends Node3D
class_name NexusPlanetCitiesV27
## Six distinct original planetary architecture sets. Terrain and story own collisions.
## A limited visual prototype, not full open-world planets or AI-populated cities.
const CITY_STYLES: Dictionary = {
    "alpine": {"name":"Terranischer Vorposten", "color":"b9a18d", "roof":"72604f", "base":5.0, "count":7},
    "desert": {"name":"Solara Duenenstadt", "color":"d7af7d", "roof":"8c674d", "base":12.0, "count":12},
    "ice": {"name":"Cryos Eisforschungsbasis", "color":"accbd4", "roof":"527e9b", "base":9.0, "count":9},
    "jungle": {"name":"Verdant Baumkolonie", "color":"5c8b67", "roof":"b7ac78", "base":11.0, "count":10},
    "volcanic": {"name":"Ignis Lavalabore", "color":"66636b", "roof":"b95c3b", "base":15.0, "count":9},
    "alien": {"name":"Umbra Fremdarchitektur", "color":"7165a1", "roof":"53b9b0", "base":21.0, "count":11}
}

var biome: String = "alpine"
var structure_count: int = 0
var anchors: Array[Vector3] = []

func configure(biome_id: String, seed_value: int, elevations: Callable) -> void:
    biome = biome_id if CITY_STYLES.has(biome_id) else "alpine"
    name = "NEXUS V2.7 planetary quarters | " + str(CITY_STYLES[biome]["name"])
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value + 2701
    var style: Dictionary = CITY_STYLES[biome]
    var wall := _material(Color(str(style["color"])),false)
    var crown := _material(Color(str(style["roof"])),biome in ["volcanic","alien"])
    var pale := _material(Color(str(style["color"])).lightened(0.17),false)
    # Stay away from fixed scan/core/exit objective hubs and landing point.
    for i in range(int(style["count"])):
        var x := -105.0+float(i%5)*22.0+rng.randf_range(-3.0,3.0)
        var z := 76.0+float(i/5)*21.0+rng.randf_range(-4.0,4.0)
        var ground := float(elevations.call(x,z))
        var y := ground
        var height: float = float(style["base"])+rng.randf_range(-1.0,7.0)
        var position := Vector3(x,y,z)
        anchors.append(position)
        _block("Planetary structure",position+Vector3(0,height*0.5,0),Vector3(10.0,height,9.0),wall)
        match biome:
            "alpine":
                _block("Timber roof",position+Vector3(0,height+1.0,0),Vector3(11,2,10),crown)
                _block("Balcony",position+Vector3(0,height*0.62,5),Vector3(8,0.3,2),pale)
            "desert":
                _block("Desert canopy",position+Vector3(0,height+0.7,0),Vector3(12,1.4,11),crown)
                _block("Windbreak",position+Vector3(-6,3,0),Vector3(1,6,11),pale)
            "ice":
                _block("Insulated roof",position+Vector3(0,height+0.6,0),Vector3(12,1.2,11),crown)
                _block("Antenna",position+Vector3(3,height+3,2),Vector3(0.4,6,0.4),pale)
            "jungle":
                _block("Elevated habitat walkway",position+Vector3(0,height*0.7,5),Vector3(13,0.5,4),crown)
                _block("Green canopy",position+Vector3(0,height+1,0),Vector3(13,2,12),pale)
            "volcanic":
                _block("Thermal radiation shield",position+Vector3(0,height+1,0),Vector3(12,2,11),crown)
                _block("Heat chimney",position+Vector3(3,height+4,-3),Vector3(1.8,7,1.8),pale)
            "alien":
                _block("Umbra crystal apex",position+Vector3(0,height+5,0),Vector3(4,10,4),crown)
                _block("Luminous collar",position+Vector3(0,height+0.5,0),Vector3(11,1,10),pale)
        structure_count += 1

func _material(c: Color, luminous: bool) -> StandardMaterial3D:
    var mat := StandardMaterial3D.new()
    mat.albedo_color = c
    mat.metallic = 0.25 if biome in ["ice","alien"] else 0.0
    mat.roughness = 0.45 if biome in ["ice","alien"] else 0.88
    if luminous:
        mat.emission_enabled = true
        mat.emission = c
        mat.emission_energy_multiplier = 0.48
    return mat

func _block(tag: String, at: Vector3, size: Vector3, material: Material) -> void:
    var mesh := BoxMesh.new()
    mesh.size = size
    var visual := MeshInstance3D.new()
    visual.name = tag
    visual.mesh = mesh
    visual.position = at
    visual.material_override = material
    add_child(visual)
