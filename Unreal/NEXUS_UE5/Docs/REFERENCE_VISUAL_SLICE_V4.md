# NEXUS – Referenzbild-Visual-Slice (V4, Code)

## Konkrete Vorlage
Das vom Nutzer übermittelte Adlerklamm-Bild ist die **Art-Direction**: österreichische Alpen mit dichten Nadelwäldern, dunklen Wolken, einem Reisebus im Absturz von der beschädigten Brücke, Helikopter-Bergung, Blaulicht, urbanem Hintergrund, detaillierter FP-Waffe und seitlichem HUD. Das Bild **ist keine Aufnahme des tatsächlichen Spiels**.

## Implementiert (Quellcode, UE5-Editor-Build noch nicht geprüft)
- Cinematic runtime atmosphere + unbound post-processing: Kontrast, Entsättigung und Vignette werden an den tatsächlichen Unwetterzustand gebunden. Ersetzt weder fotogrammetrische Modelle noch artistische Beleuchtung.
- Filmischeres 1600×900-HUD, mit responsiver Skalierung: Mission oben links, echte dynamische Rettungsziele, kontextbasierte Rollenwahl, Warenlager oben rechts, Weltkoordinaten-Bridge-Radar unten links, Wiederaufbau rechts, aktive Quickbar unten. **Keine simulierte Munitionsanzeige**, solange es keine entsprechende Mechanik gibt.
- Kamera mit Taste **V**: Ego-/Third-Person am Spieler, Cockpit-/Verfolgerkamera in Fahrzeugen und Helikopter. Eigene Kameraeinstellung pro Pawn, nicht netzwerkweit erzwungen. Eine echte Fullbody-Mesh und Cockpit-Interieur müssen noch importiert werden.
- Rettungsfahrzeuge haben alternierende dynamische rote und blaue Leuchten. Realistische Rettungsfahrzeug-Meshes/Materialien müssen separat existieren.

## Für fotorealistischen UE5-Abgleich noch erforderlich
1. UE5.8-Projekt auf Rechner mit kompatibler GPU starten und C++-Kompilierung prüfen.
2. Hochwertige PBR/Nanite-Landschaft, korrekt dimensionierte Brücke (inklusive Chaos Geometry Collections), High-Poly-Bus/Helikopter sowie Feuerwehrfahrzeuge aus der projektweiten Asset-Pipeline **wirklich importieren**.
3. Echter Fichtenwald mit PCG, Volumetric Clouds, echtes Niagara-Regen-/Staub-/Trümmersystem, Wildwasser-Schaum, Reflexionen und Blickwinkel-Komposition.
4. UMG mit echten Icons, interaktiver Minimap, Metahuman/Charakter-Animationen und Waffeninventar als nächster Schritt.
5. Aufnahme aus laufender Engine anstelle eines KI-Konzeptbilds erstellen; Renderqualität mit dem Referenzbild vergleichen. Das Aussehen **1:1** ist derzeit **nicht** erreicht. Keine vorgetäuschte GPU- oder Gameplay-Verifikation.

## Quick check
`python -m unittest discover -s Unreal/NEXUS_UE5/Scripts -p "test_*.py"`

Unreal-Engine-Version und ausgewählte Render-Einstellungen: siehe `Config/DefaultEngine.ini`.
