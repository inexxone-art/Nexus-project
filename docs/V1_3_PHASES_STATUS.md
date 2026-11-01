# PROJECT NEXUS — V1.3 Phase 1 / 2 / 3: Verifizierter Arbeitsstand

## Zielbild
Fotorealistische, zusammenhaengende Open-World wie in den Referenzen: Gebirgsdorf, Helikopterrettung, bewaffnete Einsaetze, Quarantaene-Station, moderne Blaulicht-Einsaetze, zerstoerte Wiederaufbau-Stadt, Raumhafen und verschiedene Planeten. Gameplay und Komposition koennen an AAA-Spiele erinnern, muessen aber eigenstaendige Welt/Assets und ein eigenes Regelwerk behalten.

## Phase 1 — Grafik, Welt, Fahrzeuge
- IMPLEMENTIERT ALS PROTOTYP: zusammenhaengende alpine 3D-Landschaft, mehrere gestaltete Einsatzorte, Fahrzeugsuche/Fahrzeughalle mit 123 Datenprofilen und Standard-Antriebsverhalten je Gattung, 8 texturierte Materialfamilien mit Normal Maps, Beleuchtung und Nebel.
- NICHT ERREICHT: Fotorealismus im Stil eines final gerenderten AAA-Spiels; cineastische Beleuchtungskontrolle pro Scene, hochwertige Fahrzeuge und Umwelt-Meshes, realistische Physiksimulation, Performance-Profiling, fliessendes Wettersystem pro Planet.
- NAECHSTER PRODUKTIONSSCHRITT: 1 Quadratkilometer Alpen-Tal mit hochwertigen Terrain-, Vegetations-, Dorf- und Helikopter-Assets, LOD/HLOD und fuer Zielplattform passende Materialqualitaet.

## Phase 2 — Kampf, Rettung, Koop, Fahrzeuge
- IMPLEMENTIERT ALS PROTOTYP: bestehende Missions-/Kampfbasis; erweiterte narrative Einsatzorte, 20 gepanzerte Fahrzeugprofile und 10 Helikopterprofile, Bergrettung / Wiederaufbau; experimentelle LAN-Avatarpositionen mit Host + 4 Freunden.
- NICHT ERREICHT: voll funktionsfaehiger vernetzter Koop mit geteilten Quests, Spawn-Logik, Missions-Autoritaet und persistenter gemeinsamer Welt; COD-nahes Gunplay und KI; belastbare Flugphysik, Turmsteuerung und realistische Baggerkinematik.
- NAECHSTER PRODUKTIONSSCHRITT: serverautoritatives 4+1-Spielermodell, replizierte Interaktionen/Kampfzustand, ein taktisches Einsatzlevel mit Animations-State-Machines, Waffen-Feedback und Squad-KI.

## Phase 3 — Sonnensystem, Story, lebende Welt
- IMPLEMENTIERT ALS PROTOTYP: 6 betretbare Levels in 6 Biomen mit Sternenkarte; sechs unterschiedliche Lore-Arcs, Missionen mit Scan / Sektor sichern / Bergen / Entscheidungen; gespeicherte Konsequenzen, NEXUS DIRECTOR und wiederholbare alpine Operationen.
- NICHT ERREICHT: nahtloser interplanetarer Flug, glaubhafte interplanetare Oekonomie, Generationssimulation, dynamisch neu geschriebene Missionsketten mit Story-Konsistenz, 48-Stunden-Kampagne.
- NAECHSTER PRODUKTIONSSCHRITT: 48-h-Hauptgeschichte in 6 Akten mit 8 Kernmissionen pro Akt (~1 h je Mission), hochwertige Dialoge, Kinematik und Script-Schnittstellen, Koop-Testfaelle.

## 48-Stunden-Story (Designplanung, KEINE fertigen Spielstunden)
- Akt I — Terra Nova (8h): Bergrettung, Signal, sektorale Quarantaene, Entscheidung ueber Datenfreigabe.
- Akt II — Sahra IX (8h): Wrackfelder, Schutz der Karawanen, Schmuggler, Antennen-Archiv.
- Akt III — Nivora (8h): Eisstation, Crew-Rettung, Reaktor, gesperrte Untergrundstrecken.
- Akt IV — Vesper (8h): Bio-Wald, Kontakt mit intelligenter Oekologie, Kolonialkonflikt.
- Akt V — Ignis Prime (8h): Industrieanlagen, Energiekrise, Arbeiterfraktionen, Schwertransport.
- Akt VI — Umbra (8h): Ruinen, Ursprung des Signals, finale Zusammenfuehrung bzw. Unterbrechung des Nexus-Systems.

## Mobile-Only-Entwicklung
GitHub/ChatGPT am iPhone fuer Quellcode. GitHub Actions unter Linux fuer headless Test. Zur Beurteilung der Grafik einen Cloud-Windows/Linux-Testrechner oder einen eigenen PC mit GPU verwenden. iPhone-Codierung allein bedeutet nicht, dass das Spiel direkt auf dem iPhone AAA-Grafik rendert.
