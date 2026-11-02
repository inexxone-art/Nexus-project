# V3.9 – Lebendiger Flussquerschnitt und Schwimmen in Adlerklamm

## Referenz
Das vom Nutzer gesendete, lizenzierbare Shutterstock-Schaubild zeigt
**Prallhang** (Außenkurve mit Seitenerosion und Uferabbrüchen),
**Gleithang** (Innenkurve mit Ablagerung und Sandbank),
schnellere Strömung außen, langsamere innen und die seitliche Verlagerung
des Flussbetts. Das Bild selbst und sein Shutterstock-Wasserzeichen
wurden NICHT in das Spiel übernommen; wir verwenden es nur als
geologische Referenz.

## In diesem Entwicklungsstand PROGRAMMIERT
- `ANexusAlpineRiver` baut eine echte 3D-Querschnittsgeometrie mit
  lokal tieferem Flussbett am Prallhang (bis ca. **5,2 m**),
  flacher Sandbank am Gleithang (ca. **0,9 m**) und zwei modellierten
  Uferflächen. Für das Bett und die Ufer wird Kollisionsgeometrie
  berechnet, für die Wasseroberfläche ausdrücklich KEINE feste
  Kollision (sonst könnte man nicht hineinschwimmen).
- Die Strömung folgt dem gewundenen Flusslauf und ist in der
  Außenkurve mit bis zu **4,8 m/s** deutlich stärker als innen
  (ca. **1,76 m/s**). Diese Werte sind **Spielbalance-Annahmen**,
  keine vor Ort gemessenen Fließgeschwindigkeiten.
- Der Fluss verläuft **Nord–Süd unter der West–Ost-Brücke**.
  Die Schluchtwände wurden dazu ausgerichtet und der alte
  rechteckige `RiverBase`-Block wurde entfernt.
- `ANexusExplorer`: Swim-Modus für echtes dreidimensionales Bewegen,
  Auftauchen/Tauchen, Strömungseinfluss, vereinfachten Auftrieb,
  45 Sekunden Atemluft, Ermüdungs-/Gesundheitsfolge bei Luftmangel,
  Strand-Rettungspunkt statt endgültigem Spielabbruch.
- Unterwasser-Kamerafärbung und Besitzer-replizierte Atemluft.
  Die Fortbewegung verwendet bewusst `MOVE_Flying` mit Wasserprüfung,
  weil noch keine Editor-erzeugten `PhysicsVolume`-Wasservolumen
  vorhanden sind. Sie ist noch keine finale Schwimmanimation/Physik.
- `ANexusUnderwaterEvidence`: leuchtender Datenrekorder liegt
  tatsächlich auf dem gekrümmten Flussbett; nach dem Bussturz
  über `E` bei tiefem Tauchen bergbar, mit Story-Fortschritt,
  Bonus und gespeicherter/kooperativ replizierter Bergung.
- `Scripts/create_riverbank_material.py`: Unreal-Editor-Skript
  erzeugt ein Material, das per VertexColor zwischen sandiger
  Ablagerungszone und Fels-/Erosionsufer unterscheidet.

## Steuerung
- WASD: Im Wasser horizontal schwimmen
- **Leertaste**: Auftauchen, über Wasser springen
- **Strg**: Abtauchen
- **E**: Am Datenrekorder unter Wasser bergen (erst nach Busabsturz
  und passender Missionsphase)
- HUD: Atemluft (Sekunden), Strömung, Warnung bei Luftmangel

## Was NOCH fehlt
- Kein echter UE5.8-Editor-Build (in dieser Umgebung keine UE-Installation).
- Kein verifizierter 4-Spieler-Wasser-/NPC-Playtest, keine echten
  Unterwasseranimationen, keine Fischschwärme, keine hydraulisch
  korrekte Freiwasserphysik, kein dynamisch wandernder Fluss
  im Zeitverlauf. Die Bildreferenz zeigt Flusswanderung,
  **derzeit ist die Verlaufslinie statisch**.
- Schatten, Wassertransparenz, Dichte, Schaum, gebrochene Strahlen,
  Wellenbewegung, nasse Felsen und fotografisch vermessene
  Sedimente sind für den finalen Fotorealismus noch im Ausbau.
- Der Standard-Fluss und die geskripteten Bankmaterialien
  sind keine fertig abgenommenen photorealistischen AAA-Assets.

## Projektgrenzen
0 € zusätzlich. Keine Engine-Miete, Cloud-GPU oder kostenpflichtigen
Assets. Draft-PR in Github bleibt zunächst separat, der Godot-Stand
auf `main` wird nicht beschädigt.
