# NEXUS Unreal Engine 5.8 – kostenlose Adlerklamm-Grafikpakete

**0 € Zusatzkosten.** Keine Cloud-VM wurde bestellt, kein Abo gestartet. Alle hier genannten Original-Assets wurden offline aus den bereits vorhandenen NEXUS-Quellmaterialien oder geometrischen Skripten erzeugt.

## Downloads aus dem begleitenden Chat

- `NEXUS_UE5_18_PBR_MATERIALIEN_72_DATEIEN.zip`: 18 ursprüngliche KI-Texturfamilien, 72 Bilder. Normal, Roughness, Ambient Occlusion sind **heuristisch** erzeugt, keine Materialscans.
- `NEXUS_UE5_ADLERKLAMM_LANDSCAPE_2017.zip`: 2017×2017 Heightmap (16-bit), Terrain-Zonenmasken und Metadaten.
- `NEXUS_UE5_ADLERKLAMM_9_3D_TERRAIN_TILES.zip`: neun GLB-Meshes für die 2×2-km-Adlerklamm-Karte, in einem 3×3-Raster. Gesamt 257.049 Vertices / 508.032 Dreiecke. Dies sind **Terrain-Vorschaumeshe** und kein UE-Landscape-Collision-Ersatz.
- `NEXUS_UE5_4_FREE_3D_HERO_MODELS.zip`: 12-m-Bus, ein 6,83-m-Brückensegment, Rettungswagen, Rettungshelikopter als selbst erzeugte GLB-Prototypen. Kein Scan, kein AAA-Asset.

## Dateien ablegen

Die entpackten ZIP-Inhalte wie folgt sortieren:

```text
Unreal/NEXUS_UE5/
  Content/
    SourceArt/
      PBR/
        AlpineRock_albedo.png
        AlpineRock_normal.png
        ... [72 Texturen]
      Geometry/
        Hero/
          SM_NEXUS_RescueBus_12m.glb
          SM_NEXUS_BridgeSpan_6p83m.glb
          SM_NEXUS_FireRescue_Truck.glb
          SM_NEXUS_RescueHelicopter.glb
        TerrainTiles/
          Adlerklamm_Tile_1_1.glb
          ...
          Adlerklamm_Tile_3_3.glb
      Heightmap/
        Adlerklamm_Landscape_2017x2017_16bit.png
        Adlerklamm_Layer_*.png
  Scripts/
    import_nexus_pbr.py
    import_nexus_geometry.py
```

## Sobald Unreal Editor 5.8 verfügbar ist

1. `NEXUS.uproject` öffnen und C++-Module tatsächlich mit UnrealBuildTool kompilieren.
2. In Unreal **Tools → Execute Python Script** die Datei `Scripts/import_nexus_pbr.py` ausführen.
3. Danach `Scripts/import_nexus_geometry.py` ausführen. Das Skript importiert 4 Hero- und 9 Terrain-GLBs; für die Hero-Meshes wird nach Möglichkeit einfache Box-Kollision erzeugt.
4. Die C++-Spielklassen suchen automatisch nach den importierten Assets unter `/Game/AAA/Geometry/Hero/`. Beim Import die resultierenden Unreal-Pfade kontrollieren; Interchange kann Namensvarianten vergeben.
5. **Für echte Spiele-Kollisionen** das 2017×2017-16-Bit-PNG im Landscape-Tool als UE Landscape importieren. Die neun Terrain-GLBs sind nur für Vorschau oder eine separate Test-Map und dürfen nicht gleichzeitig deckungsgleich mit dem Landscape gerendert werden.
6. Fels-, Beton- und Asphalt-Shader anwenden, Nanite für passende statische Meshes einsetzen, Kollision der dynamisch simulierten Meshes auf einfache konvexe Volumes prüfen.
7. Die Brücke ist zunächst in zwölf Chaos-Physiksegmente aufgeteilt. Für zerbrechende Betonstücke mit realen Bruchkanten später eine **Geometry Collection** mit Chaos Fracture authoren.

## Status und Einschränkungen

- Die ZIPs wurden erzeugt und können unabhängig vom Gaming-PC heruntergeladen werden.
- Die C++-Projektdateien und Importskripte wurden auf GitHub eingetragen; GitHub Actions prüft Struktur und Python-Syntax.
- **Es gibt noch keinen erfolgreichen Unreal-Engine-5.8-Compile**, keine hochqualitative GPU-Szene und keine als 1:1 fotorealistisch bestätigten Frames. Godot-Aufnahmen ersetzen das nicht.
- Für künftige Cloud-GPU-Renderings ohne eigenen starken PC wird ein kostenfreier Zugang nur genutzt, wenn er nachweislich verfügbar und mit dem 0-€-Budget vereinbar ist. Es wird kein kostenpflichtiger Dienst gestartet.
