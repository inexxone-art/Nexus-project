# Unreal Engine 5.8 — Cloud-GPU-Entwicklung ohne leistungsstarken Privat-PC

## Ziel
Unreal Engine und Bildberechnung laufen auf einer geeigneten GPU-Cloud-Workstation.
Der Anwender kann die fertige Anwendung auf dem iPhone über **PixelStreaming2**
steuern. Ein iPhone rendert dabei nicht selbst die AAA-Grafik.

## Hardware
Für den ersten GPU-Cloud-Test plane eine Windows-Workstation mit mindestens
32 GB RAM und DX12-fähiger Grafikkarte mit >=8 GB VRAM. Für aufwendige
Adlerklamm-Szenen empfehle ich zunächst **64 GB RAM, 16–24 GB VRAM und
200 GB+ SSD**. Diese Werte sind Arbeitsannahmen, keine garantierten FPS.

Epic UE 5.8 Mindest-/Empfehlungswerte:
https://dev.epicgames.com/documentation/unreal-engine/hardware-and-software-specifications-for-unreal-engine

## Kosten
GPU-Instanzen werden normalerweise pro Zeit abgerechnet. Ohne Konto,
Budgetfreigabe und Cloudanbieter wurde bisher **keine Maschine gemietet,
kein Server gestartet und kein Cloud-GPU-Test durchgeführt**.
Der manuell startbare GitHub-Workflow unten benötigt einen konfigurierten,
eigenen GPU-Runner mit den Labels `self-hosted, Windows, X64, ue5-gpu`.
GitHub Actions Standard-Ubuntu-Läufer liefern keine UE5-RTX-GPU.

## Testablauf
1. Cloud-VM mit moderner NVIDIA-GPU, GPU-Treiber und Windows starten.
2. Unreal 5.8 + Visual Studio 2022 (C++-Workloads) über einen
   legitimierten Epic-Login installieren; den Windows-GPU-Rechner nur
   über gesicherten Zugriff fernsteuern.
3. Die NEXUS-UE5-Quellen aus dem Repository holen.
4. Die separat gelieferte NEXUS-Materialbibliothek in
   `Content/SourceArt/PBR/` kopieren.
5. `Unreal/NEXUS_UE5/NEXUS.uproject` öffnen, Buildfehler beheben und
   über `Scripts/import_nexus_pbr.py` die PBR-Materialien importieren.
6. **Erst nach erfolgreichem Editor-/UE-Build** das CI-Skript
   `cloud-build-unreal5.yml` auf einem GPU-Runner ausführen.
7. Für den Einsatz auf dem iPhone das Plugin **PixelStreaming2**
   aktivieren; einen sicheren Signalling/WebRTC-Stack mit Authentifizierung
   und TLS betreiben. Keinesfalls offene RDP-/Unreal-Ports direkt freigeben.
8. Die tatsächliche Adlerklamm-Szene am GPU-Rechner mit Blickwinkel und
   Beleuchtung der vom Nutzer gelieferten Bildvorlage vergleichen.
9. GPU-FPS, 1%-Low, VRAM, Busphysik, Missionen und Ressourcen im echten
   Spiel testen. „AAA“ erst nach solch einer Abnahme behaupten.

## Offizielle Dokumentation
- Pixel Streaming: https://dev.epicgames.com/documentation/en-us/unreal-engine/pixel-streaming-in-unreal-engine
- UE 5.8 Quickstart: https://dev.epicgames.com/documentation/en-us/unreal-engine/getting-started-with-pixel-streaming-in-unreal-engine

## Grenzen des heutigen Stands
Das UE5.8-Projekt besteht noch aus **programmierter Migrationsgrundlage,
Editor-Platzhaltergeometrie und vorbereiteten Materialslots**.
Der Unreal Editor selbst ist in dieser Umgebung nicht installiert.
Kein echter Unreal-GPU-Screenshot, keine fertige photogrammetrische
Adlerklamm-Welt, keine professionelle Character-Animation.
Die alte spielbare Godot-Version bleibt separat erhalten.
