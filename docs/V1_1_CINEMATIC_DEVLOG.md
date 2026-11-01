# V1.1 – Änderungen und nachvollziehbarer Status

## Gegenüber V1.0 implementiert
1. `scripts/cinematic_landscape.gd`: Kontinuierliches, farbkodiertes Gebirgsmesh statt 25 niedriger Kegelberge und 40 weiterer Kulissenkegel; instanzierter dekorativer Wald, Geröll, See und Gras.
2. `scripts/world.gd`: Landscape in bestehende Welt integriert, Render-Environment um moderne Godot-4-Effekte ergänzt, alte Kulissen abgeschaltet, Story-Integration in Interaktions- und Speicherpfad.
3. `scripts/nexus_story.gd`: Vier Etappen mit Markierung, Ruf, zwei Wahlmöglichkeiten, Münzbelohnung und permanentem Story-Memory.
4. `tests/smoke.gd`: zusätzliche Tests für Landschaft, Story-Fortschritt, Wahl, Abschluss und Speicherwiederherstellung (nur vorbereitet; nicht ausgeführt).
5. `project.godot`: Desktop standardmäßig Forward+; Mobilgeräte weiterhin Compatibility.

## Was noch fehlt
- Die Bilder zeigen realitätsnahe 3D-Szenen. Die in der Alpha verwendeten Grundkörper und prozeduralen Meshes sind keine vergleichbare fotorealistische Grafik. Dazu benötigen wir hochwertige Meshes, PBR-Texturen, Animationen, Modellierungsarbeit und belastbare Hardware-Tests.
- Dekorativer Wald und Wasserflächen haben keine physikalische Kollision, NPCs sind Platzhalter.
- Die Missionen werden durch Interaktion fortgesetzt, nicht durch vollautomatisch reagierende KI.
- Keine ausgereifte 4er-Koop-Implementierung, keine 48-Stunden-Hauptstory.

## Tests
- `python tests/validate_project.py`: statische Prüfung.
- Nach Import in Godot: `godot --headless --path . --script res://tests/smoke.gd` (optional).
- Danach F5 und manuell prüfen: Start, Story-Trigger, Grafik, Fahrzeuge, Gebäude, Save/Load, Performance.
