# V2.3 Grafik-Upgrade – Stand und Abnahme

## Im Code fertiggestellt
- Drei Hero-Fahrzeuge können beim Laden echte `glTF 2.0` / `.glb`-Modelle verwenden; prozedurale Ersatzmodelle bleiben ohne Assets automatisch aktiv. Vorhandene Fahrfunktionen und Kollisionskörper bleiben erhalten.
- Benannte Pivot-Teile (`Wheel_*`, `Rotor_Main`, `Rotor_Tail`, `Boom`, `Bucket`) werden beim Import gebunden und über vorhandene Fahrlogik animiert.
- PBR-Asset-Lookup für Asphalt, Stein, Dach, Verputz, Holz und Gras mit weiterhin funktionsfähigem Material-Fallback.
- Ein neuer Shader passt Nassglanz und Mikro-Rauheit der Straßen an Niederschlag und Trocknungszeit an; Wetter kommt aus dem realen Welt-Zeit-System.
- Aus einfachen Flachdach-Quadern im Alpendorf wurden doppelgeneigte Hausdächer mit Regenrinne, Steinfundament, Fensterkreuzen, Balkon und Schornstein.

## Noch nicht vorhanden
- Hochwertige externe GLB-Assets / Fotogrammetrie-Meshes; Lizenzprüfung der vom Nutzer zu liefernden Dateien.
- Vollständiges Fels-/Gebirge-Photogrammetrie-Set, realistisches Stadtmodell, vollständige Figurenanimationen, filmreife VFX, vier-Spieler-Server-Koop, 48-Stunden-Story.
- Optische GPU-Abnahme auf PC/iPhone, Benchmark und 4K-Original-Gameplay-Trailer.

## Test- und Freigabegates
1. Statische V2.3-Validierung und Godot Headless Import.
2. V2.3-Smoketest: keine GLBs -> funktioniert, nasses Straßenmaterial -> Parameteränderung, 9 Häuser mit geneigten Dächern -> vorhanden.
3. Nach Asset-Einbau: tatsächliche Godot-Aufnahme Tag/Regen/Nacht für jeweils nah und weit, Performance pro Gerät messen.
