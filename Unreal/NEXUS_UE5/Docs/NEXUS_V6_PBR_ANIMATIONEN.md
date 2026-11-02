# NEXUS V6 – PBR-Grafik und fertige Bewegungen

## Geliefert
- **14 zusätzliche Materialfamilien** (PaintRed/Blue/White/Olive/Black, BrushedSteel, OxidizedSteel, TireRubber, BlueGlass, ConcreteModern, WeatheredBrick, AlpineWood, AsphaltWet, AlienCeramic). Je **6** PNG-Maps: Albedo, DirectX-Normal, Roughness, Metallic, Ambient Occlusion, Height. Zwei entpackbare Pakete: 1K für geringere GPU-RAM-Anforderungen, 2K für den stärkeren Rechner. Es sind prozedurale Originalmaterialien, **keine** fotogescannten Texturen.
- **14 bewegliche 3D-Quellen:** acht Straßenfahrzeug-Karosserien OHNE fest angebrachte Räder, drei Helikopter-Rümpfe OHNE statische Hauptrotorblätter und drei getrennte bewegliche Parts (Rad, vierblättriger und fünfblättriger Rotor). Der C++-Code `ANexusVehicle` animiert die beweglichen Komponenten auf allen Clients in Echtzeit, sobald die V6-Meshes vorhanden sind. Ohne Import bleibt der alte V5-Prototyp erhalten.
- Lokaler Waffenrückstoß und eine einfache Nachladeabsenkung: transformbasierte Prototyp-Animationen, keine Motion-Capture- oder Hand-/Körper-Animationen.

## Einrichtung
1. Die gewünschte **eine** PBR-Variante und das `NEXUS_V6_MOTION_GEOMETRIE.zip` in den Projektordner kopieren/entpacken, sodass die Dateien unter `Unreal/NEXUS_UE5/Content/SourceArt/PBR_V6` und `.../NexusV6Motion` liegen.
2. Im Unreal Editor das Python Editor Script Plugin aktivieren und nacheinander ausführen: `Scripts/import_nexus_v6_pbr.py` und `Scripts/import_nexus_v6_motion.py`.
3. Die PBR-Materialien bei UV-gemappten Asset-Materialslots explizit zuweisen und Skalierung, Normalrichtung, Performance/Lumen prüfen. V5-Meshes haben **keine UV-Koordinaten**, daher kann die Textur nicht ohne UV-Unwrap/WorldAligned-Material sichtbar korrekt auf der alten GLB-Oberfläche liegen.
4. Animierte Rotoren/Räder im PIE mit `V` Ego/Third-Person prüfen. Achtung: Standard-Fahrphysik ist immer noch Arcade und noch kein Chaos-Vehicle-Rig.
5. **Humanoide fertige Animationen** zusätzlich in *deinem eigenen* Epic/Fab oder Adobe/Mixamo-Account beziehen, in Unreal auf Manny/Quinn oder eigene Skelette retargeten und mit Animation Blueprint abspielen. Wir haben keine lizenzgeschützten fremden Animationsdateien ohne Zustimmung in das ZIP aufgenommen.

## Externe Vorlagen (Lizenzen beachten)
- CC0 original photogrammetry textures & HDRI: https://polyhaven.com/textures ; https://polyhaven.com/license
- ambientCG CC0: https://ambientcg.com
- UE-Only **Animation Starter Pack (62)**: https://www.fab.com/listings/98ff449d-79db-4f54-9303-75486c4fb9d9
- UE5 Manny/Quinn free **Free Animation Pack (24)**: https://www.fab.com/listings/8de31c5d-93bc-4bd4-9606-ca789ce91b99
- UE5 free **Basic Walk Cycle Animation Pack**, auch Zombie Walk: https://www.fab.com/listings/39fc275c-2dbf-4d3e-a934-b64b4be012e8
- https://www.mixamo.com/ – kostenlos mit Adobe-ID, freie Verwendung in Spielen, Humanoiden-Rigging (keine Fahrzeug-/Tier-Rigs): https://helpx.adobe.com/creative-cloud/faq/mixamo-faq.html
- Optionaler CC0-Downloader für **drei offizielle Poly-Haven-Quellen**: `Scripts/download_nexus_cc0_materials.py` (nur vom Nutzer auf einem PC mit Internet auszuführen; Downloader erstellt nachvollziehbare Provenienzen).

## Was folgt in NEXUS als nächstes?
1. **Asset QA** mit durchgängigen UVs, texturierter Hero-Brücke, PBR-Fahrzeugen und realen Bildvergleichen, optional PCG-Wald.
2. **Vollwertige Rigging-/Animationsklasse** für Einwohner, Rettungsteams, Soldaten und Zombies (gehen, laufen, klettern, winden, retten).
3. **Wirklich begehbare Interiors**, NPC-Öffnungszeiten, Shops, Tage-/Nachtrhythmus und Immobilienverwaltung.
4. **Dynamische zerstörbare Brücke/Stadt, Unwetter und Überschwemmungen** mit spielbaren Einsatzaufträgen.
5. **Wirtschaftliche Warenketten und Industrie-NPCs**, Goldminenstollen, Offshore-Plattform, Zeit-/Kostenmanagement.
6. **Planetenreise-Module**, Raumanzüge, gekapselte Sci-Fi-Forschung, Story-Entscheidungen und Crew-System.

**Status:** GitHub Actions prüft Python- und C++-Quellvertragsregeln. Ohne installierte UE5-Toolchain/GPU wurde das Produkt nicht echt im Unreal Editor kompiliert oder als fotorealistisches Gameplay gerendert.
