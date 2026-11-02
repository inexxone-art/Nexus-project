# PROJECT NEXUS — AAA-WELTENBAUPLAN (UE5.8)
**Arbeitsstand:** 2026-11-02 · **Budget:** 0 € Zusatzkosten · **Autorität:** die NEXUS-Projektwünsche und Story-PDFs als Produktziel, der aktuelle Repository-Code als Implementierungsnachweis.

> **Verbindliche Abgrenzung:** Dies ist der vollständige, technisch umsetzbare **Bauplan**, keine Behauptung, dass die Welten und Gebäude bereits fotorealistisch gerendert oder alle 18 Kapitel spielbar sind. Auf dem GitHub-Branch existieren bisher eine C++-Vertikalschnitt-Basis, Datenprofile, importierbare Originalmodelle, PBR-Pipeline und Offline-Tests. UE5.8 wurde in dieser Umgebung noch **nicht kompiliert oder im GPU-Editor ausgeführt**. Kein Cloud-Dienst wird ohne ausdrückliche Freigabe bezahlt.

## 1. Unveränderliches Produktziel

**PROJECT NEXUS** soll ein zusammenhängendes, filmisch wirkendes Open-World-Spiel werden: begehbare Städte und Häuser, Berglandschaften, realistische Industrie, zerstörbare Brücken, Fahrzeuge, Rettungseinsätze, Gegner, Helfer, Rohstoffketten, bis zu vier Freunde, Reisen ins Sonnensystem und sechs weitere Welten. Die Missionen reagieren auf Entscheidungen, Zerstörung und Reparaturen. Die angestrebte **48-Stunden-Hauptkampagne** besteht laut vorhandener Storystruktur aus 18 Kapiteln mit je sieben Phasen (126 Missionsphasen). Das ist ein **Inhalts- und Spielzeitziel**, kein derzeit gemessener Wert.

**Bildregie Adlerklamm:** Perspektive der bisherigen Bus-/Brücken-Referenz halten; aber keine Waffenansicht festschreiben: Ausrüstung ist wechselbar. Sichtbar sind strukturierter, nasser Alpenfels; dichte Misch- und Nadelwälder; eine echte tief eingeschnittene, mäandrierende Klamm; Wildwasser mit Schaum; eine tragende Beton-/Stahlbrücke; ein hochwertiger Reisebus in Bewegung; Polizei/Feuerwehr/Sanitäter; Hubschrauber; belebte Häuser und Industrie dahinter. Keine erfundenen Gameplay-Screenshots als Fortschrittsbeweis.

### Visuelle Abnahmeregeln
| Element | Mindestanspruch für die spätere Abnahme |
|---|---|
| Landschaft | Höhenverlauf, Erosion, sichtbare Stratifikation, Schutt, Bodenmaterialien, keine erkennbaren Box-Blöcke |
| Gebäude | echte Fassadentiefe, Fenster-/Türrahmen, Dachränder, Materialalterung, sichtbare Innenräume bei betretbaren Gebäuden |
| Vegetation | mehrere Baumarten und Altersstufen, Wind, Bodenschicht, Stein-/Moosverteilung, keine Kegelbäume |
| Wasser | Ufer/Sediment/Strömung, Unterwasserzustand, Spiegelung/Brechung, Schaum und lokale Partikel |
| Fahrzeuge | Hero-Meshes mit Rädern, Glas, Innenraum, Licht, Schaden, Sound und glaubwürdiger Bewegung |
| Licht | nachvollziehbarer Sonnenstand, dynamisches Wetter, Gebäude-Innenlicht, maßvolle volumetrische Effekte |
| Zerstörung | Fragmente mit Innenmaterial/Armierung, zeitliche Ursache/Wirkung, reproduzierbare Physik und Persistenz |
| Nachweis | echte Unreal-Editor-Aufnahmen, reproduzierbare Tests, GPU-Frametime/FPS/VRAM; erst dann das Wort „fotorealistisch“ als Ergebnis |

