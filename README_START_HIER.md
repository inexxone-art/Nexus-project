# PROJECT NEXUS V1.6 — CINEMATIC PROTOTYPE & iPHONE WEB PREVIEW

**Stand:** Prototyp mit sechs Planeten, 123 Fahrzeugprofilen, mehrstufigen Einsaetzen und In-Engine-Fotomodus. Kein fertiges AAA-Spiel.

## Schnellstart
- Godot 4.4.1 installieren, `project.godot` oeffnen und starten.
- WASD bewegen, E interagieren, F Fahrzeuge, F6 Fahrzeughalle, G Sternenkarte, F8 Welteinsaetze.
- NEXUS OPS: Eine Mission hat **drei Etappen**. Folge dem orangefarbenen Wegpunkt; erst die Rueckmeldung bringt Geld.
- Auf Touch-Geraeten: Bildschirmtasten + Kamerawischgesten, siehe `docs/V1_6_MOBILE_PREVIEW.md`.
- F4 Cinematic/Performance, F10 Kameramodus, F11 dort PNG-Screenshot (`user://nexus_shots`), F10 zurueck.
- F5 Welt speichern, F9 laden. Die Vorversion-Spielstaende werden weiterhin gelesen.
- In-Engine-Trailer: `docs/TRAILER_PRODUCTION.md` und `tools/build_trailer.py`.

## Technik und Qualitaet
- Original-Game-Engine: Godot 4.4.1, Forward+.
- Teststufen: statische Python-Checks, Godot Headless-Import, Gameplay-, Planeten-, Fraktions-, Foto- und Save-/Load-Smoke-Tests.
- GitHub Actions: `.github/workflows/godot-check.yml` und experimenteller `web-build.yml` (HTML5-Web-Export).
- Fuer iPhone: GitHub zum Entwickeln/Pruefen; das native 3D-Spiel benoetigt zum Spielen eine passende Laufzeitumgebung.

## Grenzen
- Die 48-Stunden-Story, fotorealistische 3D-Assets, drei- bis vierstellige Einzel-Animationen und vollstaendiger 4-Spieler-Koop sind nicht fertig.
- 123 Fahrzeugprofile sind keine 123 einzigartigen photogrammetrischen Modelle.
- Aktuelle Funktionstests ersetzen weder einen Performance-Test noch QA auf Zielhardware.

Siehe `docs/V1_5_RELEASE_NOTES.md`.
