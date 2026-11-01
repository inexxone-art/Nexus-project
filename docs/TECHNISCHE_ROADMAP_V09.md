# PROJECT NEXUS – Architektur und verbindliches Langfristkonzept

## Spielvision

**Ein zusammenhängendes fiktives Sonnensystem** mit großen begehbaren Planeten, die mit eigenen Raketen ohne Planeten-Auswahlmenü angeflogen werden. Jeder Planet startet in einem anderen Zeitalter (Steinzeit, Mittelalter, 1945, Gegenwart, Zukunft), und KI-Zivilisationen entwickeln sich durch Forschung, Handel, Konflikte und Spielerentscheidungen weiter. Die Raumreise zu Nachbarplaneten soll als Spiel-Balancing-Ziel ungefähr 3–5 Minuten dauern. Das erfordert bewusst nichtrealistische Entfernungen und eine spezielle Welt-/Koordinatentechnik.

## Kernsysteme, langfristig geplant

1. **Freies universelles Bauen:** Blöcke, Präzisionsverbindungen, Gebäude, Fahrzeuge, Industrieanlagen, Raketen, Städte und verformbares Terrain. Eigentumsschutz und Bauphysik.
2. **Verkehr und Fahrzeuge:** Sportwagen, Motorräder, Traktoren, Forstmaschinen, Bagger, Kräne, LKW, Eisenbahnen, Schiffe, Panzer, Helikopter, Jets, FPV-Drohnen, Raketen und Raumschiffe. Tanken, Verschleiß, Cockpit, Tuning, Anhänger.
3. **Berufe und Wirtschaft:** Holzernte, Seilwinde, Sägewerk, Zellstoff, Papier, Landwirtschaft, Tierzucht, Bergbau, Gold, Erz, Öl, Raffinerie, Treibstoffe, Stromnetze, Baugewerbe, Handel, Arbeitsplätze, Immobilien.
4. **Rollen und Quests:** Polizei, Rettung, Feuerwehr, Militär, Unternehmer, Geheimdienst, historische Schlachtmodi, illegale fiktionale Missionen mit Konsequenzen, frei wählbare Story-Entscheidungen.
5. **Schlachten und Geschichte:** Arma-/Battlefield-inspirierte historisch-fiktive 1945-Fronten, Infanterie, Panzer und Luftfahrt, taktische Missionsziele, Deckung, zerstörbare und wiederaufbaubare Umgebung. Keine Nachbildung realer Waffenbauanleitungen.
6. **Rettungssystem:** Verletzung → KI-Rettung → Behandlung und zeitweise Infusion; beim zweiten Zusammenbruch sicherer Respawn und selbst ausgewählte Verluste aus dem Inventar; Eigentum bleibt bestehen.
7. **Überleben:** optionale Zombies nach einer fiktiven fehlgeschlagenen Forschungsinitiative, Quarantäne, Evakuierung, Medizinmissionen, Survival und Kreaturen.
8. **Planeten und Forschung:** Meteoritenabbau, Experimente mit nachvollziehbaren Fehlschlägen, eigene Raumfahrtindustrie, Schwerkraft-/Biomunterschiede, Weltraumrettung und interplanetarer Handel.
9. **Zivilisation und Herrschaft:** Nationen, Politikerrollen, Gesetze, Fraktionen, Diplomatie, Verrat, KI-Reaktionen, Staatenentwicklung, Sprachen und Geschichte.
10. **Persistenter Multiplayer:** Maximal 100 aktive reale Spieler pro dauerhafter Heimatwelt, auch bei einer Million Gesamtnutzern; Heimatwelt wird nicht neu zugeteilt. Je Welt eigene lokale Moderation und Sperren, **keine globale Spielsperre** aufgrund lokaler Regelverstöße. Geschützte zivile Eigentumsrechte, kriegszonenbezogene Zerstörung, Backup/Rollback. Besuch anderer Welten separat geregelt.
11. **Weitere Simulationen:** Untergrundstädte, Meer, U-Boote, Energie, Dämme, Eisenbahn, Archäologie, Wetterkatastrophen, Tier- und Ökosysteme, Unterhaltung, Medien, Wettbewerbe, Museen, Notrufleitstellen, Reparatur und Automatisierung.
12. **High-Quality-Grafik:** Fotorealistische Alpen, mittelalterliche Städte, Rettungsgebiete, nächtliche Quarantäne, Polizei/Feuerwehr, Baustellen und historische 1945-Szenen nach den bereitgestellten **Stilreferenzen**. Originale, legal lizenzierte Game-Ready-Assets erforderlich.

## Architekturpfad (keine Fertigstellungszusage)

| Meilenstein | Solide Prüfkriterien |
|---|---|
| V0.9 - Singleplayer-Vertikalschnitt | Godot öffnet ohne Parse-Fehler, mindestens vier funktionierende Wirtschaftsketten, Fahrzeuge, Bauen, Save/Load, FPV |
| V1.x - hochwertige Szene | LOD/Streaming, PBR-Materialien, Charakteranimationen, fahrbare Maschine mit echten Funktionen, 60 FPS auf definierter Testhardware |
| V2.x - Serverprototyp | Autoritative Serverlogik, 8–16 Spieler, persistente Datenbank, Schutz vor unzulässiger Zerstörung, reproduzierbare Netzwerk-Tests |
| V3.x - große Welten | Multi-Region-Streaming, belastbarer 100-Spieler-Lasttest, Modus- und Fraktionssystem |
| V4.x - Planeten | Große Koordinaten, mehrere Himmelskörper, Flug-/Atmosphärenübergänge, separate Simulation in inaktiven Gebieten |

## Hochskalierung

- **Nicht alle NPCs überall aktiv simulieren.** Stattdessen Aktivitätszonen und wirtschaftliche Offlinesimulation.
- **Bauwerke versioniert speichern.** Änderungen als serverseitig validierte Aktionen, Snapshots und Deltas, mit Rechten und gezielter Rücknahme.
- **Fahrzeuge und Bauwerke datengetrieben.** Komponenten anstelle von kopiertem Code; Asset-Katalog samt Lizenzen.
- **Performance zuerst messen.** World-Streaming, LOD/Impostors, Batching, Occlusion, Texture-Budgets und reproduzierbare Benchmarks.
- **Serverzustand ist maßgeblich.** Bewegung, Inventar, Schäden, Wirtschaftsaktionen, Eigentum und Sanktionen werden serverseitig geprüft.
- **100 GB sind kein Qualitätsziel.** Dateigröße resultiert aus Assets, nicht aus "besserem Code".
