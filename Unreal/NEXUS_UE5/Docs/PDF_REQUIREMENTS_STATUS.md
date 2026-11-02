# NEXUS UE5.8 – Abgleich mit den Projekt-PDFs (02.11.2026)

## Quelle und Reichweite
Inhaltlich abgeglichen mit `PROJECT_NEXUS_KI_AGENTEN_UEBERGABE_2026-11-01.pdf`,
`PROJECT_NEXUS_Uebergabe_KI_Agent.pdf` und
`PROJECT_NEXUS_V30_MASTER_MISSIONEN_18_STORYS.pdf`.
Die PDF nennt **18 Missionskapitel × 7 Phasen**, **vier Spieler**, eine
**48-Stunden-Zielkampagne**, **acht Planeten plus sechs fiktive Welten**,
dynamische Konsequenzen, NPC-Gedächtnis, Fraktionen, Fahrzeuge, reale Materialien
und fotorealistische 3D-Welten.

## Was im Unreal-Branch wirklich implementiert ist
- C++ Codenucleus für Adlerklamm mit physikalischen Brückensegmenten, Bus,
  Rollenwahl, drei Bergungszielen, Ressourcenproduktion, vier Bauphasen, Save/Load.
- World Memory / Simulation Component: regionale Brückensicherheit, Medizin,
  Strom, Handelswege, Rettungsreputation, NPC-Vertrauen; deterministischer
  täglicher Regisseur mit begrenzten konditionalen Ereignissen.
- Kampagnensystem: 18 Datenkapitel mit 126 einzigartigen Ziel-IDs, sieben
  Handlungsetappen je Kapitel, zwei gespeicherten Konsequenzoptionen und
  strikt geordneter Freischaltung. **Nur das erste Kapitel ist mit konkreten
  Adlerklamm-Ereignissen verbunden.**
- Server-autoritative Eingabepfade, replizierter Missions-/Ressourcenstand,
  Standard-MaxPlayers=4. **Noch kein tatsächlicher Online-Koop-Playtest.**
- Zwei nav-basierte KI-Rettungshelfer mit Follow/Scout/Medic/Engineer-
  Befehlsschnittstelle. Ohne UE NavMesh sind Bewegungen nicht funktionsgetestet.
- 14 Weltprofile (8 echte Sonnensystemplaneten + 6 fiktive NEXUS-Welten),
  diverse Monde/Orbit-Orte als noch nicht inszenierte Erweiterungen.
- Nanite, Lumen, Schattenprofile in UE5-Config; Hero-Importer, 2K-
  Materialien, neun GLB-Terrainkacheln, vier eigene Fahrzeug-/Brücken-Prototypen,
  fünf original generierte Nadelbaum-/Fels-Modelle und ein echtes
  Poly-Haven-CC0-Fotogrammetrie-3D-Modell mit Original-PBR-Texturen.
- Offline-Python-Tests und GitHub Actions; **kein UE5-Editor-Build oder GPU-Test**.

## Was noch NICHT fertig ist
- Nicht 48 Stunden spielbare Kampagne, keine inszenierten 126 Kapitelphasen.
- Kein reproduzierbar getesteter 4-Spieler-Multiplayer, kein zertifizierter
  synchronisierter Chaos-Einsturz für Late-Join/Drop-out.
- Nur einige typische Prototypfahrzeuge, keine 123 vollständig modellierten
  Qualitätsfahrzeuge; noch keine Raumschiff-Innenräume oder Planet-zu-Orbit-Reise.
- Keine fotorealistischen vollständigen Städte, Industriewelten und Planeten.
- Keine professionell vertonten/animierten NPCs, ausgereiften Kampffunktionen,
  Dungeons, Zug-/Flug-/Schiffssysteme, langfristige Generationen oder Multi-Act-Finale.
- Kein echter Unreal-Engine-Screenshot, kein FPS-/VRAM-Benchmark.
- Kein kostenpflichtiger Cloud-Rechner: 0€-Grenze bleibt erhalten.

## Bisher zusätzlich separat verfügbare Dateien
1. 18 PBR-Sets mit 72 Texturen und Unreal-Importer.
2. 2017×2017 16-Bit Heightmap + sektorbasierte Oberflächenmasken.
3. Neun auflösungsfähige GLB-Geländekacheln.
4. Vier originale Fahrzeug-/Brücken-Prototyp-GLBs.
5. Fünf Nadelbaum-, Strauch- und Fels-GLBs (GitHub erzeugt und geprüft).
6. Tatsächlich gescannter Poly-Haven-Fels `rock_moss_set_02` (Kless Gyzen,
   **CC0-1.0**, 2K-Farb-, Normal- und Roughness-Textur, über 57k Dreiecke).
   **Powered by Poly Haven:** https://polyhaven.com/a/rock_moss_set_02

## Nächste notwendige Qualitätsabnahme
Für ein echtes Produkt müssen das UE5.8-C++-Modul auf einem Rechner mit Unreal
gebaut, die vier Original- und die gescannten CC0-Modelle im UE Editor importiert,
Kollision/Nanite/Materials überprüft, der Brückeneinsturz in mehreren Runs
gefilmt, der Missionsablauf mehrfach gespielt und die GPU-Frametimes/VRAM
gemessen werden. Die nächste strategische Stufe ist ein echtes visuelles
Adlerklamm-Vertical-Slice, NICHT massenhaft unspielbare Kulissen.
