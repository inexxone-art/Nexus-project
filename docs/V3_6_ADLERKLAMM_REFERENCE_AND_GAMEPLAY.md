# PROJECT NEXUS V3.6 — Adlerklamm Art Direction + Gameplay Vertical Slice

## Verbindliche Bildreferenz
Das vom Auftraggeber bereitgestellte NEXUS-Motiv zeigt:
- alpine Schlucht mit steilen, nassen Felswaenden, Wald, Schneegipfeln und aufgewuehltem Fluss
- zusammenbrechende Betonbruecke, abstuerzenden Reisebus, Staub, Stahlteile und fallende Truemmer
- Rettungshelikopter mit Bergung an der Seilwinde, Einsatzfahrzeuge, Industriestadt mit Kraenen
- HUD-Komposition: Mission links oben, Kompass oben, Rohstoffe rechts oben, Bergungsfortschritt rechts, Rundkarte und Rollenwahl links unten, Hotbar mittig unten und Ausruestung rechts unten

Das Bild ist **visuelle Zielvorgabe**, KEIN Screenshot eines bereits realisierten AAA-Spielbuilds. Eine 2D-Referenz allein liefert weder 3D-Geometrie noch UV-Texturen, Physik oder Animationen.

## Was in dieser Version tatsaechlich im Godot-Projekt funktioniert
1. Start in der bestehenden Open World. **F11** oder **ZUR ADLERKLAMM FAHREN** in der neuen HUD bringt dich zur Bruckenzufahrt und stellt ein Rettungsfahrzeug bereit.
2. **F** einsteigen; mit **WASD** ueber die Bruecke fahren. Der Einsturz wird **erst nach dem Fahren ueber das eigentliche Brueckendeck** und bei Verlassen der anderen Seite ausgelöst.
3. Zwölf physikalische Brueckenabschnitte loesen sich nacheinander; ein Bus als RigidBody mit eigenem Kollisionkoerper und Drehimpuls stuerzt in die Schlucht. Staubpartikel und vorhandene PBR-Brueckenoberflaechen werden verwendet.
4. Funkruf „Ist hier ein Sanitaeter oder Pilot?“. Die Auswahl im HUD startet **Sanitaeter**, **Pilot** (Hubschrauber im Schwebeflug) oder **Bodensuche**. Drei interaktive Rettungsziele, Speicherung und Belohnung nur einmal.
5. Sechs Bauplaetze und transaktionale Rohstoffketten: Steinbruch (Erz/Kalk/Sand/Kies), Schmelzofen (Eisen), Bohrinsel (Rohoel), Raffinerie (Bitumen/Diesel), Zementwerk, Asphaltwerk.
6. Bruckenreparatur in vier wirtschaftlich verknuepften Schritten: Schutt, Traeger, Beton/Zement, Asphalt/Freigabe. **E** nahe der Bruecke nach der Bergung.
7. Neues dynamisches Referenz-HUD: echte Rohstoffzahlen, echte Kompassrichtung, Auftraege, vier Bauphasen, Rundkarte mit Weltkoordinaten, auswählbare Rollen, vier wechselbare sichtbare Ego-Ausrüstungsmodelle.
8. **3–6** Ausruestung wechseln; Gewehr und Pistole haben verschiedene Testfeuerraten; Sanitaetstasche heilt nach Cooldown; Bauwerkzeug oeffnet den Baumodus. **F12** zeigt Industrieanlage bauen/produzieren. **F1** wechselt zum alten HUD.
9. Eigene unregelmaessige Felsmeshes statt uniformer Kugeln, wiederverwendete CC0-PBR-Albedo-/Normal-/Roughness-Oberflaechen, animierter Shader fuer den Fluss.

## Bekannte Grenzen
- Godot-Alpha. Das HUD ist als dynamische UI umgesetzt, aber die Vorlage ist weder Pixel fuer Pixel identisch noch ist die Welt auf AAA-Photorealismus.
- Der Bus und die Ausruestungsmodelle verwenden prozedurale Platzhaltergeometrie. Keine professionellen Riggs, PBR-Fahrzeuglackbibliothek, 3D-scannbaren Klippen oder ausgearbeitete Innenraeume in diesem Meilenstein.
- Keine strukturelle Bruchsimulation im Ingenieurssinn; Truemmer sind vereinfachte RigidBodies. Die NPC-Bergung ist ein interaktives Missionssystem, keine vollstaendige Sanitaeter-/Piloten-KI.
- Die Industrieproduktion wird als Spielrezept transaktional modelliert, nicht als industrielle Physik-Simulation.
- FPS und visuelle Qualitaet sind ohne reale GPU-Aufnahme nicht abgenommen. Ein erfolgreicher Headless-Test beweist Funktion, nicht Bildgleichheit.

## Nachweis
- Godot 4.4.1 auf GitHub Actions: Import- und Skriptsyntax, bestehende Regressions-Suite sowie V3.4, V3.5 und V3.6 Gameplay-Tests.
- Testdateien: tests/adlerklamm_v34_smoke.gd, tests/adlerklamm_industry_v35_smoke.gd, tests/adlerklamm_v36_hud_smoke.gd.
- F5 in Godot startet den spielbaren Main-World-Stand.

## Weiterer erforderlicher Produktionsumfang
Authored High-Poly-Bus mit Innenraum und Schadenszuständen; photogrammetrische Fels- und Terrain-Meshes, lizenzrechtlich geklaerte 2K–4K PBR-Bibliothek, Vegetations-Library mit LOD, Fassadenbibliothek mit echten Grundrissen, realistische Rauch-/Wasser-/Wetter-Simulation, synchronisiertes Schadenssystem sowie GPU-Profiling. Erst Engine-Screenshots und Performance-Messungen koennen die Referenzqualitaet belegen.
