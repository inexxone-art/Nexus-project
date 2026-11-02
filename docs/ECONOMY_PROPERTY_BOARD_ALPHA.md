# NEXUS Wirtschaft & Missions-Pinnwand — Alpha-Modul

**Status:** Implementierter Godot-4.4-Datenkern, noch nicht an die 3D-Szene/UI angebunden. Kein fertiges Immobiliensystem mit Innenräumen, NPC-Mietern oder synchronisiertem Koop.

## Aktivierung
In Godot: Project > Project Settings > Autoload. Datei `res://scripts/systems/nexus_economy.gd` als **NexusEconomy** registrieren.

## Spielstart
- Eigenes Haus `starter_home` vorhanden, Startgeld 1.500 Spiel-Euro.
- Die Pinnwand zeigt ausschließlich `NexusEconomy.board_entries()`: drei Einführungsmissionen am Start, danach nur entdeckte Aufträge.
- Neue Missionen über `NexusEconomy.discover("meteorite_delivery")` nach realer Entdeckung freischalten.
- Nach Abschluss der Brücken-Einführungsmission wird der Brücken-Wiederaufbau sichtbar.

## API-Beispiele
```gdscript
var tasks = NexusEconomy.board_entries()
NexusEconomy.add_item("wood", 3)
NexusEconomy.finish_quest("intro_jobs")
NexusEconomy.buy_item("stone", 6)
NexusEconomy.manufacture("gravel", 3)
NexusEconomy.buy_property("village_house")
NexusEconomy.discover("meteorite_delivery")
NexusEconomy.start_research("lava_suit")
NexusEconomy.advance_time(3600.0) # eine simulierte Stunde
NexusEconomy.save_state()
```

## Weitere Arbeit
- UI der Büro-Pinnwand und Smartphone-Aufträge an die API anbinden.
- Kaufbare/betretbare Häuser als 3D-Szenen und Grundstücke realisieren.
- NPC-Bauarbeiter, Geschäfte, Mietverträge, Lager, Preise und Fabrikproduktion simulieren.
- Forschungsfreischaltungen mit echter Rüstung und Planetengefahren verbinden.
- Save/Load, Missbrauchsresistenz und Multiplayer-Serverautorität testen.
- Godot-Editor-/Smoke-Test auf Rechner mit Godot 4.4.1 ausführen.

**Wichtig:** Beispielpreise und Zeitmodell sind vorläufig. Miete wird pro *simulierter Spielstunde* abgerechnet, auch während Planetenerkundung, solange `advance_time` aufgerufen wird. Keine behauptete Echtgeld- oder Offline-Auszahlung.
