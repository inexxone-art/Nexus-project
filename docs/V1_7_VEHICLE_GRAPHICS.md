# PROJECT NEXUS V1.7 — Fahrzeug-Grafiküberarbeitung

## Was in dieser Version tatsächlich im Quellcode umgesetzt ist
- 123 bestehende Fahrzeugprofile bleiben erhalten, in fünf Familien; keine neue Behauptung über 123 individuell modellierte AAA-Assets.
- Einheitliche, maßstabsabhängige neue Fahrzeugvisualisierung `scripts/nexus_vehicle_visuals.gd` für Autos, Nutzfahrzeuge, Panzer, Helikopter und Bagger.
- Geformte, zusammenhängende Karosseriemeshes statt nur gestapelter Quader für Pkw und gepanzerte Rümpfe; Lack-Materialvarianten mit Metallizität und Klarlack.
- Detailgeometrie wie Räder/Felgen/Speichen, Kennzeichen, Außenspiegel, Seitenscheiben, Cockpit/Sitze, Grills, Stoßfänger, zusätzliche Lampen.
- Panzer mit Kettensegmenten als MultiMesh, Laufrollen, Schrägpanzerung, Turm, Rohr und Sichtoptiken; rein spielerisch und nicht reale technische Nachbauten.
- Helikopter mit Kabinenglas, Landekufen, Hauptrotor, Heckrotor und animierten Drehungen.
- Bagger mit Fahrerhaus, Hydraulik, beweglichem Ausleger und Schaufel; **noch keine Erdverformung**.
- Neue Fahrzeughalle mit drehbarer 3D-Vorschau, Filter und technischen Kenndaten vor dem Spawn; auf Touchscreens verwendbar.
- Wiederverwendete Steuerung und Fahrzeugkollisionen, nun nach Modellabmessungen skaliert.
- Neuer Headless-Regressionstest für alle fünf Fahrzeuggrundtypen und die 3D-Bauteile.

## Grenzen
Diese Prozeduralmodelle sind eine optisch detailliertere **Alpha-Prototypbasis**, kein Fotorealismus in der Liga GTA 6 oder Call of Duty. Für die Zielgrafik fehlen weiterhin individuelle lizensierte/selbst erstellte, hochqualitative Meshes mit UVs, PBR-Texturen, detaillierte Cockpit-Dashboards, Animationen, Fahrzeugschaden, Sounddesign, realistisches Fahrwerk und ausgiebige GPU-Performance-Messungen.

Ein grüner Godot-Headless-Test beweist die Szenenkompatibilität und Funktionalität, aber **nicht** die visuelle Qualitätsstufe oder ruckelfreie mobile Darstellung. Das muss später anhand von echten In-Engine-Screenshots und auf Zielhardware geprüft werden.

## Priorität für reale Grafikqualität
1. **Hero-Fahrzeuge**: zuerst 1 Sportwagen, 1 Rettungshubschrauber, 1 Bagger in hochwertigen, eigenständigen GLB-Modellen und echten PBR-Texturen ausbauen, statt 123 Modelle gleichzeitig nur oberflächlich aufzuwerten.
2. Fotorealistische Materialbibliothek mit Normal-, Roughness- und AO-Maps; UV-konforme Texturen und sauberer Maßstab.
3. Animationen und Innenräume dieser drei Fahrzeuge funktionsfähig machen.
4. Schatten, Licht und Umgebung passend abstimmen und auf PC- und Web-Version getrennt messen.
5. Mehr Fahrzeuge systematisch auf diesem Qualitätsniveau umsetzen.
