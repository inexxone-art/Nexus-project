# PROJECT NEXUS — LIVING UNIVERSE V1.4

**Godot 4.4.1 · eigenständiges Open-World-3D-Prototyp-Projekt.**

## Start
Godot 4.4.1 installieren, `project.godot` als Projekt öffnen, Hauptszene starten.
Ein iPhone reicht, um GitHub/ChatGPT zu bedienen; das ist **keine iPhone-Spiel-App**.

## Neu in V1.4
- Sechs voneinander abhängige Regionen und sechs wiederkehrende Ereignisse, Fraktionsruf, Entscheidungen und gespeicherte Weltfolgen.
- `F8` / sichtbare Schaltfläche: **Einsatzleitung** öffnen. Die Entscheidungen ändern Geld, regionale Stabilität und Reputation.
- `F4`: **CINEMATIC / PERFORMANCE**. Zusätzliche Straßen-/Stadtdetails, Wetterpartikel, dynamischer Himmel, Industrie- und Naturobjekte.
- Regressionstests für die Weltsimulation, Qualitätsstufen und Speichern/Laden.
- Bestehende V1.3-Basis: 123 Fahrzeug-Definitionen mit Prototyp-Aufbauten, Story-Prolog, sechs Planeten, Forschungs-/Kampf-/Rettungsprototyp.

## Testen (Cloud-GitHub-Actions oder Rechner mit Godot)
```bash
python3 tests/validate_project.py
python3 tests/validate_fleet.py
python3 tests/validate_v14.py
godot --headless --path . --editor --import --quit
godot --headless --path . --script res://tests/living_smoke.gd
godot --headless --path . --script res://tests/visual_smoke.gd
```

**Ehrlicher Status:** Kein fertig entwickeltes AAA-Spiel, keine GTA-6-Qualität, keine 48 vollständig spielbaren Story-Stunden, keine fertige mobile iOS-Version. Siehe `docs/V1_4_IMPLEMENTATION_STATUS.md`.
