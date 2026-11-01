# Adlerklamm — fotorealistische Art-Direction für UE5.8

Das unveränderte Nutzerbild ist Qualitätsmaßstab. In der Szene müssen später konkret sichtbar sein: nasse geschichtete Felswände, detaillierter Reisebus beim freien Fall, rund 82 m lange Brücke mit realistischem Betonbruch und herausragendem Stahl, turbulenter Fluss, Rettungshelikopter mit Seilwinde, Feuerwehr/Blaulicht, Nadelwald, schneebedeckte Berge, industrielle Großstadt hinter der Schlucht und das NEXUS-HUD. **Kein KI-generierter Gameplay-Fake.**

## Übergabe für 3D-Artists
| Bereich | Produktives Asset | Anforderungen |
|---|---|---|
| Canyon | Nanite-Felsstücke | fotogrammetrische Detailgeometrie, gescannte 4K-PBR-Maps, Makro-/Mikrovariation |
| Brücke | Beton + Stahl | modular, Schäden, echte Bruchflächen/armierter Innenkern, Chaos Geometry Collection |
| Bus | High-Poly Reisebus | Reifen, Fahrwerk, Sitze, Innenraum, Glasbruch, mehrere Schadenszustände |
| Wasser | UE Water + Niagara | Fließgeschwindigkeit, Wildwasser, Schaum entlang Fels und Trümmern |
| Wald | PCG + Nanite-fähige Vegetation | dichte Nadelbäume, LOD, Windanimation, Höhenzonen |
| Himmel | SkyAtmosphere + Volumetric Cloud | Sturmfront, Nebel, Regen, dynamischer Tageswechsel |
| Industriestadt | Nanite/Fassadenbibliothek | Glas/Beton/Metall, offene Lobbys, Dachkonstruktionen, volumetrischer Smog |
| Figuren | MetaHuman/Rig | animierte Hände, Verletzten-/Rettungsanimationen |
| Fahrzeuge | mehrere Hero-Meshes | Rettungswagen, Feuerwehrauto, Helikopter, Verkehr, sichtbare Schäden |
| HUD | UMG | Bildaufbau mit Missionsliste, Rollenwahl, Kartenradar, Inventar, Bauphasen, wechselbarer Ausrüstung |

Alle externen Meshes nur mit dokumentierter Nutzungslizenz importieren. Die im Quellpaket generierten Maps sind **kein Ersatz für fotografisch gescannte Oberflächen**. Ein visuelles 1:1-Versprechen ist erst nach echten UE5-Aufnahmen mit GPU- und Qualitätsvergleich möglich.

## UE5 Rendering
- **Lumen**: dynamisches Licht / Reflektionen.
- **Nanite**: hochauflösende, statische Fels-/Gebäudemeshes (assetweise aktivieren).
- **Virtual Shadow Maps**: hochauflösende Schatten.
- **TSR**: zeitliche Rekonstruktion.
- **Chaos Geometry Collections**: strukturelle Bruchsimulation; Erst-CPP verwendet 12 RigidBody-Segmente.
- **World Partition + PCG**: später große Regionen streamen, dichter Wald.
- **Niagara**: spätere Staub- und Gischtsimulation.

## Abnahmekriterien
Echte UE-Editor-Screenshots in 1920×1080 und 3840×2160 aus demselben Blickwinkel wie das Bild; zehnsekündiger originaler Gameplay-Clip mit Fahrt, Brückenunfall und Bergung, ohne KI-Fake; VRAM-/FPS-/Frametime-Profiling; Test sämtlicher Missionstrigger, Savegames und Ressourcenketten.
