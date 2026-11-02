# NEXUS — Unreal Engine 5.8 (Migration-Prototyp)

**Status:** Eigenständige C++-Migration mit spielbarer Mission als Entwicklungsziel, noch **nicht** auf UE5 kompiliert oder als AAA-Grafik abgenommen. Die ursprüngliche Godot-Version bleibt im selben GitHub-Repository getrennt erhalten.

**V7 / 02.11.2026:** Bus als fahrender Verkehr hinter dem Spieler, dreistufige Suche/Erstversorgung/Bergung, pro Spieler getrennte Koop-Rollen, replizierte Missionsreferenzen und gespeicherte Teilrettungen. Details und Abnahmeliste: [NEXUS V7 Adlerklamm Rettung](Docs/NEXUS_V7_ADLERKLAMM_RETTUNG.md). Diese Features sind als Code implementiert, aber noch nicht in einem UE5-Editorbuild abgenommen.

## Start auf Windows
1. **Unreal Engine 5.8** und **Visual Studio 2022** mit den Workloads "Game development with C++" und dem Windows SDK installieren.
2. Den **kompletten NEXUS-Unreal-Paketordner** entpacken (das kleine GitHub-Quellprojekt enthält keine großen Bildtexturen).
3. `NEXUS.uproject` öffnen; Unreal fragt ggf. nach dem Kompilieren des C++-Moduls `NEXUS`.
4. Im Unreal Editor **File > New Level > Basic** erstellen. Das Spiel startet seine temporäre Adlerklamm-Blockout-Welt zur Laufzeit über `NexusGameMode`. Den Level als `/Game/Maps/L_Adlerklamm` speichern und bei Bedarf als Startup Map einstellen.
5. `Edit > Plugins > Python Editor Script Plugin` aktivieren, Editor neu starten und unter **Tools > Execute Python Script** die Datei `Scripts/import_nexus_pbr.py` ausführen.
6. Die generierten Materialien aus `/Game/AAA/Materials` verwenden und professionell modellierte Bus-, Brücken-, Natur- und Gebäude-Assets in eigene Unreal-Blueprint-Varianten der C++-Klassen einfügen.

## Steuerung
- **WASD, Maus, Leertaste:** Gehen, Umschauen und Springen
- **E:** Ins Rettungsfahrzeug einsteigen, Ziel retten, Industrie bauen oder produzieren
- **WASD im Fahrzeug:** Fahren / Helikopter steuern
- **F:** Fahrzeug verlassen
- **F1 / F2 / F3:** Nach dem Notruf zwischen Sanitäter, Pilot oder Suchteam wählen
- **1 bis 4:** Ausrüstungsslots (aktuell Auswahlzustände, noch keine fertigen Waffenanimationssysteme)
- **F5 / F9:** Mission speichern / laden
- **F11:** Zur Adlerklamm-Anfahrt wechseln

## Missionsablauf
1. Als Spieler auf dem westlichen Bergplateau starten.
2. In das Rettungsfahrzeug einsteigen und **über** die Brücke fahren.
3. Erst nach der echten Überquerung wird der Bus auf der Brücke mit **Chaos-RigidBody-Physik** losgelassen; zwölf separate Brückenteile brechen ein.
4. Automatischer Notruf: **Ist hier ein Sanitäter oder Pilot?** Eine Rolle wählen.
5. Drei Überlebende über Bodeninteraktion oder Helikopter-Schwebebergung retten. Nur eine Belohnung pro Rettungsmission.
6. Für den Wiederaufbau zuerst Holz beschaffen, Erz und Kalk abbauen, Eisen schmelzen, Öl fördern, raffinieren, Zement und Asphalt herstellen. Jede Produktionsstätte kostet Material/Geld und hat einen Arbeitszyklus.
7. Vier Wiederaufbauphasen: Schutt, Stahl, Beton, Asphalt. Fertige Brücke wird wieder befahrbar; der Missionsstatus ist speicherbar.

