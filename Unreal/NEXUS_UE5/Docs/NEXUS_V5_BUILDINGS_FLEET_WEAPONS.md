# NEXUS V5: 28 baubare 3D-Quellmodelle und Spieleinbindung

**Stand:** 28 originale GLB-Prototypen als separate Chat-ZIP erstellt und integrity-geprüft. Dieses GitHub-Repository enthält das verifizierbare Import-Register und das **nicht-destruktive UE5-Editor-Importskript**, nicht die binären .uasset-Dateien. Die 28 Dateien dürfen nur dann als tatsächlich im Spiel importiert gelten, wenn der Unreal-Editor-Importbericht erfolgreich ist.

## Paketinhalt
8 eigenständige Gebäudequellen: Supermarkt, Polizeistation, Feuerwehr, Airport-Terminal, Altstadthalle, Alpenvilla, Goldmineneingang, Forschungslabor. Dazu 13 Fahrzeuge: 8 Straßen-/Einsatztypen, 3 Helikopter, 2 Panzer; 6 Waffenmodelle (4 normal + 2 Sci-Fi) und 1 Trainingsziel.

**Die 3D-Objekte sind noch keine Fotorealismus-Assets:** vielteilige Geometrie, sichtbare Türen/Fenster, Reifen, Scheinwerfer, Rotoren, etc.; aber bislang Vertexfarben statt authored 4K PBR, ohne Rigging, Gewichts-/Federungsphysik und ohne echte UE5-Renderaufnahmen. Hochwertige Fassaden, Landschaft und Animationen sind ein folgender Art-Pass.

## Installationsweg
1. Das Paket `NEXUS_V5_28_3D_MODELLE_GEBAEUDE_FAHRZEUGE_PANZER_WAFFEN.zip` im **Stammverzeichnis** des GitHub-Repositorys `Nexus-project` entpacken. Damit entstehen Dateien in `Unreal/NEXUS_UE5/Content/SourceArt/NexusImports/<category>/`.
2. UE5.8 `Unreal/NEXUS_UE5/NEXUS.uproject` öffnen; Unreal C++-Code kompilieren; Python Editor Script Plugin aktivieren.
3. Unter Tools → Execute Python Script `Unreal/NEXUS_UE5/Scripts/import_nexus_v5_assets.py` ausführen.
4. Importbericht unter `Content/SourceArt/NexusImports/NEXUS_V5_EDITOR_IMPORT_REPORT.json` lesen. Falls Interchange eine andere Package-Benennung generiert, referenzierten Mesh-Pfad angleichen.
5. Gebäude-Kollisionen sorgfältig prüfen: **keine Voll-Box-Kollision über den gesamten Baukörper**, sonst sind die Türen nicht tatsächlich begehbar. Fenster, Dach, Raumhöhen, Geometrieskalierung und NPC-Navigation testen.
6. Fahrzeug-Kamera und E-Possession, Rettungshelikopter-Scheinwerfer, Schießstand, Magazin-/Nachladesystem mit 4 Spielern prüfen.
7. Historische Panzer nur auf dem späteren **separaten 1945-Planeten**, niemals als Ersatz für das verworfene sechste Referenzbild auf der ersten Karte platzieren.

## Normale Waffen zuerst
Vier Waffen der fiktiven Spielwelt stehen am Anfang zur Verfügung. Mit Q durchwechseln, R nachladen, Mausklick nur auf das Schießstandziel als Prototyp. Die Sci-Fi-Varianten sind erst nach Training, Meteoriten-Forschung, 3 gefundenen Erzproben und Kosten freischaltbar. Die nötigen Forschungsquests sind noch nicht vollständig integriert.

## Qualitätsabnahme
Die statische Python/C++-Quellprüfung ist **keine Unreal-Kompilierung**. Keine 1:1-Vergleichsbehauptung zum Referenzbild ohne echte Engine-Aufnahme auf geeigneter Hardware.
