# PROJECT NEXUS V1.4 — verifizierbare Implementierung und Grenzen

## Spielbare Basis / Quellcode
- Die bestehenden V1.3-Funktionen bleiben erhalten: Godot-Alpenkarte, sieben Startfahrzeuge, Fahrzeughalle mit **123 Datenprofilen** (keine 123 fotorealistischen 3D-Unikate), Bauen, Warenkreislauf, Bergrettungs-Prolog, sechs prototypische Planeten, Sternenkarte und Kampfsystem-Grundlagen.
- Neu: **Living Universe** mit sechs Regionen, sechs datengetriebenen Weltvorfällen, Rufsystem für vier Fraktionen, regionaler Stabilität/Versorgung, Einsatzentscheidungen und persistenter Chronik.
- Neu: sichtbare **Einsatzleitung**, aufrufbar über `F8` oder Schaltfläche. Ein Einsatz hat zwei verschiedene finanziell gewichtete Antworten. Unbezahlbare Entscheidungen werden abgewiesen; die Situation bleibt offen.
- Neu: visuelles Set-Dressing mit Straßenschildern, Fahrbahnmarkierungen, Planken, Strommasten, Industrie-Containern, Fensterdetails, Wasserfall, Waldgeröll und Blaulicht-Effekten. `F4` wechselt zwischen **CINEMATIC** und **PERFORMANCE**.
- Neu: leichter lokaler Regen-/Schneefall mit CPU-Partikeln und dynamisch auf Nacht/Wetter reagierenden Himmelsfarben.

## Nachweis
`python tests/validate_project.py && python tests/validate_fleet.py && python tests/validate_v14.py` prüft nur statische Struktur. Für einen tatsächlichen Engine-Test muss GitHub Actions `godot-check.yml` inklusive `living_smoke.gd`, `visual_smoke.gd` und bisherigen Smoke-Tests grün abschließen. Weitere manuelle Grafik- und Mehrspieler-Tests sind erforderlich.

## Noch nicht fertig / nicht behaupten
- **Kein Fotorealismus wie GTA 6 oder COD.** Die Assets sind überwiegend vereinfachte prozedurale Primitive; fotogrammetrische Modelle, LOD, hochwertige Charaktere, Rigging und Animationen fehlen.
- **Keine 48 Stunden fertig spielbare Story**, nur Design und kurze Missionen.
- **Kein produktionsreifes 4-Spieler-Koop**, bestehende LAN-Demo bleibt experimentell.
- **Keine volle Fahrzeugphysik, realistische Waffenbalistik, Zerstörung, Tiergenetik, Echtzeit-Wirtschaft, riesige planetare Simulation**. Das Living-Universe-System ist eine skalierbare, begrenzte Ereignissimulation.
- **Keine iPhone-App**. Quellcode kann per iPhone/GitHub entwickelt werden; Rendering braucht ein geeignetes Gerät oder Testsystem.

## Priorisierte nächste vertikale Scheibe
1. Ein 500 x 500 m dichtes Alpengelände als hochwertiges Level aus lizenzierten PBR- und 3D-Assets, LOD und glaubwürdiger Fahrbahn.
2. Eine echte Bergrettungsmission mit Suchlogik, Rettungshelikopter und Animationszuständen; vom Start bis zur Auswertung durchspielbar.
3. Ein taktischer Sektor-31-Einsatz mit Navigation/Deckung, Gegner-KI, Missionsentscheidung und persistenten Konsequenzen.
4. Stabiler iPhone-Browser-Test nur mit geeignetem Godot-Kompatibilitätsrenderer, optimierter Web-Ausgabe und nachgewiesenem Geräte-Test.
5. Mehrspieler erst nach autoritativem Servermodell, Replikation und Netzwerktests.
