# PROJECT NEXUS — Cinematic Fleet & Solar Campaign Alpha V1.3

**Status:** verifizierbarer Godot-Quellcode-Prototyp, **kein** fertiges GTA-6-/COD-AAA-Spiel. Ziel: eigene fotorealistische Open-World-Erlebniswelt mit Rettung, Einsatzkraeften, Fahrzeugen, Fraktionen, Bauberufen, Planetenerkundung und langfristiger Story.

## Jetzt im Quellcode

- Alpines 3D-Level mit Dorf, Wald, Bergen, Sektor 31, Rettungszone, Baustelle und Stadt; volumetrischer Nebel, Schatten, Licht, texturierte Materialien und neue Landmark-Kulissen.
- 6 betretbare Planeten-Levels mit eigenem Biome-Seed und Terrain (Terra Nova, Sahra IX, Nivora, Vesper, Ignis Prime, Umbra), Sternenkarte und Storyfragmenten.
- Sechs planetare Story-Arcs, jeweils mit Suche, Kampf, Bergung und einer gespeicherten finalen Entscheidung; der originale alpine Prolog bleibt erhalten.
- Datengetriebene Fahrzeughalle **123 unterschiedliche Datenprofile**: **70 Autos**, **20 Panzer**, **10 Helikopter**, **3 Bagger**, **20 Nutzfahrzeuge und Einsatzmaschinen**. Jede Variante hat eigene Fahrwerte und eine procedurale Modellvariante. Dies sind keine 123 individuellen High-Poly-Modelle.
- Wiederholbare Auftraege und Weltkonsequenzen; bestehende Wirtschaft, Baumodus, Drohne, Fahrzeugsteuerung, Save/Load und NEXUS DIRECTOR.
- Experimenteller **LAN-Koop-Avatar-Sync** (Host + bis zu 4 Freunde) — *kein vollstaendig synchronisiertes Koop-Spiel*. Vollstaendige Missionen/Interaktionen und Server-Autoritaet ausstehend.
- 8 prozedural erzeugte Albedo- und Normal-Map-Paare zusaetzlich zu den bisherigen Texturen.

## Starten

1. Godot 4.4.1 (Forward+ Rendering) installieren oder GitHub Actions CI fuer Headless-Pruefung nutzen.
2. `project.godot` mit Godot oeffnen und `F6` / Play druecken. Godot kann beim ersten Import Texturen verarbeiten.
3. Lokal: WASD bewegen, Maus umsehen, E nutzen, F Fahrzeug betreten, F6 Fahrzeughalle, F7 LAN-Koop-Vorschau, G Sternenkarte, F5/F9 Speicherstand.
4. Planeten: G Sternenkarte, Ziel auswaehlen, landen; E Mission, Mausklick feuern, R nachladen, 1/2 finale Storyentscheidung.

## Ehrlicher Teststatus

Statische Python-Validierung: `python3 tests/validate_project.py` und `python3 tests/validate_fleet.py`.
Runtime: GitHub Actions prueft Godot-Import und Smoke-Skripte bei Push / Pull Request. **Zum Zeitpunkt des Pakets kein erfolgreicher Godot-Runtime-Build bestaetigt.**

## Was noch fehlt

Photogrammetrie / High-Poly-3D-Modelle, echte Charakter-Animationen, professionelle PBR-Oberflaechen, ausgearbeitetes Gunplay, autoritatives Multiplayer, persistent synchronisierte Welt, Streaming riesiger Karten, vollstaendige 48-h-Kampagne, Performance-Messungen auf Zielhardware. Die Bildreferenzen sind eine visuelle **Zielvorgabe**, kein Screenshot aus diesem Build.

Fortsetzung siehe `docs/V1_3_PHASES_STATUS.md`.
