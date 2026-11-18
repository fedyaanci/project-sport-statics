$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$toolDirectory = Join-Path $projectRoot '.tools'
New-Item -ItemType Directory -Path $toolDirectory -Force | Out-Null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function Get-CheckedFile([string]$Url, [string]$Destination, [string]$Sha256) {
    if (!(Test-Path -LiteralPath $Destination) -or (Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash -ne $Sha256) {
        Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $Destination
    }
    if ((Get-FileHash -LiteralPath $Destination -Algorithm SHA256).Hash -ne $Sha256) {
        throw "Контрольная сумма не совпала: $Destination"
    }
}

Get-CheckedFile `
    'https://github.com/plantuml/plantuml/releases/download/v1.2026.10/plantuml-1.2026.10.jar' `
    (Join-Path $toolDirectory 'plantuml.jar') `
    'e9bc9e6b2eb715e8c0c929f3dcb5fc1923be13f37599b09c293c66d354e88686'

$javaDestination = Join-Path $toolDirectory 'java'
if (!(Test-Path -LiteralPath (Join-Path $javaDestination 'bin/java.exe'))) {
    $archivePath = Join-Path $toolDirectory 'java17.zip'
    Get-CheckedFile `
        'https://github.com/adoptium/temurin17-binaries/releases/download/jdk-17.0.21%2B9/OpenJDK17U-jre_x64_windows_hotspot_17.0.21_9.zip' `
        $archivePath `
        'fe4656bd78fb09812dc38c49da777f79cc33e7ee435a254be82f9e7f40d9d117'
    $unpackDirectory = Join-Path $toolDirectory 'java-unpacked'
    Expand-Archive -LiteralPath $archivePath -DestinationPath $unpackDirectory -Force
    $runtimeDirectory = Get-ChildItem -LiteralPath $unpackDirectory -Directory | Select-Object -First 1
    if (!$runtimeDirectory) { throw 'В архиве не найден каталог Java' }
    New-Item -ItemType Directory -Path $javaDestination -Force | Out-Null
    Get-ChildItem -LiteralPath $runtimeDirectory.FullName | ForEach-Object {
        Copy-Item -LiteralPath $_.FullName -Destination $javaDestination -Recurse -Force
    }
}

$editorDirectory = Join-Path $projectRoot '.vscode'
New-Item -ItemType Directory -Path $editorDirectory -Force | Out-Null
$settingsPath = Join-Path $editorDirectory 'settings.json'
$settings = @{}
if (Test-Path -LiteralPath $settingsPath) {
    $previousSettings = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
    $previousSettings.PSObject.Properties | ForEach-Object { $settings[$_.Name] = $_.Value }
}
$settings['plantuml.render'] = 'Local'
$settings['plantuml.java'] = Join-Path $javaDestination 'bin/java.exe'
$settings['plantuml.jar'] = '.tools/plantuml.jar'
$settings['plantuml.exportOutDir'] = 'out'
$settings['plantuml.exportFormat'] = 'svg'
$settings['c4.languageserver.java'] = $javaDestination
$settings | ConvertTo-Json -Depth 10 | Set-Content -LiteralPath $settingsPath -Encoding UTF8

Write-Output 'Java 17, PlantUML и локальные настройки VS Code подготовлены. Можно запускать render.ps1.'