## Wichtige Qualitätseinschränkungen
- **Noch keine fotorealistische fertige Karte.** Ohne lizenzierte photogrammetrische Fels-/Wald-/Gebäudemodelle rendert das Projekt primitive **Platzhalter**.
- Die zwölf Brückenteile sind mit Chaos physikalisch simulierte Mesh-Segmente. Für professionelle Betonbrüche die Brücke im **Fracture Mode** als **Geometry Collection** bearbeiten, Cluster/Anker und Schäden einstellen und in Blueprint an den Missionseinsturz anbinden.
- Der Bus braucht ein eigenes High-Poly-Mesh mit Innenraum, Deformationsstufen, Glasbruch und Sounddesign. Die Eigenschaft `HighPolyBus` ist vorbereitet.
- **Nanite + Lumen + VSM + TSR** sind im Rendering-Profil aktiviert; hohe Qualität entsteht erst durch hochwertige Unreal-Materialien, Beleuchtung, Nanite-Meshes und Performanceabnahme.
- Multiplayersynchronisierung, MetaHuman-NPCs, ausgereifte Pilot/Medizinanimationen, volle 500-Stunden-Kampagne und andere Planeten sind nicht Bestandteil dieses ersten Portierungsschritts.

## Technische Prüfung
UE5.8 ist in dieser Ausführungsumgebung **nicht installiert**; die Unreal-C++-Klassen konnten daher noch nicht durch UnrealBuildTool/Editor kompiliert oder visuell getestet werden. Vor einem Merge den tatsächlichen UE5-Editorbuild, automatisierte Tests, Controller-Possession und Physik live prüfen.

## Herkunft
Die Albedo-Quellbilder stammen aus den im NEXUS-Projekt vorhandenen KI-generierten Oberflächen. Normal-/Roughness-/AO-Karten werden aus der Bildhelligkeit **heuristisch abgeleitet** – keine gemessenen Materialwerte und keine 3D-Photogrammetrie. Das Bild mit Bus, Rettungshelikopter und HUD ist ausschließlich die **Art-Direction-Referenz**, kein Gameplay-Screenshot.

## Neuer Open-World-Prototyp (02.11.2026)
- START: Spieler startet im begehbaren Platzhalter-Haus (in Adlerklamm; südliche Tür, Büro mit Pinnwand). **B** direkt im Büro zeigt nur entdeckte Aufgaben; **E** an der Pinnwand liest sie als Funktext.
- **M** Smartphone öffnen/schließen, **K** 1 Golderz für 180 Credits nach Handelsgebühren verkaufen, **U** erste Mietwohnung für 1.500 Credits kaufen. 170 Credits Miete pro Spieltag minus 45 Unterhalt = 125 netto am Tageswechsel. Welt-/Koop-Konto ist derzeit gemeinsam, nicht pro Spieler.
- Zwei neue Baustellen/Produktionsstätten: **Goldmine** (+2 Golderz und +1 Eisenerz pro Zyklus) und **Sägewerk** (3 Holz → 5 Bretter). Ein Bau kostet Rohstoffe und Geld; Startprodukte erscheinen nicht automatisch.
- **F11** bleibt schnelle Rückkehr zur Adlerklamm-Brückenmission; **V** Kamera wechseln, **F5/F9** speichert/lädt Mietobjekt und Pinwand-Entdeckungen.
- **Grenze:** Haus ist begehbarer Unreal-Cube-Blockout oder importiertes `SM_NEXUS_StarterHome`, nicht fotorealistische Architektur. Goldmine ist momentan eine interaktive Produktionsstätte, **kein** unterirdisch begehbares Höhlennetz; Mietwohnung ist eine wirtschaftliche Buchung, kein eigenes begehbares Gebäude. Das wird erst mit weiteren Level- und Interieur-Assets umgesetzt.

## Quell-Asset-Bundle vom 02.11.2026
Das in dieser Unterhaltung bereitgestellte **NEXUS_UE5_ALLE_VORHANDENEN_ASSETS_IMPORTPAKET.zip** wurde aus 6 vorhandenen Bibliotheks-ZIPs geprüft und enthält die korrekte Ordnerstruktur `Content/SourceArt`. Bitte nicht mit fertig importierten Unreal-`.uasset`-Dateien verwechseln.
1. ZIP separat entpacken und `Install_NEXUS_SourceArt.ps1 -ProjectFolder "C:\\Pfad\\Nexus-project\\Unreal\\NEXUS_UE5"` ausführen (oder die SourceArt-Ordner manuell kopieren).
2. UE Editor 5.8 mit Python Editor Script Plugin starten.
3. In **Tools > Execute Python Script** `Scripts/import_nexus_all_verified.py` ausführen – die Pipeline importiert PBR, Hero-Meshes, Terrain-Vorschauen, Foliage und CC0-Felsscan soweit verfügbar.
4. Das `Content/SourceArt/Heightmap/Adlerklamm_Landscape_2017x2017_16bit.png` im Landscape-Tool als echte Landschaft importieren; nicht als glatte Terrain-Mesh-Vorschau behandeln.
5. Nach Import Assets prüfen, Maße/Materialien, Kollision, Lumen/Nanite-FPS testen. Noch keine Real-UE-Renderfreigabe.

