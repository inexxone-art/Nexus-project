# PROJECT NEXUS — OFFIZIELLER TRAILER · PRODUCTION SPEC

## Verbindliche Qualitätsregel
Der offizielle Trailer darf **nur tatsächlich gerenderte Aufnahmen aus der aktuellen, geprüften Godot-Spielversion** als Gameplay zeigen. Keine KI-Konzeptbilder oder externen Spiele-Screenshots als angebliche In-Engine-Aufnahmen ausgeben. Der Bildstil orientiert sich an fotorealistischen, **eigenständigen** Spielwelten; keine übernommenen fremden Marken, Models oder Assets ohne Lizenz.

## Technisches Ziel
- 16:9, 1920x1080, 30 FPS als minimal reproduzierbarer Master; 4K/60 FPS erst, wenn echte entsprechend hochwertige Capture-Quellen und geeignete GPU vorliegen.
- 75 Sekunden: 3s Titel + 8x8s tatsächliche In-Engine-Aufnahmen + 8s Abspann.
- Bildsprache: breite Totalen, sichere räumliche Orientierung, echte Fahrzeugbewegung, dynamisches Licht, Wetter, glaubwürdiges Materialverhalten.
- Ton: originale oder lizenzierte Musik, aus tatsächlichen Spielszenen aufgezeichnete Effekte, deutscher Sprecher, optionale englische Untertitel.
- Optional zusätzlich: 9:16 Cutdown für Instagram Reels und 30s Kurztrailer.

## Szenen / Regie
1. 00–03: Logo PROJECT NEXUS auf Schwarz.
2. 03–11: Alpental bei Sonnenaufgang, Blick auf Dorf, Forststraße und Schneeberge.
3. 11–19: Wetterbruch, Bergrettung, Helikopter, Sichtbehinderung, Suche.
4. 19–27: NEXUS City nachts, Regen, Verkehr, Blaulicht, Rettungseinsatz.
5. 27–35: Sektor 31, originale Kampf-Gameplay-Aufnahmen, KI-Deckung und Evakuierung.
6. 35–43: Bauprojekt / Fuhrpark: Bagger, LKW, Materialfluss und sichtbare Baustellenänderung.
7. 43–51: Raumhafen, Schiff, Übergang zur Sternenkarte.
8. 51–59: Sechs Planeten in kurzem, deutlichem Biome-Vergleich.
9. 59–67: Umbra: Geheimnis um das Netzwerk und eine echte Gameplay-Entscheidung.
10. 67–75: PROJECT NEXUS, klare Einblendung „Work in Progress“.

## Sprechertext (Entwurf)
„Eine Welt, in der jeder Tag anders beginnt. In der ein gewöhnlicher Auftrag eine ganze Geschichte verändern kann. Rettet Leben. Baut Städte. Entscheidet über Konflikte. Überquert die Grenzen eurer Welt. Sechs Planeten. Tausende Möglichkeiten. Jede Entscheidung bleibt. PROJECT NEXUS.“

## Herstellung und Qualitätsgates
1. Engine-Import und Smoke-Tests müssen bestanden sein.
2. Lizenznachweis für alle verwendeten 3D-Modelle, Texturen, Stimmen und Musik.
3. Grafisch glaubwürdige, spielbare Vertikal-Scheibe; vollständige Welt nicht nötig, aber Szenen dürfen keine Attrappen als angebliches Gameplay verkaufen.
4. Mindestens acht originale Spiel-Captures unter `captures/gameplay/` mit im `trailer/shotlist.json` definierten Mindestlängen.
5. `python tools/build_trailer.py --music <original_oder_lizenzierter_track.mp3>` baut den MP4-Master; ohne Musik: `python tools/build_trailer.py`.
6. Manuelle Bild-/Tonabnahme (Bewegung, ruckelfreie Frametime, Schnitt, Bildfehler, lesbare Einblendungen, Wahrheitsgehalt).

## Status (2026-11-01)
Die Capture-Szenen **existieren noch nicht als abgenommene Gameplay-Videodateien**. V1.4 enthält überwiegend prozedurale Prototyp-Assets; der AAA-Look ist noch Entwicklungsziel. Das bereitgestellte Skript ist eine reproduzierbare Videopipeline, **kein fertiger Trailer**.