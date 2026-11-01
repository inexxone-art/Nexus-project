# PROJECT NEXUS — recherchierte Produktionsassets (Stand 2026-11-01)

Diese Liste enthält öffentlich geprüfte Asset-Seiten. **Nicht als bereits importiert ausgeben.** Rechte und reale Godot-Darstellung sind vor Release nochmals zu prüfen.

## Empfohlen: Sportwagen / CAR_041

- Spectral GT RS, Originalmodell von JaronKBragg7337
- Quelle: https://github.com/JaronKBragg7337/spectral-gt-rs
- Direktes GLB: https://raw.githubusercontent.com/JaronKBragg7337/spectral-gt-rs/main/spectral_gt_rs_game_ready.glb
- Lizenz: CC0 1.0, siehe https://github.com/JaronKBragg7337/spectral-gt-rs/blob/main/LICENSE
- ca. 4.7 MB; getrennte Karosserie-/Cockpitteile und Animationen
- Auf Modellursprung und Orientierung achten: Quelle nennt Fahrzeugfront +X; NEXUS-Konvention verlangt -Z. Vor Integration um die Y-Achse korrekt ausrichten und Räder/Steuerung an vorhandene NEXUS-Pivots binden.
- Zielpfad: assets/production/vehicles/vortex_sport.glb

## Empfohlen: Rettungshubschrauber / HELI_01

- Air Ambulance Twin Helicopter von 3DAssets.dev, CC0 laut Asset-Seite.
- Quelle: https://3dassets.dev/assets/aircraft-fleet-and-airfield-medium-twin-air-ambulance-52d4f7fc
- Direktes GLB: https://cdn.3dassets.dev/assets/32807/v1/model.glb
- ca. 1.3 MB; 35.218 Dreiecke; benannte Rotor- und Türanimationen.
- Quelle nennt Fahrzeugfront +Z; NEXUS verlangt -Z: Modellausrichtung und AnimationPivots prüfen.
- Zielpfad: assets/production/vehicles/alpin_h1.glb
- Hinweis: Materialpalette statt fotorealistischer 4K-PBR-Fototexturen. Für AAA-Fotorealismus nur Zwischenstufe.

## Detaillierter Bagger / EXC_02

- Excavator, Anton Krupnov: https://sketchfab.com/3d-models/excavator-3c4d505819294b4982a67218fa8baaa2
- 134.200 Dreiecke, 2K-Texturen, CC BY laut Sketchfab; Attribution erforderlich.
- Sketchfab erfordert beim regulären Download i.d.R. Anmeldung. **Nicht ohne Login/Erlaubnis scrapen**.
- Alternative CC0 ohne Konto (kompakter Bagger, nicht gleiche Größe): https://www.innerscene.com/tools/library/3d-parts/compact-tracked-excavator-76c41cd5
- Zweite CC0-Alternative zum automatischen Prototyp-Import: https://cdn.3dassets.dev/assets/35687/v1/model.glb (Hydraulikhammer statt Löffel; nur ~2400 Dreiecke), Quelle https://3dassets.dev/assets/demolition-and-site-clearance-demolition-and-site-clea-33f05b81
- Gewünschter Zielpfad: assets/production/vehicles/excavator_14t.glb
- Keines dieser Modelle wurde als exakt passender 14-t-Bagger im Projekt getestet.

## CC0-PBR-Texturen für die Alpenregion

- Ziegel: https://polyhaven.com/a/roof_tiles
- Fels: https://polyhaven.com/a/rock_face
- Waldboden: https://polyhaven.com/a/forest_ground_04
- Schnee mit Fahrspuren: https://polyhaven.com/a/snow_05
- Asphalt mit Schnee: https://polyhaven.com/a/asphalt_snow
- Poly Haven Lizenz: https://polyhaven.com/license

Pro Material sinnvoll: 2K Diffuse/Albedo + OpenGL Normal + Roughness; auf Mobilgeräten Texturspeicher und LOD-Budget prüfen.

## Technische Abnahme

1. Nur GLB-Downloads aus vertrauenswürdiger Quelle, Quelle/Lizenz für jedes Asset dokumentieren.
2. In Godot importieren; Mesh-Fehler und PBR/Normalmap-Import prüfen.
3. Fahrzeugmodell skalieren, Ausrichtung korrigieren, Räder/Rotor/Schaufel als getrennte Pivots anbinden.
4. Das Mesh ist nur sichtbare Geometrie, Physik und Kollisionen bleiben vom Spiel kontrolliert.
5. Screenshots/Gameplay aus Godot erstellen und mit Referenzbildern vergleichen.
6. Render-Performance auf Web, iPhone und PC messen; High/Low LOD bereitstellen.

Ergebnis der Recherche: eine rechtlich dokumentierte Auswahlliste, **noch keine fertige Integration in die NEXUS-Spielwelt**.
