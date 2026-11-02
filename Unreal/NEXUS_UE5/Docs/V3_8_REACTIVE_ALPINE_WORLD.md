# NEXUS V3.8 – ALPINE REACTIVE WORLD (Unreal 5.8, no cloud spend)

## Added in this release
- Network-visible survivors: two replicated fields, `bRescued` and
  `bAvailable`; clients apply the resulting collision and visibility
  using `OnRep_RescueState`.
- Industry sites: `bConstructed` and `Facility` replicate; the factory
  construction is reflected to late joiners instead of only the host.
- `ANexusAlpineWeather` controls time of day, sunlight, fog, weather
  severity, and optional Niagara precipitation. In the story the rescue
  starts with rain, the bridge collapse triggers a storm, and rebuilding
  calms the weather. Slippery road behavior affects speed and steering.
- `ANexusAlpineRiver` constructs curved 3D meshes for river water and
  both banks, with flow direction and replicated flood water level.
- `Scripts/create_river_material.py` creates a baseline Unreal water
  material in the Editor. No third-party textures or paid services.
- Inventory HUD now uses the replicated resource snapshot for all items.

## Playable and quality caveats
The water fallback is a physically-inspired tinted material. It is not yet
a photorealistic river with scanned beds, 3D whitewater, correct refraction,
transparency/wet shore foam or Niagara waterfalls. The weather system
has real sun/fog response, but precipitation particles require the Niagara
asset `/Game/AAA/VFX/NS_NexusAlpinePrecipitation`, which has NOT been
created. The source can compile only after the free
`ProceduralMeshComponent` engine plugin is enabled.

Unreal Editor was not available in this execution environment.
Existing source unit/contract checks do not replace an editor build.
No paid cloud hardware was activated. Godot main remains untouched.

## Import
1. Open `NEXUS.uproject` in Unreal 5.8 with its source project.
2. Import the original 3D GLB and scanned CC0 rock assets as documented.
3. Run `Scripts/create_river_material.py` from Tools > Execute Python Script.
4. Build C++ module; run a multiplayer 2-client PIE test for rescue and
   factory visibility, with a late join and Save/Load.
5. Verify actual river face orientation and normals in the game viewport,
   then add properly authored wave, foam and flow-map materials.
6. Test storm performance, fog density, day/night light and car traction.
7. Record 10 seconds of genuine Unreal gameplay (not a generated video).