## 2. Kartenhierarchie, Maßstäbe und Streaming

**UE-Grundstruktur:** ein Game Instance State + pro Zielregion eine World-Partition-Karte; keine riesige monolithische Karte. Datenebenen (Data Layers) für Tageszeit/Ereignis/Abbruch/Neubau, HLOD für Entfernung, PCG für Vegetation und Kleindetails, Nanite für geeignete statische Nanite-Meshes, Lumen und Virtual Shadow Maps nur im Qualitätsprofil, für das die GPU reicht. Weltkoordinaten und World-Origin-Rebasing bzw. Large World Coordinates bei großen Distanzen beachten.

| Karte / Level | Zielbereich | Konkrete Inhalte | Status |
|---|---|---|---|
| L_Adlerklamm_VerticalSlice | zunächst ca. 2 × 2 km | Brücke, Unfall, Rettungsrallye, Fluss, Fels, Industrie-Zufahrt | C++-Blockout und vorbereitete Daten; UE-Grafiktest offen |
| L_Terra_Alpenland | später zusammenhängende Streaming-Region (Ziel ca. 16 × 16 km, anpassbar) | Bergstadt, Wälder, Straßen, Höfe, Bahn, Kraftwerk, Staudamm | geplant |
| L_Terra_Stahlhafen | eigenes Streaming-Gebiet | Hafen, Lager, Hochhäuser, Kanal, Raffinerie, Werften | geplant |
| L_Terra_Silberkueste | eigenes Gebiet | Küstenstadt, Flugfeld, Meer, Frachtumschlag | geplant |
| L_OrbitalHub | Raumsektor / Stationslevel | Hangars, Raumfahrzeug, Missionstransfer | geplant |
| L_Planet_<ID> | je begehbarem Landekorridor | eigenes Biom, Kolonie, Rohstoffe, Gegner/Missionen | nur Profile angelegt |
| L_SolarSystem_Map | strategische Darstellung / Reise | Sonne, acht Planeten, Monde, Stationen, Flugrouten | geplant |

**Entscheidung zur Planetengeometrie:** keine acht komplett auf der Oberfläche begehbaren 1:1-Kugeln versprechen. Stattdessen Orbit-/Reisekarte plus hochauflösende **lokale Landegebiete**, die pro Planet mit World Partition streamen. Gasriesen erhalten Atmosphären-/Orbit-/Fluglevel, **keine erfundene feste Landfläche**.

### Adlerklamm – verbindliche räumliche Aufteilung
Die Brücke führt **West–Ost**; der mäandrierende Fluss fließt **Süd–Nord quer darunter**. Die gescannte Fels-/Felsbrockenbibliothek wird über Böschung und Schluchtwände verteilt. Seitenerosion am Prallhang, Sedimentation/Gleithang und schwimmbare Wasserkolonne gehören zusammen. Nördlicher Ausgang führt zur Bergstadt; westliche Zufahrt hat Rettungswagensammelpunkt; östlicher Brückenkopf verbindet Feuerwehrstützpunkt, Krankenhaus und Industrie. Ölplattform nur an sinnvoll gelegenem Gewässer/Küste, nicht unrealistisch mitten im steilen Flussbett.

**Adlerklamm-Sektoren:** (A) westliche Waldstraße/Fahrzeugstart, (B) Brücke 82 m und Bruchsegmente, (C) Fluss & Kiesbank, (D) Hangrutsch/Forststraße, (E) Rettungsbasis mit Heli-Landeplatz, (F) Siedlung mit 20–40 individuell variierten Gebäudekörpern als Ausbauziel, (G) Steinbruch/Zementanlage, (H) Stahl-/Holzbearbeitung, (I) Krankenhaus/Feuerwehr, (J) Fernsicht Bergstadt/industrielle Skyline. Auf dem ersten passierenden Slice nicht alle Häuser vollständig möblieren: **5 betretbare, hochwertige Mustergebäude** entwickeln und daraus eine modulare Stadtbibliothek erweitern.

