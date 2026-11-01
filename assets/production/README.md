# PROJECT NEXUS – Produktionsassets (V2.3)

Füge nur **eigene oder rechtmäßig lizenzierte** 3D-Modelle und Texturen ein. Die sechs gesendeten Bilder sind Referenzen, keine aus diesen Bildern extrahierbaren Spielmeshes.

## Drei sofort austauschbare Hero-Fahrzeuge

- `vehicles/vortex_sport.glb` – Sportwagen, ID `CAR_041`
- `vehicles/alpin_h1.glb` – Rettungshubschrauber, ID `HELI_01`
- `vehicles/excavator_14t.glb` – 14-t-Bagger, ID `EXC_02`

Godot importiert `.glb` automatisch. **Fehlt eine Datei**, bleibt das bisherige prozedurale Modell erhalten. Das Fahrzeug bleibt fahrbar, weil die Gameplay-Kollision und die Fahrphysik getrennt vom optischen Mesh sind.

GLB-Modellregeln: glTF 2.0, Meter als Maßeinheit, `-Z` ist vorne, `+Y` ist oben, Ursprung am Boden mittig, eingebettete oder beigelegte PBR-Materialien. Empfohlene Fahrzeugteile als `Node3D`-Pivots: `Wheel_FL`, `Wheel_FR`, `Wheel_RL`, `Wheel_RR`, `Steer_FL`, `Steer_FR`, `Rotor_Main`, `Rotor_Tail`, `Boom`, `Bucket`. Diese Namen aktivieren die bereits vorhandenen Bewegungen. Falls die Ausrichtung abweicht, muss das GLB entsprechend exportiert oder in `scripts/nexus_production_assets.gd` angepasst werden.

## Austauschbare PBR-Materialien

Unter `materials/` werden je nach Material folgende PNG-Dateien geladen:
- `asphalt_albedo.png`, `asphalt_normal.png`, `asphalt_roughness.png`
- `rock_albedo.png`, `rock_normal.png`, `rock_roughness.png`
- `roof_albedo.png`, `roof_normal.png`, `roof_roughness.png`
- `plaster_albedo.png`, `plaster_normal.png`, `plaster_roughness.png`
- `wood_albedo.png`, `wood_normal.png`, `wood_roughness.png`
- entsprechend `grass` und `concrete`.

Die Dateien sind **optional**: die vorhandenen NEXUS-Texturen bleiben als Fallback vorhanden. Der neue Asphalt-Shader simuliert nach Regen nasse Oberfläche und unterschiedliche Mikro-Rauheit. Sauberer Normalmap-Import: Godot sollte Normalmap-Farbprofile/Import als Normalmap behandeln.

## Qualität & Rechte

Für Fotorealismus brauchen wir echte, hochdetaillierte UV-Meshes, Materialsätze, Figuren/Animationen und eine Abnahme anhand echter Godot-Screenshots. Speichere zu jedem fremden Asset `LICENSE.txt` oder `SOURCE.txt` mit Quelle, Lizenz und Urheber. Markenlogos nur mit entsprechenden Rechten verwenden. 4K-Materialquellen sind okay; exportiere für Web/iPhone idealerweise 1–2K und nutze LODs. Die V2.3 ist deshalb ein **Asset-Ready-Prototyp**, kein AAA-Fertigspiel.
