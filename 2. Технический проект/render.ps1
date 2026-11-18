param(
    [string]$JavaPath,
    [string]$PlantUmlJar
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (!$JavaPath) {
    $JavaPath = Join-Path $projectRoot '.tools/java/bin/java.exe'
    if (!(Test-Path -LiteralPath $JavaPath)) {
        $JavaPath = (Get-Command java -ErrorAction Stop).Source
    }
}
if (!$PlantUmlJar) {
    $PlantUmlJar = Join-Path $projectRoot '.tools/plantuml.jar'
}
if (!(Test-Path -LiteralPath $PlantUmlJar)) {
    throw 'Укажите путь к plantuml.jar параметром -PlantUmlJar. Нужна Java 17 или новее.'
}

$outputDirectory = Join-Path $projectRoot 'out/2. Технический проект'
New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
$diagrams = @('Контекст.puml', 'Контейнеры.puml', 'Компоненты.puml') | ForEach-Object {
    Join-Path $PSScriptRoot $_
}
foreach ($format in @('svg', 'png')) {
    & $JavaPath '-Djava.awt.headless=true' '-DPLANTUML_LIMIT_SIZE=10000' '-jar' $PlantUmlJar '-charset' 'UTF-8' '-nometadata' '-failfast2' "-t$format" '-o' $outputDirectory @diagrams
    if ($LASTEXITCODE -ne 0) { throw "Не удалось создать диаграммы $format" }
}
Write-Output "Созданы SVG и PNG трёх диаграмм: $outputDirectory"