## 3. Häuser- und Architekturproduktionsstandard

**Kein Haus ist nur ein farbiger Würfel.** Bau jedes sichtbaren Hauses aus einem modularen, metrischen Kit: Fundamente/Sockel; 0,5-/1-/2-/4-m Wände; Eckmodule; Fassadenplatten; Fenster mit Tiefenrahmen und Glas; Türen und Beschläge; Dachkonstruktionen/Dachrinnen; Balkone; Schornsteine/Rohre; Treppen/Geländer; Innenböden/Decken; belegte Möbel; Elektro-/Wasser-/Heiztechnik; äußere Gebrauchsspuren. Fassade durch Materials/Decals mehrschichtig variieren; Fenster bekommen glaubwürdige Innenreflexion, wenn kein echter Innenraum sichtbar ist.

### Geplanter wiederverwendbarer Gebäudekatalog

| ID | Architekturtyp | Pflichtdetails | Innenraum / Interaktion |
|---|---|---|---|
| B01 | Alpenhof / Bauernhaus | Naturstein, dunkles Holz, Satteldach, Stall, Werkzeughof | Küche, Stube, Stall, Holzlager |
| B02 | Berghütte / Gasthaus | Holzschindeln, Terrasse, Schneefang, Rauchfang | Gastraum, Küche, Lager, Gästezimmer |
| B03 | Reihen-/Einfamilienhaus | Putz, Fensterlaibung, Rolläden, Garage, Dachkante | 2–4 Musterzimmer, Türen, Möbel |
| B04 | Mehrfamilienhaus | auskragende Balkone, Treppenhaus, Briefkästen, Haustechnik | Lobby, Stiegen, 1–2 Wohnungen |
| B05 | Luxusvilla | Naturstein/Glas, Terrassen, Stahlstützen, Pooltechnik | Wohnräume, Treppe, Garage |
| B06 | Stadtbüro / Hochhaus | individuelle Fassadenraster, Lobby, Dachgeräte, Notausgang | Lobby, Büroetage, Treppenhaus |
| B07 | Geschäft / Supermarkt | Ladenfront, Beschriftung, Regal-/Schaufenster, Rampen | begehbares Erdgeschoss, Lager |
| B08 | Krankenhaus | Notaufnahme, Zufahrt, medizinische Geräte, Patiententransport | Notaufnahme, OP-/Stations-Prototyp |
| B09 | Feuerwehr-/Polizeistation | Rolltore, Leitstelle, Fahrzeughallen, Signalleuchten | Einsatzhalle, Funkraum |
| B10 | Bahnhof / Verkehrsknoten | Gleise, Bahnsteig, Fahrkartenhalle, Oberleitung | Halle, Werkstatt, Signalanlage |
| B11 | Schule / Gemeindeamt | Eingang, Schilder, Flure, Treppen, Beleuchtung | Foyer, Büroraum |
| B12 | Lager-/Logistikhalle | Stahlträger, Sandwichpaneele, Tore, Container, Kräne | Warenfluss, Be-/Entladung |
| B13 | Sägewerk / Holzverarbeitung | Stammzufuhr, Sägeband, Förderer, Holzstapel, Späne | echte Produktionsschritte |
| B14 | Schmelzofen / Stahlwerk | Hochofen, Schlacke, Abstich, Krane, Leitungen | Eisen aus Erz, Verarbeitung |
| B15 | Zementwerk / Steinbruch | Kalk/Schotter, Drehrohrofen, Silos, Abgase | Rohstoff→Zement-Kette |
| B16 | Raffinerie / Offshore-Anlage | Ölpumpen, Plattform, Rohre, Lagertanks, Flare-System | Rohöl→Bitumen/Diesel |
| B17 | Asphaltmischanlage / Straßenbau | Brecher, Mischer, Silos, Walze, Belagsschichten | Kies+Bitumen→Asphalt |
| B18 | Staudamm / Kraftwerk | Turbinenhalle, Schleusen, Kabelkanal, Brückenkontrolle | Strom/Schaden/Flut-Simulation |
| B19 | Planetare Forschungsbasis | Schleusen, Luftfilter, Druckzonen, Solarmodule | Labor, Schlafmodul, Kontrollraum |
| B20 | Orbitale Raumstation | modulare Ringe, Dock, Hangar, Drucktüren | Kontrollraum, Dock, Habitat |
| B21 | Lavastation | wärmeisolierte Fassade, Basaltschirm, Kühlkanäle | Energieanlage, Schutzraum |
| B22 | Eisstation | Doppelhülle, Frostkanten, Heizsystem, Schleusen | Untergrundlabore, Versorgung |
| B23 | Wüstenstadt / Wasserwerk | Verschattung, Sandabdichtung, große Speicher | Pumpen, Aufbereitung, Wohnen |
| B24 | Fremde Architektur | nichtmenschliche Proportion, eigene Materiallogik, Lichtcodes | Rätsel, Durchgänge, Archive |

