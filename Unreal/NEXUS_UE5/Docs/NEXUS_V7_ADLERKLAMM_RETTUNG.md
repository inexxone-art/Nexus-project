# NEXUS V7: Adlerklamm - Bus, Suche, Erstversorgung und Bergung

Stand: 02.11.2026. Diese Runde entwickelt die bereits vorhandene UE5-C++-Mission
auf dem Branch `feature/adlerklamm-rescue-v7` weiter. Es ist ein **Code-Meilenstein**,
kein fertiges 48-Stunden-Spiel und kein verifizierter UE5-Grafikbuild.

## Ablauf zum Ausprobieren

1. Im Start-Haus die Auftraege ansehen (`B` im Buero). `F11` versetzt die Figur
   zum Rettungseinsatz; `E` in der Naehe eines Autos steigt ein.
2. Auf der westlichen Anfahrt in Richtung Bruecke fahren (`W`, `A`, `D`).
   Ein Bus wird serverseitig als Verkehr mit Abstand hinter dem fahrenden
   Spieler bewegt, bleibt auf der Bruecke und stuerzt nach der Durchfahrt
   mitsamt den Brueckensegmenten in die Schlucht. Chaos uebernimmt die Physik.
3. Nach dem Notruf eine Rolle mit `F1` Sanitaeter, `F2` Pilot oder `F3`
   Bodensuche waehlen. In Koop kann jeder Spieler seine eigene Rolle waehlen;
   Rollenwechsel sind auch waehrend des Rettungseinsatzes moeglich.
4. **Boden:** Person anlaufen und `E` nacheinander zum Lokalisieren,
   Stabilisieren und Bergen betaetigen. **Pilot:** Am Heli einsteigen (`E`),
   zu den Vermissten fliegen, 4-24 m ueber ihnen langsam schweben und mit `E`
   suchen, versorgen und bergen. Teamkameraden koennen gleichzeitig am Boden
   arbeiten. Der HUD-Wegweiser zeigt die jeweils naechste reale Zielposition.
   Der Helikopter steht auf einem eigens markierten Landeplatz auf dem
   Ostplateau; dieser ist **kein** vollstaendiger Flughafen.
5. Nach drei Bergungen folgen vier Wiederaufbauphasen. Eisen, Zement und
   Asphalt muessen ueber die schon vorhandenen Produktionsketten beschafft
   werden. Der Spielstand speichert auch teilweise versorgte Personen.

## Implementierte technische Verbesserungen

- Der Bus ist nicht mehr statisch auf der Bruecke platziert. Er folgt dem
  fahrenden Verkehr auf dem Server; Bewegung und Absturz werden repliziert.
- Triage-Zustaende `bLocated`, `bStabilized`, `bRescued` werden getrennt
  repliziert und angezeigt. Fuer Abschlusspruefungen werden nur wirklich
  geborgene Personen gezaehlt.
- Individuelle Rettungsrollen auf Spielfiguren und besetzten Fahrzeugen
  ersetzen die bislang globale Einzelauswahl fuer Koop-Aktionen. Der erste
  gewaehlte Teamweg bleibt fuer alte Spielstaende erhalten.
- Missionsziele, Rettungsakteure, Bus, Bruecke und Heli erhalten Replikation
  der relevanten Verweise. Die HUD-Zahlen stammen aus diesen Zustaenden.
- Speichern/Laden enthaelt Such- und Versorgungsstatus. Alte Spielstaende mit
  nur `RescuedIds` koennen diese abgeschlossenen Bergungen rekonstruieren.
- Provisorische Viadukt-Stuetzen stehen nicht mehr mitten auf den Fahrspuren.
- Die erste Brueckenmission verwendet im Storykatalog jetzt das korrekte
  Gebiet Adlerklamm statt des zuvor irrtuemlichen `aurelia`.

## Nachweis und offene Arbeiten

- `python3 -m unittest discover -s Scripts -p 'test_*.py'` testet nur die
  Skripte, Daten und Quellcode-Vertraege. Es ist **kein** UE5-Laufzeittest.
- Unreal Editor, Chaos/Physik, Kollisionen bei hoher Geschwindigkeit,
  Replication in vier Player-in-Editor-Fenstern und Savegame-Lebenszyklus
  muessen auf einer UE5-Installation ausprobiert werden.
- Die gezeigten Fotorealismus-Bilder sind Art Direction. Hochwertige 3D-Assets,
  Nanite-Landschaft, ueberzeugende Metahumans, Audio, Animationen, Wetter-VFX
  und finaler Beleuchtungsabgleich sind noch offen. Ohne diese Assets ist
  die Szene sichtbar ein Prototyp.
- Die Kampagne mit 48 Stunden, alle Planeten und Monde, der Lavaplanet mit
  Alien-Forschern, die historische Parallelwelt und vollstaendiger Vierer-Koop
  sind weiter *Ziele*, keine abgenommenen Features.

## Naechster Build-Check

Unreal/NEXUS_UE5/NEXUS.uproject in einer zur Repository-Konfiguration
passenden UE5-Version oeffnen, C++-Module kompilieren, `Play In Editor` mit
1 und 4 Spielern testen. Vom Haus bis zum Ende der vierten Bauphase spielen.
Besonders pruefen: Bus hinter dem Lead-Fahrzeug, Sturz vor Zeugen, Blickachsen,
alle drei Triage-Aktionen, Hover-Hoehe, Fahrzeugwechsel, Verbindung nach
Rejoin und Save/Load in allen Zwischenphasen. Danach Gameplay-Aufnahmen
aus dem Editor mit den gelieferten Referenzbildern vergleichen.
