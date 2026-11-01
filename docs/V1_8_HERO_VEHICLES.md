# PROJECT NEXUS V1.8 — drei detaillierte Hero-Fahrzeuge

## Implementiert

- `CAR_041` Supersportwagen Vortex: neue Karbon-Aerodynamikteile, Lüftung, dreidimensionale LED-Akzente, sichtbare Bremsbauteile, originale NEXUS-Emblemform, Armaturen- und Gurtdetails.
- `HELI_01` Alpin H1: Rettungsstreifen, Kabineneinrichtung, Krankentrage, Seilwinde, Suchscheinwerfer, Turbinengitter, verstärkte Landekufen. Haupt- und Heckrotor werden durch die bestehende Fahrzeugkomponente animiert.
- `EXC_02` Mobilbagger 14t: Gegengewicht, Lüftungsgitter, Bedienerkabine, Joysticks, Unterwagen, bewegungsgebundene Schaufeldetails und zusätzliche Hydraulikbauteile. Ausleger/Schaufel folgen den vorhandenen Animations-Pivots.
- Originale, selbst prozedural erzeugte Carbonfaser- und Mikro-Normalmaps (`assets/hero_*.png`) ergänzen die auf Metallic/Roughness basierenden Godot-PBR-Materialien.
- In der Fahrzeughalle (`F6`) stehen drei Schnellzugriffe bereit. Die 3D-Vorschau lässt sich am Touchscreen und per Maus drehen; per Mausrad zoomen. Die anderen 120 Fahrzeugprofile bleiben unverändert.

## Prüfung

- `python3 tests/validate_v18.py` prüft Dateiverknüpfungen, Katalog und Hero-ID-Kontrakte.
- `godot --headless --path . --script res://tests/hero_vehicle_smoke.gd` instanziiert die drei Fahrzeuge, prüft Komponenten und ruft Animationen auf.
- GitHub Actions führt Import/Parser-Checks und die alten Regressionstests aus.

## Qualitätsgrenzen – transparent

Es handelt sich um aufwendigere **Original-Prozeduralmodelle**, keine realen gescannten Fahrzeuge. Diese Version besitzt **keine** hochauflösenden, manuell modellierten AAA-GLB-Assets, lizenzierte Automarken, fertige photogrammetrische Fahrzeuge, echte Motor-/Hydraulik-Simulation oder abgenommene mobile Frameraten. Die Konturen und Materialvielfalt sind verbessert, müssen aber noch anhand echter In-Engine-Screenshots bewertet werden. Die Fahrzeugdaten und der restliche Spielstand bleiben erhalten.

## Grafik-Abnahme als nächster Schritt

Für fotorealistische Lookdev-Qualität braucht jedes der drei Hero-Modelle manuell modellierte Geometrie, korrektes UV-Unwrapping, eigene hochauflösende Albedo/Normal/ORM-Texturen, Rigs, Sound und drei LOD-Stufen. Art Direction: Alpendorf bei Sonne/Regen/Nacht, gleiche Kamera, je ein Screenshot vor/nachher. Browser-Fallback auf schwächeren Handys muss separat optimiert werden.