Für jedes Kit: Maßstab/Collision-Layer, sichtbare Innen-/Außenansichten, LOD-/Nanite-Policy, UV-Koordinaten/Materialslots, Dachwassersystem, Fensterspiegelungen, Sound-Oberflächen, Schaden pro Element, technische Türen/Fenster, Fire/Rescue-Navigation. Variantensystem durch **Seed, Fassadenpalette, Fensteranordnung, Dachmodul und Alterung** – nicht bloß wechselnde Fassadenfarbe.

**Zerstörungskonzept:** Fassade und Inventar als getrennte Schichten; teilweise zerstörbares Gebäude erhält Chaos-Geometry-Collection nur auf relevanten Bauteilen, nicht jedes physikalische Ziegelchen gleichzeitig. Evakuierung, Brand-/Rauchpfad, Netz-/Strom-/Wasserverlust, Reparatur und SaveGame müssen synchron sein. Keine unendlichen unkontrollierten Debris-Simulationen für einen 4-Spieler-Server.

## 4. Sonnensystem: acht echte Planeten

| Planet | Physikalischer/visueller Ansatz | Bauwerke | Spielerische Tätigkeit |
|---|---|---|---|
| Merkur | Krater, zerklüfteter Regolith, harte Schatten, extreme Sonnen-/Temperaturzonen | abgedeckte Mine, mobile Solarfarm, hermetische Basis | Erzabbau, Hitzeschutz, Sonnenseiten-Timer |
| Venus | dichte, undurchsichtige Atmosphäre, extreme Hitze/Druck, Korrosion | hochgeschützte Forschungsstation, obere Wolkenplattform | Messdrohnen, Druck-/Kühlmanagement |
| Erde | Wälder, echte Städte, Meer, Flüsse, Wetter, Leben | 24 Gebäude-Kits und vorhandene Regionen | Story, Bergungen, Wirtschaft, Verkehr |
| Mars | eisenoxidreicher Staub, Canyons, dünne Atmosphäre, Staubstürme | Druckkuppeln, Bergbaustationen, Gewächshäuser | Rover, Energie, Koloniebau |
| Jupiter | **Gasriese ohne feste Oberfläche**; Turbulenz, Wolkenschichten, Blitz und Orbit | Orbitalhub, Hochatmosphären-Sonden | Atmosphärenflug, Stationsreparaturen |
| Saturn | **Gasriese**, Ringe, Partikelfeld, Monde | Ringstation, Titan-/Enceladus-Expedition | Navigation, Eis-/Hydrocarbon-Mission |
| Uranus | **Eisriese**, Wolken, extreme Kälte, gekippte Rotationsachse | Orbitmessstation | Sensoren, orbitaler Transport |
| Neptun | **Eisriese**, sehr starke Höhenwinde, dunkle Wolken | Sensororbiter, Wettersatelliten | Strömungs- und Fluchtrouten |

