# PROJECT NEXUS – Grafikausbau und Gesamtarchitektur nach V0.8

## Stilreferenzen (vom Auftraggeber geliefert)

Die sechs Referenzbilder zeigen: (1) Alpen-/Mittelalterdorf, (2) Bergrettung mit Helikopter, (3) nächtliche Forschungs- und Quarantänezone, (4) nächtliche Polizei-/Feuerwehr-/Rettungsszene, (5) Kriegsruinen und Wiederaufbau, (6) historische Militärfahrzeuge und Einsatzkräfte.

**Zielästhetik:** natürliche Oberflächen, detailreiche Formen, große Sichtweiten, szenisches Licht, dichte Vegetation, Wetter, Materialien mit Roughness- und Normalmaps, glaubwürdige Modellmaßstäbe und Animationen. Die aktuellen Meshes sind nur ein einfacher Platzhalter, keine Annäherung an AAA-Fotorealismus in objektiver Qualität.

## Was V0.8 wirklich als Godot-Quellcode enthält

- Eine **zusammenhängende** 460 x 460 m große Grundkarte mit vier thematischen Hauptbezirken sowie Wiederaufbau-Areal
- 7 grob modellierte fahrbare Fahrzeugklassen (Traktor, LKW, Sportwagen, Rettung, Panzer, Bagger, Helikopter); vereinfachtes Fahrmodell, Helikopter mit Steigen/Sinken, rotierendem Rotor
- Bausystem mit zehn vorgefertigten Bauteiltypen, 0,5/1/2 m Raster, 15° Drehung, Höhenversatz; das ist **kein** frei kombinierbarer Engineering-Simulator
- Vier einfache Orts-/Liefer-/Kontrollmissionen und Geldbelohnung; keine komplexe Gegner-KI
- Öl-/Gold-Interaktion, Holzfällen, Stämme liefern, Tanken und Reparatur, Spielstand speichern/laden
- Neue prozedurale Materialtexturen; Basismodelle aus Box/Cylinder/Sphere und originale Code-Geometrie

## Langfristiges Spielkonzept: alle geforderten Systeme

| Großsystem | Nötige Technologie | Status V0.8 |
| --- | --- | --- |
| Riesige Open World + dynamische Zeitalter | World-Streaming, LOD, Sektorensimulation | Nur kleine Grundkarte |
| 100 echte Spieler je permanente Heimatwelt | Autoritativer dedizierter Server, DB, Replikation, Anti-Grief-Logik | Nicht vorhanden |
| Planetensystem / nahtloser Raketenflug | planetare Koordinaten, Floating Origin, Gravitation, Atmosphärenwechsel | Nicht vorhanden |
| Freies Bauen / jedes Bauteil verbinden | Steckpunkte, statische Tragstruktur, Kollisionen, Ressourcen, Multiplayer-Replikation | 10 einfache Bauteile |
| Holz-/Landwirtschaft | Maschinenphysik, Interaktion, Prozessketten | Holz vereinfacht; Landwirtschaft noch nicht nativ |
| Öl, Metall, Gold, Papier, Industrie | Produktionsgraph, Fabriken, Lager, Transport | Öl/Gold nativ nur vereinfacht |
| Fahrzeuge: Sportwagen, Forst, Bau, Panzer, Jets, Schiffe, Raketen | Je Kategorie Fahrzeugdynamik, Sounds, Animationen und Schadensmodell | 7 grobe Klassen |
| Rettung / Polizei / KI-Wiederbelebung | KI-Navigation, Ragdolls, Trage-/Sanitätsanimationen, Zustandssystem | Ein Lieferauftrag, keine KI-Rettung |
| Kriege 1945 / moderne Kampfzonen | Eigene taktische Gegner-KI, Missionssystem, sichere Kampfzonen, Zerstörung | Eine historische Ruinenzone, Kontrollmission |
| Zombies durch Laborunfall | KI-Navigation, Ausbruchsimulation, Zustands- und Infektionsmodell | Forschungszone, kein natives Zombie-System |
| NPC-Gesellschaft / Politik / Staaten / Gerichte | Agentensimulation, Regeln, Erinnerungen, Wirtschaftsserver | Nicht vorhanden |
| Meere, Eisenbahnen, Tiefbau, Terraforming, Roboter, Raumstationen, Tierwelt | Eigenständige Simulations-Subsysteme | Nicht vorhanden |
| Realistische Grafik wie Referenzen | Studio-Assets, Terrain, Animationen, Licht, PBR, LOD und Optimierung | Nur primitive prozedurale Modelle |

## Produktionsvoraussetzungen für wirklich hochwertige Grafik

1. **Content-Pipeline:** Blender-Modelle als GLB, jeweils mit UVs und PBR-Materialien; keine unbearbeiteten Referenzbilder als Spielgrafik ausgeben.
2. **Terrain:** geformte Höhenkarte, Felsen mit Displacement, korrekt begehbare Kollisionen, Schnee- und Schlammzonen, Straßenränder.
3. **Szenen:** zuerst ein hochwertiges 100 x 100 m Alpen-Diorama mit Haus, Straße, Bäumen und einem Fahrzeug, bevor der gesamte Kontinent skaliert wird.
4. **Animation:** Rig für Charaktere, Verladen, Motorsäge, Traktor, Hubschrauber, verletzte NPCs und Rettung.
5. **Licht:** Schatten, atmosphärischer Nebel, Tageszeiten, lokale Nachtbeleuchtung, Reflexionen nach GPU-Budget.
6. **Leistung:** wiederholbare 1080p-FPS-Messungen; Instancing, Mesh-LOD, vereinfachte entfernte NPC-Simulation.
7. **Qualitätsabnahme:** Godot-Headless-Test, echte Windows-Tests, Videoaufnahmen, Regressionstest für Speichern/Laden.

**Realismus:** Eine fertige globale AAA-Simulation dieser Größenordnung erfordert ein erfahrenes Entwicklungsteam, ein großes Asset- und Serverbudget sowie erhebliche Entwicklungszeit. V0.8 ist der Anfang des technischen Spielkerns, nicht die Vollversion.
