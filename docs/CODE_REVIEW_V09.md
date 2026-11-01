# PROJECT NEXUS V0.9 – Code-Review und Einschränkungen

- Neue GDScript-Dateien: `drone.gd`, `nexus_map.gd`, `world_clock.gd`.
- Geändert: `world.gd` (neue Standorte und Wirtschaft, UI, Bauraycast und Kollision, Speicherformat), `smoke.gd` (mehr Prüfungen).
- **Statische Codeprüfung erfolgreich.** Alle referenzierten GDScript-Dateien und Texturdateien vorhanden.
- **Laufzeittest NICHT durchgeführt:** Godot fehlt in der Arbeitsumgebung; die Testdatei wurde nur geschrieben.
- **Grafikziel noch nicht erreicht:** Platzhaltermeshes und einfache Texturen; keine photorealistischen Charakter-, Fahrzeug- oder Umgebungsassets.
- **Multiplayer noch nicht vorhanden.** 100 Spieler pro dauerhafter Welt benötigen Netzwerkserver, Datenbank, Rechteprüfung und Lasttests.
- **Absturzrisiken ungeprüft:** PhysicsDirectSpaceState3D-Kollision, Godot-Szenenimport, GDScript-Parser und Performance müssen in Godot getestet werden.

**Erster Windows-Check:** Godot 4.3+ installieren, `project.godot` importieren, F5 starten, ggf. `TEST_GODOT.bat` ausführen; Fehlermeldungen aus dem Debugger dokumentieren.