**Zusatzweltziele:** Mond, Phobos/Deimos, Europa, Ganymed, Titan, Enceladus, Asteroiden und Raumstationen als später separate Landekorridore. Sonne ist zentraler Stern und visuelles/navigierbares Systemobjekt, **kein begehbarer Planet**. Größen/Entfernungen in der Orbitkarte maßstäblich abstrahieren, nicht „100.000 km offen fliegen“ behaupten.

## 5. Sechs fiktive NEXUS-Planeten

| Welt | Biom und Fotorealismus | Gebäudeformen | Mission/Interaktion |
|---|---|---|---|
| Terra Nova | europäisch anmutendes Hochland, Erosionsberge, Großstadt am Rand | neue Bergstädte, Schienen, Bergwerke | Krisen/Brücken/Rettung |
| Sahra IX | erodierte Dünen, Staubschleier, endlose Sanderz-Landschaften | Wüstenkolonie, Konvoistation, Wasserförderung | Sandsturm, Versorgung, Verfolgung |
| Nivora | Mehrschichten-Gletscher, Schnee, Eisfelder, Untereishöhlen | Eisobservatorium, Wärmestation, Unterwasserlabor | unterirdische Signale, Bergung |
| Vesper | photogrammetrisch plausible Tropenwälder, Feuchtigkeit, Pilz-/Wurzelökologie | erhöhte Holz-/Bio-Habitate, verstecktes Labor | Kontamination, Verhandlungen |
| Ignis Prime | basaltische Lavaebenen, Spalten, Vulkanasche, Hitze | geothermisches Kraftwerk, Kühlanlagen, Sicherheitsbunker | Ausbruch, KI-Warnung, Evakuierung |
| Umbra | fremde, aber materiell konsistente Mineralformationen, Nebel, Archivruinen | Alien-Tore, Archivstrukturen, Raumstation | Rätsel, Ethik, finale Story |

**Art-Direction-Regel:** Fremde Welten bleiben physikalisch lesbar. Kein zufälliges Neon überall: plausibler Lichtursprung, Materie, Wetterschichten, Staub-/Schnee-/Lava-Interaktion mit Schuhen, Reifen, Kleidung und Fahrzeugen. Jede Welt braucht eigene **Hero-Location, drei Architekturbausätze, acht Materialien, drei Flora-/Geologie-Kits, ein Wetterprofil und einen eigenen Gameplay-Mechanismus**, bevor eine Ausweitung verantwortbar ist.

## 6. Produktionsketten, Fahrzeuge und NPCs

### Rohstoffgraph (im bestehenden C++-Prototyp teilweise vorhanden)
**Holz:** Fällen → Entasten → Rückung → Trocknen → Sägewerk → Balken/Platten → Möbel/Baugerüst.  
**Eisen:** Erz → Brecher → Transport → Ofen/Energie/Brennstoff → Stahlträger → Fahrzeug-/Brückenteile.  
**Beton/Zement:** Kalk/Sand/Schotter → Mischwerk → Beton → Aushärten → Stützen/Fundamente.  
**Asphalt:** Erdöl → Raffinerie/Bitumen → Kies → Mischanlage → Transport → Walzen.  
**Strom/Wasser:** Turbine/Solar/Generator → Netz → Pumpen/Wohnhäuser/Labore.  
**Planetare Wirtschaft:** Regolith, Eis/Wasser, Methan, Schwefel, Titan-/Minerallegierungen – passend zu den jeweiligen Welten, keine universelle „Eisen aus jedem Felsen“-Logik.

