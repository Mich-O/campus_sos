param(
    [string]$DeviceId = "CPH2471"
)

$ErrorActionPreference = "Stop"
$buildRoot = Join-Path $PSScriptRoot ".campus_sos_build"
$gradleHome = Join-Path $buildRoot "gradle"
$tempFolder = Join-Path $buildRoot "temp"

New-Item -ItemType Directory -Force -Path $gradleHome, $tempFolder | Out-Null

# Keep this app's Gradle cache and Java temp files on F:, not the nearly-full C: drive.
$env:GRADLE_USER_HOME = $gradleHome
$env:TEMP = $tempFolder
$env:TMP = $tempFolder

Set-Location $PSScriptRoot
$flutter = Get-Command flutter -ErrorAction Stop
& $flutter.Source run -d $DeviceId
exit $LASTEXITCODE
