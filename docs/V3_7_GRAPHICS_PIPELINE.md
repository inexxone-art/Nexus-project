# NEXUS V3.7 – Adlerklamm Graphics Pipeline

## Art direction (verbindliche Zielvorlage)
Die vom Auftraggeber gelieferte Abbildung legt für Adlerklamm die Bildsprache fest: feuchter alpiner Fels, dicht bewaldete Steilhänge, schlammiger weißschäumender Canyonfluss, Betonstahl und Bruchschutt, rote und blaue Rettungslichter, helikoptergestützte Bergung sowie die ferne Industriestadt. Das V3.6-Referenz-HUD bleibt erhalten.

**Wichtig:** Das Bild ist ein fotorealistisches **Konzeptbild**. Es ist kein Screenshot des Builds. Auch V3.7 darf erst nach einem visuellen In-Engine-Vergleich als fotorealistisch beurteilt werden. „AAA“ ist kein automatischer Qualitätsschalter in Godot.

## Konkrete technische Umsetzung
- **Mehrfach-PBR-Geländematerial:** `shaders/nexus_ground_v37.gdshader` projiziert die bereits in `assets/production/materials` vorhandenen, dokumentierten Rock- und Grass-Albedo-, Roughness- und Normal-Maps triplanar; berücksichtigte Hangneigung, Höhe, Makrofarbvariation und dynamisches Regen-Nasswerden. Ohne Assets bleibt die bestehende Terrain-Visualisierung intakt.
- **Geometrie und Vegetation:** `scripts/nexus_adlerklamm_graphics_v37.gd` generiert zwei unregelmäßige, geschichtete Canyon-Felswände; 490 instanzierte Nadelbaumkronen und Baumstämme mit variabler Skalierung/Färbung und Sichtweitenbegrenzung (kein Replizieren einzelner Drawcalls).
- **Wasser:** `shaders/nexus_river_v37.gdshader` mit animierten Wellen, Strömungsrichtung, Gischt- und Uferschäumung; das Original-Flussmesh erhält zusätzliche Unterteilungen.
- **Katastrophen-Details:** `scripts/nexus_bridge_fracture_v37.gd` ergänzt jedes der zwölf fallenden Brückensegmente um unregelmäßige Bruchflächen und **18 sichtbare Stahlarmierungen**; bestehende RigidBody-Kollision und Bergung bleiben erhalten.
- **Bus:** `scripts/nexus_bus_art_v37.gd` erweitert den physikalisch fallenden Bus um gekrümmte Dachschale, Frontscheiben-Paneele, Kotflügel-/Felgendetails, Bus-Sitzreihen, Scheibenrahmen, Spiegel- und Fahrzeugaufbauten.
- **Rettung:** drei zusätzliche szenische Einsatzfahrzeuge, animierte Rot-Blau-Lichter, vorhandenes lizenzdokumentiertes Hubschrauber-Modell (sofern der GLB-Import erfolgreich ist), Seil und Flussnebel.
- **Licht:** Filmic-Tonemapping, leicht gedämpfte AO, gerichtete Schatten, volumetrischer Nebel und kontrolliertes Glow im realen `WorldEnvironment`.
- **Kompatibilität:** Bestehendes referenznahes V3.6-HUD, automatische Brückenkatastrophe, Rettung nach Rollenwahl, Industrieproduktion und Savegames bleiben unverändert.

## Start
Godot 4.4.1 öffnen, `project.godot` importieren, **F5** starten. Im Referenz-HUD **F11** bringt den Spieler zur Adlerklamm-Anfahrt. Mit **F** ins Rettungsfahrzeug einsteigen und über die Brücke fahren; danach löst der Einsturz hinter dem Fahrzeug automatisch die Rettungsmission aus.

## Qualitätssicherung
GitHub Actions `.github/workflows/godot-check.yml` führt Import, ältere Regressions-Tests und den neuen **`tests/adlerklamm_v37_graphics_smoke.gd`** aus. Der neue Test prüft: Shaderanbindung im echten Level, 2 Felswand-Meshes, 490 instanzierte Bäume, 3 Einsatzfahrzeuge, 12 fallende Betonsegmente mit je 2 Bruchflächen und 18 Stahlarmierungen sowie physikalischen Bus mit über 45 Dekorelementen.

### Was der Test ausdrücklich NICHT beweist
- Keine objektiv bestätigte 1:1-Ähnlichkeit zum Bild.
- Kein GPU-FPS-Benchmark, kein 1080p/4K-Hardwaretest, kein exaktes AAA-Terrain oder fotogrammetrisches Waldmodell.
- Alle zusätzlichen Felsen, Bäume, Brückendetails und Bus-Paneele sind weiterhin **prozedurale Geometrie**. Es fehlen noch professionelle individuell modellierte, texelgenau texturierte 3D-Assets, character rigs, realistische Kollisionstrümmer und photogrammetrische Topografie.

## Folgende Abnahme ist für eine echte AAA-Aussage zwingend
1. Freier 16:9-In-Engine-Screenshot aus Godot Forward+ bei Tageslicht, Regen und Abenddämmerung, vergleichbarer Blickwinkel wie das Referenzbild.
2. 60 Sekunden tatsächliches Gameplay-Video mit dem Übergang Fahrt → Einsturz → Rolle wählen → Bergung.
3. GPU-Benchmark: Frametimes, 1%-Low und VRAM-Aufnahme bei 1080p/1440p Ultra; Low-/Medium-Profile separat.
4. Art-Abnahme der externen Meshbibliothek (Bus, Feuerwehr, Hubschrauber, Wald, Klippen, Industriestadt), PBR-Shader und Animationen.
5. Vervollständigte Multiplayer-/Mission-Regression und Echtzeit-Synchronisierung physikalischer Einstürze.

**Asset-Herkunft:** Die verwendeten externen Produktionsmaterialien/GLBs sind in `assets/production/ASSET_PROVENANCE.json` dokumentiert. V3.7 fügt keine unlizenzierten externen Asset-Dateien hinzu.