### Fahrzeuge (gemeinsames modular erweiterbares System)
Boden: PKW, Geländewagen, LKW, Feuerwehr, Rettung, Bus, Holzrücker, Baukipper, Bagger, Radlader, Walze, Schwerlast. Wasser: Rettungsboot, Fähre, Forschungsschiff. Luft/Orbit: Hubschrauber mit Seilwinde, Transportheli, Flugzeug, Dropship, Shuttle, Rover. **Fahrzeugklasse benötigt** Chassis/Innenraum, Cockpit, Fahrer/Passagiere, Motor/Kraftstoff, physikalisches Profil, Licht/Sound, Schaden, Interaktionen, Reifen/Schnee/Wasser und Netzwerkkorrektur. Wechselbare Ausrüstung statt festgehaltene Waffe.

### KI- und Konsequenzlogik
NPCs haben Identität, Dienst, Schicht, Erinnerung, Zuhause, Fraktionsbezug, Rettungsstatus und Beziehungen. **NEXUS Director** wählt Ereignisse abhängig von Region, zerstörten Wegen, Personalmangel und aktueller Story, nicht nur Zufall. Beispiel: Brücke zerstört → Rettungsweg unterbrochen → Krankenhaus ohne Material → spontane Hubschrauberliefermission → Wiederaufbau verbessert Handelslage. Spielerentscheidungen können nicht alle gleichzeitig „perfekt“ lösen; Ergebnisse müssen reproduzierbar und im SaveGame persistent sein.

## 7. Kampagne: 18 Kapitel / 126 Phasen / Ziel 48 Stunden

