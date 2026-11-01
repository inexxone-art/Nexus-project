# PROJECT NEXUS — V1.2: Sonnensystem und Planeten-Expeditionen

## Was wirklich implementiert ist
- Godot-4-Projekt mit bestehender alpiner Sandbox, Rettung, Fahrzeugen, Landwirtschaft, Bergbau und Bauwesen.
- In der Heimatwelt mit **G** oder sichtbarer Schaltfläche zur 3D-Sternenkarte wechseln.
- 1 Stern, 6 sichtbare und animierte Planetenbahnen; Auswahl mit 1–6 oder Schaltflächen.
- 6 unterschiedlich gestaltete, begehbare 3D-Planeten mit eigenem Terrain, Wetterfarbe, Materialien, Flora, Felsen, Ruinen und Landeplätzen.
- Pro Planet Missionskette: Scannen → feindlichen Sektor sichern → Kern bergen → Rückkehr zum Landeplatz.
- Einfaches Third-Person-Schießen mit Sichtlinien-Trefferprüfung, Munition, gegnerischen Patrouillen und Sanitäts-Evakuierung.
- Persistente abgeschlossene Kapitel, Fortschritt, Credits und Datenfragmente zwischen Reisen.
- Sechs Kapitel als Start einer Kampagne, nicht 48 Stunden fertig produzierter Missionen.
- Sichtbare Touch-Schaltflächen für wichtige Aktionen, jedoch keine fertig getestete iOS-App.

## Story-Bogen (geplante größere Handlung)
**Titel: PROJECT NEXUS — DIE SECHS SIGNALE**

Im alpinen Tal von Terra Nova führen eine Bergrettung und ein Datenträger aus Sektor 31 auf ein Signal unter dem Eis. Die wissenschaftliche Organisation HELIX hat sechs Fragmente eines uralten interplanetaren Netzes gefunden. Der Funkkontakt zu einer geheimen Station bricht ab; Fraktionen kämpfen um Energie, Lieferketten und den Zugang zur Technologie.

1. **Terra Nova — Das Signal im Eis.** Nach Rettung und Unfalluntersuchung führt ein Kapselsender zur ersten NEXUS-Anlage.
2. **Sahra IX — Das verschüttete Archiv.** In Sandstürmen muss ein verlassenes Raumschiff gesichert werden, bevor Plünderer die Daten erhalten.
3. **Nivora — Funkspruch Null.** Eine Eisstation warnt vor der Aktivierung des Netzes und verschwindet.
4. **Vesper — Der lebendige Code.** Ein biologischer Wald reagiert auf die Spieler. Forschung und Schutz von Leben stehen im Konflikt.
5. **Ignis Prime — Der Bruch im Kern.** Fabriken fallen aus; Spieler können Rettung, Energieversorgung und Fraktionskämpfe beeinflussen.
6. **Umbra — Der NEXUS-Ursprung.** Unter zwei Monden werden die Netzknoten und der Konflikt um ihre Kontrolle offengelegt.

Die bestehende Story-Prolog-Entscheidung (Behörden informieren / Daten veröffentlichen) ist noch **nicht** mit den Planeten-Dialogzweigen verknüpft. Koop für vier Spieler, taktische Shooter-Systeme auf AAA-Niveau, vollständige Weltsimulation, echte Raumflugsimulation, nahtlose Planet-to-Planet-Reisen, hochwertige animierte NPCs und fotorealistische Assets sind Backlog, nicht implementiert.

## Bedienung
- Auf Terra Nova: G = Sternenkarte, solange Baumodus aus. Schaltfläche „Sternensystem / Planeten“.
- Auf Sternenkarte: 1 bis 6 auswählen, Eingabe landen, Escape Heimatwelt.
- Auf Planeten: WASD, Maus, Linksklick feuern, R Munition, E Mission, G Sternenkarte.
- Im Missionsgebiet die cyanfarbenen Markierungen verfolgen. Abschluss bei drei ausgeschalteten Wachen und Rückkehr zum Shuttle.

## Tests
- `python tests/validate_project.py` prüft nur Dateistruktur und Referenzen.
- `godot --headless --path . --editor --import --quit` importiert/prüft das Projekt.
- `godot --headless --path . --script res://tests/solar_smoke.gd` prüft Planetenmodell und Missionsfortschritt.
- `godot --headless --path . --script res://tests/smoke.gd` prüft das alpine Basisspiel.
- Teste Grafik und Eingabe zusätzlich in einer echten Godot-Laufzeit. Laufzeit-Tests wurden in der Erstellungsumgebung **nicht** ausgeführt, wenn keine Godot-Binärdatei verfügbar ist.
