# PROJECT NEXUS V2.0 — 12 Bereiche, prüfbare Vertikalscheibe

## Status und Abgrenzung
**In Entwicklung / Alpha.** Alle zwölf angefragten Themen besitzen jetzt einen sichtbaren, programmierbaren Prototyp-Anknüpfungspunkt. Die meisten haben bewusst nur einen begrenzten vertikalen Funktionsumfang. Das ist keine fertige Produktion mit GTA-6-/COD-Qualität, keine 48h-Kampagne und kein vollständiges Koop-Spiel. GitHub-CI belegt nur das, was dort tatsächlich getestet wurde.

| # | Bereich | V2.0: tatsächlich implementierter Ausschnitt | Noch nicht fertig |
|---|---|---|---|
| 1 | Grafik | Bestehende PBR-Landschaften, Environment, Licht, Wetter, zwei Renderprofile plus mobiles Profil | Fotogrammetrie, High-Poly-Assets, auf Hardware abgenommene FPS |
| 2 | Fahrzeugphysik | Wetterabhängiger Grip, Braking Helper, Condition/Wear, Kilometer, Boden-/Flug-Steuerung; Hero V1.8 integriert | Radaufhängungen, Reifenmodell, interaktive Fahrzeugschäden, Motor-/Getriebesimulation |
| 3 | Innenräume | Begehbare NEXUS-Einsatzzentrale mit Arbeitsplätzen und schwenkender Tür | Vollständig möblierte Gebäude und Räume in allen Städten |
| 4 | NPC-Leben | Vier NPCs, Bewegungsroutine, Dialoge am Einsatzhub | NavMesh, Tagesaufgaben, Emotionen, LLM-Dialoge, NPC-Lebenszyklen |
| 5 | Kampf | Bestehender Planetenprototyp und lokaler Trainingszielstand mit Raycast/Punkten | Hochwertiges Gunplay, Waffenanimationen, Deckungs-/Squad-AI |
| 6 | Zerstörung | Drei persistente Infrastrukturzustände, gesperrte/erlaubte Reparatur gegen Credits, Zwischenfall-Verschleiß | Zerstörbare Meshes, Trümmerphysik, reale Bauabläufe |
| 7 | Raumfahrt | Bestehende 6 begehbare Planeten sowie 3 versteckte Funde pro Planet, gespeichert | Nahtloser Orbit, begehbares Flugschiff, viele Planetenbiome mit AAA Assets |
| 8 | Animation | Kleine originale Laufbewegungs-Animation, Fahrzeug-Showcase-Animationen | Motion Capture, Rigging, Gesichter, Hände, IK, Interaktionen |
| 9 | Wetter | Regen/Schnee beeinflussen Haftung und Bremswege der Fahrzeuge; bestehende visuelle Niederschläge | Flüssigkeit, Aquaplaning, Schnee-/Deckenänderung, Simulation von Unwettern |
| 10 | Geheimnisse | 3 auf Terra + 3 je Planet, mit einmaliger Bergung und gespeicherten Belohnungen | Umfangreicher investigativer Rätselbaum |
| 11 | Audio | Original synthetisierte Ambient- und Bestätigungstöne, stummschaltbar | 3D-Ambisonics, echte Motor-/Rotorklänge, Voice Acting, Score |
| 12 | iPhone / Web | Vorhandene Touch-Steuerung + AIM/FPS; Preset Mobile (30FPS cap), Balanced (60FPS cap), Cinematic (unlimited), FPS Anzeige | Gemessene iPhone-FPS und langer mobile Playtest, vollständiger iOS-Build |

## Bedienung
- **WASD** bewegen, **F** Fahrzeug, **E** interagieren, **G** Sternensystem, **F6** Fuhrpark, **F10** Fotomodus.
- **F3** Grafik/FPS-Anzeige öffnen und Profil wechseln; **F4** alter Quick-Toggle; **J** Audio an/aus.
- Im Trainingsgelände **Linksklick** bei gefangener Maus auf Übungsziele, am iPhone **AIM**.
- Auf iPhone **FPS**-Button öffnen. Höhere Grafikqualität kann auf mobilen Browsern instabil sein.
- Bei der Basis im Alpental: **E** Tür öffnen/schließen; bei vier Personen sprechen; bei beschädigten Anlagen 75 Credits zur Reparatur ausgeben.
- Geheimnisse sind absichtlich nicht auf der Karte markiert. Planetenfunde sind pro Welt im Speicherstand abgelegt.

## Qualitätsregeln
1. **Funktions-CI:** GDScript-Import und `quality_v20_smoke.gd` müssen fehlerfrei bestehen. Alte Smoke-Tests weiterhin erforderlich.
2. **Daten und Lizenzen:** Nur eigene procedurale Modelle/Texturen. Keine fremden AAA-Assets als Spielcontent ausgeben.
3. **Grafik-Abnahme:** Identische In-Engine-Screenshots bei Sonne, Regen, Nacht; Nahaufnahme und 30-m-Abstand zu jedem der drei Hero-Fahrzeuge. Ein photorealistischer Qualitätstitel folgt erst nach echter Abnahme.
4. **Mobil-Abnahme:** Reale FPS, Auflösung, Speicherauslastung und Ladezeiten auf einem konkreten iPhone dokumentieren. 30FPS cap ist kein 30FPS-Leistungsnachweis.
5. **Multiplayer:** LAN-Vorschau ist nicht netzwerksichere gemeinsame Story. Kein Claim eines voll entwickelten Koop-Modes.

## Nächste Produktionsschritte zur angestrebten AAA-Optik
1. Ein professionelles, eigenständiges optimiertes Sportwagen-GLB mit UVs, animierter Tür, LODs und PBR ORM/Normal-Albedo-Materialsets.
2. Dasselbe für Rettungshubschrauber und Bagger, mit Interaktionspunkten und echten Geräuschen.
3. Ein begrenztes fotorealistisches alpines Level mit Terrain-/Foliage-Streaming, geprüfter Kollision, sauberem Licht und echter Performancemessung.
4. Eine 10–15-minütige abgenommene Storymission mit NPC-Navigation und Animationen.
5. Ein **echter** Gameplay-Trailer ausschließlich mit abgefilmten Spielszenen, nicht KI-Konzeptgrafiken.