**Source of truth:** \`Content/Data/nexus_campaign.json\`. Jedes Kapitel enthält genau sieben Stufen: Aufklärung, Eingriff, Eskalation, Wendung, Höhepunkt, Entscheidung, Ausweg. Die folgenden 18 Titel sind bereits im Datenkatalog hinterlegt:

| # | Kapitel | Zielraum |
|---|---|---|
| 01 | Die letzte Brücke | Terra / Adlerklamm |
| 02 | Spur der Sprengladung | Terra / Stahlhafen |
| 03 | Die Nacht des Staudamms | Terra / Bergstadt |
| 04 | Der Geisterkonvoi | Sahra IX |
| 05 | Das Sandglas-Protokoll | Sahra IX |
| 06 | Der Sturmkönig | Sahra IX |
| 07 | Signal unter Null | Nivora |
| 08 | Der schwarze See | Nivora |
| 09 | Das Eisgericht | Nivora |
| 10 | Das grüne Schweigen | Vesper |
| 11 | Wurzeln der Lüge | Vesper |
| 12 | Die letzte Blüte | Vesper |
| 13 | Der brennende Kern | Ignis Prime |
| 14 | Der Asche-Code | Ignis Prime |
| 15 | Der Vulkan erwacht | Ignis Prime |
| 16 | Unter zwei Himmeln | Umbra |
| 17 | Das falsche Sternentor | Umbra |
| 18 | Die letzte Erinnerung | Umbra |

**48 Stunden = geplante Spielzeit**, die erst nach Level-Implementierung, spielbaren Zielen, Stimmen, Animationen, echten Wegen, Balancing und unabhängigen Playtests gemessen werden kann. Eine JSON-Liste mit 126 Objective-IDs ist keine 126 spielbaren Missionssequenzen. Für jede Stufe werden benötigt: Auslöser, Weltänderung, begehbares Set, Gegner-/Helferpositionen, Dialoge, Mini-/Hauptziel, Fail-/Recovery-Pfad, Koop-Abschlussbedingung, SaveGame und tatsächliche Zeitmessung.

## 8. Technische UE5.8-Architektur

| Domäne | Implementierung / Basis |
|---|---|
| Welt | World Partition, Data Layers, HLOD, Level Streaming, Large World Coordinates |
| Architektur | \`NexusBuildingKit\` (neu), \`NexusSettlementDirector\` (neu), instanzierte Meshes, betretbare Blueprint-Varianten |
| Landschaft | UE Landscape + Heightmap, PCG-Natur; C++ \`NexusCinematicScenery\` schon als Basis |
| Fluss | \`NexusAlpineRiver\` enthält 3D-Bett, Prall-/Gleithang, Strömung und Schwimmen; Material-/GPU-Abnahme ausstehend |
| Wetter/Licht | \`NexusAlpineWeather\`; Lumen/Nanite/VSM im geeigneten GPU-Qualitätsprofil |
| Spieler/Koop | \`NexusExplorer\`, \`NexusGameMode\`, \`NexusVehicle\`, serverautoritative RPC und replizierte Spielzustände |
| Bergung | \`NexusWorldDirector\`, \`NexusRescueTarget\`, \`NexusUnderwaterEvidence\`, \`NexusBridge\`, \`NexusBus\` |
| Wirtschaft | \`NexusIndustrySite\`, \`FNexusResourceStock\`; für Produktionsgraph später echte UI und Wege |
| Missionen | \`NexusCampaignComponent\`, \`nexus_campaign.json\`; nur Kapitel 1 teilweise in Weltaktionen umgesetzt |
| Weltgedächtnis | \`NexusSimulationComponent\` mit Straßen-/Medizin-/Handels-/NPC-Werten |
| KI | \`NexusCompanion\` als Start; später Perception, Behaviour Trees, EQS, NavMesh, Smart Objects |
| Planeten | \`nexus_world_profiles.json\` (Daten), später \`NexusPlanetTravelSubsystem\` + Landing-Zone-Maps |
| Effekte | Niagara / Chaos-Fracture / Water, keine fotorealistischen Ergebnisse ohne geprüfte Assets |
| Qualität | GitHub Actions Python/Quellcode-Contracts; echter UE5.8-Compile + GPU-Playtest weiterhin erforderlich |

**Verzeichnisziel:**
\`\`\`text
Unreal/NEXUS_UE5/
  Content/
    Data/                       # JSON Campaign, World Profiles, Building/Map Catalogue
    SourceArt/PBR/              # Rohtexturen (nicht als uasset in Git)
    SourceArt/Geometry/         # GLB/GLTF/FBX + Herkunfts-/Lizenzmetadaten
    Maps/L_Adlerklamm_*.umap    # erst nach echtem Unreal-Editor-Build
    AAA/Buildings/             # Nanite statisch + zerstörbare Varianten
    AAA/Terrain/               # Landscape, PCG
    AAA/VFX/                   # Niagara Wasser, Wetter, Rauch, Trümmer
  Source/NEXUS/                # C++ Spielsysteme
  Scripts/                     # Editor-Import, CC0, Offline-Tests
  Docs/NEXUS_AAA_MASTER_BAUPLAN.md
\`\`\`

**0-€-Assets:** selbst generierte 3D-Module/Materialien, vorhandene NEXUS-Modelle, rechtssichere CC0-Fotogrammetrie (beispielsweise der bereits verifizierte Felsensatz von Poly Haven). Künstlerische Quellassets und Fotos nur mit Lizenz-/Herkunftsnachweis übernehmen. Nicht einfach Screenshots/Stockbild-Texturen kopieren. Große Binärdateien nur über Git LFS (wenn kostenloses Kontingent reicht), Release-Artefakte oder separate Importpakete, nicht als unkontrollierte Git-Historie.

## 9. Qualitätsprofile: schlechte Hardware darf die Architektur nicht begrenzen

- **Edit/Low:** Bau-/Testmodus ohne Lumen/Nanite-Pflicht, kleine View-Distance, reduzierte Vegetation, vereinfachte Materialien. Dein Intel UHD 620 / 8-GB-Laptop ist selbst dafür riskant; kein Erfolg zugesichert.
- **High:** geeigneter Desktop mit diskreter GPU, Nanite/HLOD, selektive Lumen-Einstellungen und moderne Schatten.
- **Cinematic:** GPU-Workstation / Unreal Movie Render Queue, hochwertige Texturen/Geometrie, atmosphärisches Licht; nicht als Echtzeit-Framerate-Garantie verkaufen.
- **iPhone:** Browser-Streaming über einen tatsächlich verfügbaren, sicheren GPU-Host ist nur dann möglich, wenn kostenloser geeigneter Zugang existiert. **Eine dauerhaft kostenlose RTX-Cloud ist nicht garantiert und wird nicht fingiert.**

## 10. Produktionsreihenfolge mit überprüfbaren Gates

| Gate | Lieferung | Abnahmebedingung |
|---|---|---|
| G0 – Basis | UE5.8-Projektstruktur, Code, Lizenzen, Datenmanifest | Offline-Tests grün; keine behaupte UE-Kompilierung |
| G1 – Erster UE-Build | C++ Editor in UE5.8 starten, Log ohne Compile-Fehler | **echt** auf Windows/UE ausgeführt, reproduzierbare Build-Logs |
| G2 – Adlerklamm Natur | 2×2 km Landscape, gescannte Felsen, echte Bäume, Fluss, Straßen | echte UE-1920×1080 Aufnahmen aus festem Blickwinkel |
| G3 – Häuser | 5 betretbare Hero-Gebäude (Hof, Wohnhaus, Krankenhaus, Feuerwache, Industrie) + modularer Kit | glaubwürdige Außen- und Innenansichten, keine Platzhalterwürfel |
| G4 – Unglück/Rettung | Bus, fahrbare Brücke, Chaos Fracture, 3 Verletzte, Tauch-/Heli-Mission | mehrfach reproduzierbarer Gameplay-Clip + nicht-blockierte Recovery |
| G5 – Systeme/Koop | Holz/Eisen/Zement/Asphalt, NPC-Weltgedächtnis, Savegame, vier Clients | Server-/Client-PIE inklusive Late Join, Disconnect, Save/Load |
| G6 – Welten | zuerst **eine** zusätzliche Planetenzone hochwertig (Ignis oder Nivora), dann weitere | eigenes Biom/Architektur/Ressourcen/Physik geprüft |
| G7 – Kampagne | alle 18 Kapitel mit 126 echten Missionsetappen | kompletter QA-Durchlauf, reale Dauer dokumentiert, keine Fake-48h |
| G8 – Fotorealismus | Beleuchtung/Material/LOD/Audio/Animation optimiert | echte Screenshots/Video, unabhängiger visueller Vergleich, FPS/VRAM-Bericht |

**Risikoregel:** Kein Gate als „fertig“ markieren, nur weil C++-Quelldateien angelegt oder statische Tests grün sind. Vor allem G1 ist eine externe technische Blockade, solange keine Unreal-5.8-Ausführungsumgebung verfügbar ist.

### Sofortiger nächster Produktionsauftrag an nachfolgenden KI-Agenten
1. Dieses Dokument und \`Content/Data/nexus_building_world_catalog.json\` lesen.
2. Falls UE5.8-Buildrechner vorhanden: **G1 zuerst** beheben/kompilieren, ungetestete C++-APIs korrigieren, Logs ablegen.
3. Danach echtes \`L_Adlerklamm_VerticalSlice\` in Unreal erzeugen. Keine rein textuelle Platzhalterszene als Ergebnis abliefern.
4. Ein vollständiges, wiederverwendbares **Alpenhaus-Hero-Kit** mit Fenstern, Dach, Innenraum, Materialien, Kollision, Tür-Interaktion und Referenzaufnahmen erstellen, danach die vier anderen Hero-Gebäude.
5. Nur unveränderte CC0-Quellassets oder eigene Originale, exakte Lizenzdaten; keine unlizenzierte Stock-/Shutterstock-Grafik.
6. Abgeschlossenes Arbeitspaket nur mit GitHub-Commit, reproduzierbarem Test und klarer Statuskennzeichnung abgeben.

**Ergebnisdefinition:** NEXUS wird schrittweise auf die gewünschte Qualität gebracht. Dieser Bauplan legt alle Welten und Gebäude fest, behauptet aber nicht, sie seien schon gebaut.
