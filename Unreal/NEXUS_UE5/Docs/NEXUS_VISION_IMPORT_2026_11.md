# NEXUS – vollständige Übernahme der Spielwünsche (02.11.2026)

Der Datensatz `Content/Data/nexus_user_vision_2026_11.json` enthält 44 getrennte Spiel-Features und 53 **vorgesehene, nicht automatisch existierende** Asset-Slots. Die Quellen stehen in der Konversation. Die Anforderungen gelten als **verbindlicher Entwurf**, nicht als bereits gebaute oder geprüfte Spielwelt.

## Verbindliche Weltregel
Alle fünf zuerst ausgewählten Bildregionen sind Teil **derselben** Erd-Open-World: Sektor 31, Bergrettung, Burgen-/Bergstadt, moderne Stadt, beschädigte sich wiederaufbauende Stadt. Das sechste Bild (gepanzertes Kriegsfahrzeug/Soldaten) gehört NICHT zur ersten Karte. Die separat erreichbare 1945-Kriegswelt gehört zur fiktiven Science-Fiction-Zeitreisegeschichte.

## Spielstart und Gameplay
Dein eigenes vollständig betretbares Haus mit Garage und Büro/Pinnwand; anfänglich nur kurze Einführungsaufträge, später ausschließlich **selbst entdeckte** Aufgaben. Militärübungen maximal ca. 15–20 Min. vor Zombies. Danach freie Tätigkeit in der lebendigen Welt; zwischen Ego-/Third-Person überall umschalten, beim Bauen frei drehen. Aufträge auch per Smartphone verwalten. Supermarkt/Läden/Werkstätten, Handel/Banking, Goldmine, weitere Minen, Steinbruch für Brückenbeton, Sägewerk, Ölplattform mitten im Meer mit betretbaren Innenräumen, Raffinerie, Baustellen, Flughäfen, Flugzeuge/Helikopter, jagdbare Tiere. Grundstücke kaufen/bauen/vermieten, Einnahmen auch auf anderen Planeten (mit laufenden Kosten). Baustoffpreise und Nebenquests sind real und spielwirksam, keine Gratis-Erfindung ohne Ressourcenkette.

## Geschichte und Welten
Alien-Meteoritenmaterial lässt Sektor 31 im isolierten Militärlabor infizieren: Zombies durchbrechen Quarantäne; Forschung führt zu Raumfahrt. Rakete aus 3–5 großen craftbaren Modulen, kann bei Fehlern scheitern, 3–4 Min. Schiffscockpit-Flug. Unterschiedliche Städte/Höhlen/Klima und benötigte selbstgebaute Druck-/Kälte-/Hitze-Schutzanzüge je Planet. Gesamter Lavaplanet dunkel, organisch, rot und bedrohlich (eigene künstlerische Umsetzung, keine kopierten Markenassets). Verlassene Menschenlabore; verschwundene Forscher leben uralt auf geheimem Planeten; Familien-Rückkehr, fiktiver Anti-Aging-Durchbruch, Konzerne, Regierungs-Korruption und Konsequenzen bis zum Staatsoberhaupt. Verzweigte Kriminalitäts-/Schwarzmarktkarriere und historische 1945-Kriegswelt als separate Story. Crew/Verbündete sowie NPC-Erinnerungen reisen planetenübergreifend. Erdbeben und Regenhochwasser wirken auf Stadt/Karriere. Bis 4 Freunde; 48h Story und 500h Langzeitspielbarkeit sind **Ziele**.

## Asset-Import-Status
**Noch nicht importiert:** nur weil ein Pfad im JSON existiert, existiert kein echtes 3D-Modell. Wir übernehmen die Zuordnung, prüfen verfügbare Quelldateien im lokalen `Content/SourceArt/NexusImports` und importieren sie ausschließlich **im UE5-Editor** mit `Scripts/import_nexus_full_vision.py`. Für Niagara-/UMG-`.uasset`-Pakete wird keine Fake-Konvertierung behauptet. Quellrechte vor kommerzieller Verwendung prüfen. Das Skript ist absichtlich nicht-destruktiv.

## Qualität und Abnahme
UE5 C++-Build auf einer geeigneten GPU, echte Gameplay-/Render-Aufnahmen, Figuren und Innenräume, Level-Streaming, Netzwerk- und Persistenztest, Performanceprofil. Für Intel-UHD-620-Klassenrechner ist der AAA-Fotorealismus nicht nachgewiesen. Kein Screenshot aus dem KI-Konzept wird als tatsächliches Game ausgegeben.

## Reale Bibliotheksassets – Paket am 02.11.2026 erstellt
Sechs bereits vorhandene NEXUS-Library-ZIPs wurden in ein geprüftes, nicht-destruktives SourceArt-Importpaket vereinigt: **4** selbst erzeugte Bus-/Brücke-/Feuerwehr-/Hubschrauber-GLB-Prototypen, **9** Geländevorschaukacheln, **5** Fichten/Sträucher/Fels-GLBs, **1** echter Poly-Haven-CC0-Felsscan (mit Provenienz), **72** Bildkarten für 18 Materialfamilien und eine 2017×2017 16-bit Adlerklamm-Heightmap samt Masken. Das Importpaket enthält eine sichere PowerShell-Kopierhilfe und die Ausführungsreihenfolge der vorhandenen UE5-Editor-Skripte.

**Wichtig:** Das Chat-Downloadpaket ist nicht als .uasset oder .umap in GitHub importiert worden, da UE5 nur im Editor die Originalfiles in Engine-Assets umwandelt. Quellarchive sind keine AAA-Modelle; Hero-GLBs sind reproduzierbare Prototypen. Weitere Wunsch-Features mit 53 vorgesehenen Slots sind nicht durch die sechs ZIPs automatisch erfüllt.
