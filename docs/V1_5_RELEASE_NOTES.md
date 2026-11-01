# PROJECT NEXUS V1.5 — Spielbarer Prototyp: Einsaetze und Fotomodus

## Neu implementiert
- Sechs wiederholbare **dreistufige** Welteinsaetze mit Anfahrt, Folgeauftrag und Rueckkehr.
- Kein Geld fuer blosses Erreichen des ersten Wegpunkts. Auszahlung nur nach dem dritten Schritt.
- Wegpunkte und HUD zeigen das aktive Teilziel und die Entfernung.
- Fortschritt einer begonnenen Mission wird gespeichert; alte Spielstaende ohne `stage` bleiben ladbar.
- Abgeschlossene Feldauftraege beeinflussen regionale Stabilitaet, Versorgung, Wirtschaftslage (Prosperity) und Fraktionsruf. Konsequenzen erscheinen in der persistenten Weltchronik.
- **F10 Fotomodus**: freie Kamerabewegung, HUD aus, Q/E hoeher/tiefer, Shift schnell. **F11** speichert PNG unter `user://nexus_shots`. Das sind echte In-Engine-Bilder, keine generierten Werbeaufnahmen.
- Neue Godot-Regressionstests und CI-Schritte fuer Einsatzketten, Weltkonsequenzen und Kamera-Zustandswechsel.

## Nicht vorhanden / nicht behauptet
- Kein fotorealistisches AAA-Rendering wie GTA VI oder Call of Duty. Die Fahrzeuge und viele Bauwerke sind prozedurale Prototypen.
- Keine vollstaendige 48-Stunden-Kampagne; deren Grobstruktur ist geplant.
- Der LAN-Koop-Prototyp ist kein fertig synchronisierter 4-Spieler-Modus.
- Ein echter 75-Sekunden-Trailer erfordert zuvor mit dem Fotomodus und der Spiele-Engine aufgenommene Original-Gameplay-Clips.

## Reproduzierbarer Test
1. `python3 tests/validate_project.py && python3 tests/validate_fleet.py && python3 tests/validate_v14.py && python3 tests/validate_v15.py`
2. Godot 4.4.1: `godot --headless --path . --editor --import --quit`
3. Godot 4.4.1: `godot --headless --path . --script res://tests/operations_smoke.gd`
4. Godot 4.4.1: `godot --headless --path . --script res://tests/photo_smoke.gd`
5. Bestehende `smoke.gd`, `fleet_smoke.gd`, `solar_smoke.gd`, `living_smoke.gd` und `visual_smoke.gd` ausfuehren.

## Naechste Produktionsphase
- Professionell lizenzierte oder selbst produzierte 3D-Modelle mit LOD und Optimierung integrieren.
- Eine abgeschlossene 20-30 Minuten Vertical Slice mit Rettung, Kampfeinsatz, Fahrzeugfahrt, Storyentscheidung und Planetenuebergang.
- Echte In-Engine-Captures vergleichen, Bildrate und Framezeiten messen, danach den Gameplay-Trailer schneiden.