## V5 – Waffensystem (spielbarer Source-Code-Prototyp)
- **Maus links**: spielinterne Schussabgabe; derzeit ausschließlich Wertung auf Trainingszielen (kein PvP, keine neutrale-NPC-Schadensmechanik). **Q**: durch vier konventionelle Waffen und später zwei Sci-Fi-Waffen wechseln. **R**: nachladen. Ammo/Magazin im HUD sind echte Spielzustände; serverautoritativ für 4 Spieler.
- Pistole, Karabiner, Präzisionsgewehr und leichte Waffe sind von Beginn freigeschaltet; Alien-Puls und Plasmabogen erst nach der kurzen Schießstand-Übung (5 Treffer), später entdeckter Sektor-31-Meteoritenforschung, **3 Meteoritenproben und 950 Credits**. Dieser Labor-Questteil ist noch nicht spielbar, daher sind Sci-Fi-Modelle derzeit bewusst gesperrt. **M**, danach **Z**, fordert die Forschung an und gibt bei fehlenden Voraussetzungen einen Hinweis.
- Visuelle Modelle unter `/Game/AAA/Geometry/Props/SM_Nexus_...` werden nur angezeigt, wenn V5-GLBs im Editor importiert sind. Alternierende Ansichten mit **V**; spätere Animation, Treffer-VFX, Sounds und vollwertige Gegner-KI benötigen gesonderte Assets und QA.

## V5 – 28 neue 3D-Meshes (separates ZIP)
Das separate ZIP `NEXUS_V5_28_3D_MODELLE_GEBAEUDE_FAHRZEUGE_PANZER_WAFFEN.zip` enthält 8 Gebäude, 13 Fahrzeuge (3 Helikopter, 2 Panzer), 6 Waffentypen und ein Trainingsziel. In den Repository-Stammordner entpacken und dann im Unreal Editor `Scripts/import_nexus_v5_assets.py` ausführen. Dabei werden bestehende Assets **nicht überschrieben**, Importprüfsummen kontrolliert und `NEXUS_V5_EDITOR_IMPORT_REPORT.json` geschrieben. Die Panzer werden nicht auf der Erstkarte gespawnt. Alles sind noch geometrisch detaillierte **Prototypen**, keine finale AAA-Grafik.

## V6 – echte Laufzeitbewegungen + neue PBR-Assets
- `ANexusVehicle` kann nach Import des Zusatzpakets `NEXUS_V6_PBR_ANIMATIONEN.zip` **getrennte Helikopter-Rotoren** mit eigener Drehung und bei 8 Straßenfahrzeugtypen **vier getrennte, drehende Räder** anzeigen. Animiert werden UScene-/UStaticMeshComponents in Tick. Wenn MotionBody-Dateien fehlen, bleibt die bisherige V5-Standgrafik, statt den Rotor über alte Rotorblätter zu legen. Keine Chaos Vehicle-Suspension oder Rotor-Flugdynamik wird behauptet.
- `ANexusExplorer` erhält prototypischen lokalen Waffenrückstoß und eine Nachladebewegung; vollständige bewaffnete Körper-/Fingeranimationen brauchen Skelette und ein Animation Blueprint. Für fertige humanoide Animationen sind offizielle Fab-Unreal-Pakete und Adobe Mixamo aufgeführt.
- 14 **zusätzliche** eigenständige prozedurale PBR-Materialfamilien mit je sechs Maps liegen als 1K- oder 2K-Paket vor. Die alten 18 Materialfamilien werden nicht überschrieben. Erst mit `Scripts/import_nexus_v6_pbr.py` entstehen passende Unreal-Material-Assets. Ohne UV/WorldAligned-Abgleich und echtes Test-Rendering ist nicht nachgewiesen, dass alle Meshes perfekt texturiert sind.

**V6 PBR/Animationen:** Siehe `Docs/NEXUS_V6_PBR_ANIMATIONEN.md`. 14 zusätzliche original prozedurale Materialsets (84 Karten) sowie 14 Motion-GLBs (11 Fahrzeug-Rümpfe ohne starre Bewegungsteile plus 3 Teile). Im Unreal Editor `Scripts/import_nexus_v6_pbr.py` und `Scripts/import_nexus_v6_motion.py` ausführen. Fertige humanoide Animationen aus Fab/Mixamo benötigen einen eigenen Download im jeweiligen Account, retargeting und Skeleton-Rigs. Noch kein bestätigter UE5-Build.
