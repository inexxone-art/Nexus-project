# PROJECT NEXUS V1.6 — iPhone-Browser-Testversion

## Implementiert
- Overlay mit 12 Touch-Bedienelementen: Laufen (4), Sprinten, Springen, Interaktion, Fahrzeug, Karte, Sternensystem, Speichern, Einsatzleitung.
- Swipe im rechten Bildschirmbereich bewegt die Kamera zu Fuss.
- Auf Touchscreen automatisch aktiv; PC-Version nutzt weiterhin Tastatur und Maus.
- Web-Exportkonfiguration und eigene GitHub-Actions-Workflow-Datei (`web-build.yml`) mit signierter Original-Godot-4.4.1-Releasequelle, offiziellen Exportvorlagen und `.wasm`-Integritaetspruefung.
- Der Web-Build wird als GitHub-Actions-Artefakt namens `PROJECT-NEXUS-WEB-PREVIEW` bereitgestellt, **sofern** der Export in der Cloud erfolgreich durchlaeuft.

## Bedienung
Browser im Querformat (Landscape) verwenden. Links bewegen, rechts nach oben/unten/rechts/links wischen, rechts die Aktionen antippen.

## Grenzen
- Nicht mit nativer iOS-App zu verwechseln. Bei Browser-Exports sind WebGL/GLES3-Grafik, Speicher und Leistung eingeschraenkt.
- Es existiert noch **keine** veroeffentlichte GitHub-Pages-Spieladresse. Das erzeugte HTML5-Archiv muss auf einem geeigneten Webserver gehostet werden.
- Nicht behaupten, dass die Grafik auf iPhone das fotorealistische Desktop-Referenzniveau erreicht.
- Automatische Exporte sind von verfuegbaren GitHub-Actions-Ressourcen und Godot-Templates abhaengig.

## Direkt im iPhone-Browser spielen: GitHub Pages
Der Web-Workflow kann automatisch nach GitHub Pages deployen, **wenn** GitHub Pages fuer das Repository eingeschaltet ist. Diese Freigabe verlangt GitHub einmalig in **Settings → Pages → Build and deployment → Source: GitHub Actions**. Nach der Aktivierung den Workflow `Experimental NEXUS Web Preview` im Actions-Tab neu ausloesen. Erst nach gruenem Deploy-Job die Adresse `https://inexxone-art.github.io/Nexus-project/` als verfuegbar bezeichnen. Ohne Aktivierung bleibt der Build als ZIP-Artefakt verfuegbar; eine URL wird nicht erfunden.
