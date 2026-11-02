# NEXUS Windows Build Fix - Unreal Engine 5.8
# Put this file next to NEXUS.uproject and run NEXUS_BUILD_FIX.cmd.
# Does not delete or modify source code, assets or save games.
param([string]$ProjectDir=$PSScriptRoot,[switch]$NoLaunch)
$ErrorActionPreference='Stop'
$ProjectDir=(Resolve-Path -LiteralPath $ProjectDir).Path
$UProject=Join-Path $ProjectDir 'NEXUS.uproject'
$UE='C:\Program Files\Epic Games\UE_5.8'
$Build=Join-Path $UE 'Engine\Build\BatchFiles\Build.bat'
$Editor=Join-Path $UE 'Engine\Binaries\Win64\UnrealEditor.exe'
$Logs=Join-Path $ProjectDir 'Saved\Logs'
New-Item -ItemType Directory -Path $Logs -Force | Out-Null
$Log=Join-Path $Logs 'NEXUS_Compile.log'
$vswhere=Join-Path ([Environment]::GetFolderPath('ProgramFilesX86')) 'Microsoft Visual Studio\Installer\vswhere.exe'
$vsinstaller=Join-Path ([Environment]::GetFolderPath('ProgramFilesX86')) 'Microsoft Visual Studio\Installer\vs_installer.exe'
function FindVS {
    if (-not (Test-Path $vswhere)) { return @() }
    return @(& $vswhere -products '*' -property installationPath | Where-Object { $_ -and (Test-Path $_) })
}
function FindCompiler {
    foreach ($installation in (FindVS)) {
        $root=Join-Path $installation 'VC\Tools\MSVC'
        if (-not (Test-Path $root)) { continue }
        foreach ($folder in (Get-ChildItem $root -Directory | Sort-Object Name -Descending)) {
            $cl=Join-Path $folder.FullName 'bin\Hostx64\x64\cl.exe'
            try { $v=[version]$folder.Name } catch { continue }
            if ($v -ge [version]'14.38.33130' -and (Test-Path $cl)) { return $cl }
        }
    }
    return $null
}
function Fail([string]$Message) {
    Write-Host "FEHLER: $Message" -ForegroundColor Red
    Write-Host "Bei Compilerfehlern bitte diese Datei hochladen: $Log"
    exit 1
}
Write-Host 'NEXUS UE5.8 C++ Reparatur' -ForegroundColor Cyan
if (-not (Test-Path $UProject)) { Fail 'NEXUS.uproject fehlt. Beide Skripte in den Ordner NEXUS_UE5 kopieren.' }
if (-not (Test-Path $Build)) { Fail 'Unreal Engine 5.8 wurde im erwarteten Epic-Games-Ordner nicht gefunden.' }
$cl=FindCompiler
if (-not $cl) {
    Write-Host 'MSVC C++ fehlt oder ist zu alt. Installiere offizielle Microsoft Build Tools.' -ForegroundColor Yellow
    $vs=@(FindVS)
    if ($vs.Count -gt 0) {
        if (-not (Test-Path $vsinstaller)) { Fail 'Visual Studio Installer fehlt. Bitte Visual Studio Installer reparieren.' }
        $arguments=@('modify','--installPath',('"' + $vs[0] + '"'),'--add','Microsoft.VisualStudio.Workload.VCTools','--includeRecommended','--add','Microsoft.VisualStudio.Component.Windows11SDK.22621','--passive','--norestart')
        $process=Start-Process -FilePath $vsinstaller -ArgumentList $arguments -PassThru -Wait
        if ($process.ExitCode -eq 3010) { Fail 'Windows-Neustart erforderlich. Danach dieses Skript erneut ausfuehren.' }
        if ($process.ExitCode -ne 0) { Fail "Visual Studio Installer fehlgeschlagen: $($process.ExitCode)" }
    } else {
        if (-not (Get-Command winget.exe -ErrorAction SilentlyContinue)) {
            Fail 'winget fehlt. Installiere Visual Studio 2022 Build Tools mit Desktopentwicklung mit C++.'
        }
        $options='--quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --add Microsoft.VisualStudio.Component.Windows11SDK.22621'
        & winget.exe install --id Microsoft.VisualStudio.2022.BuildTools --exact --source winget --accept-source-agreements --accept-package-agreements --override $options
        if ($LASTEXITCODE -ne 0) { Fail "Build-Tools-Installation fehlgeschlagen: $LASTEXITCODE" }
    }
    $cl=FindCompiler
    if (-not $cl) { Fail 'MSVC-Compiler noch nicht gefunden. Windows neu starten und Installer pruefen.' }
}
Write-Host "C++-Compiler gefunden: $cl" -ForegroundColor Green
Write-Host 'Kompiliere NEXUSEditor ...'
& $Build NEXUSEditor Win64 Development "-Project=$UProject" -WaitMutex -NoHotReloadFromIDE *> $Log
$rc=$LASTEXITCODE
Get-Content $Log -Tail 40 | ForEach-Object { Write-Host $_ }
if ($rc -ne 0) { Fail "NEXUS C++ Build fehlgeschlagen: $rc" }
Write-Host 'NEXUS wurde kompiliert!' -ForegroundColor Green
if (-not $NoLaunch) {
    Start-Process -FilePath $Editor -ArgumentList ('"' + $UProject + '"')
    Write-Host 'Unreal Editor wird gestartet.'
}