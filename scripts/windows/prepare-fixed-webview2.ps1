param(
  [Parameter(Mandatory=$false)][ValidateSet('x64','x86','arm64')][string]$Arch = 'x64',
  [Parameter(Mandatory=$false)][string]$Version = '133.0.3065.92'
)

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $repoRoot

$srcTauri = Join-Path $repoRoot 'src-tauri'
if (!(Test-Path $srcTauri)) { throw "src-tauri not found: $srcTauri" }

$cabName = "Microsoft.WebView2.FixedVersionRuntime.$Version.$Arch.cab"
$cabUrl  = "https://github.com/westinyang/WebView2RuntimeArchive/releases/download/$Version/$cabName"

Write-Host "[win7-support] Downloading WebView2 FixedVersionRuntime: $cabUrl"
Invoke-WebRequest -Uri $cabUrl -OutFile $cabName

Write-Host "[win7-support] Expanding CAB into src-tauri/..."
Expand .\$cabName -F:* $srcTauri

Write-Host "[win7-support] Switching tauri.windows.conf.json => webview2.$Arch.json"
$targetConf = Join-Path $srcTauri 'tauri.windows.conf.json'
if (Test-Path $targetConf) { Remove-Item $targetConf -Force }
Copy-Item (Join-Path $srcTauri "webview2.$Arch.json") $targetConf -Force

Write-Host "[win7-support] Done. You can now run: pnpm tauri build --target <target>"
