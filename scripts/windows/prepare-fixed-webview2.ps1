param(
  [Parameter(Mandatory=$false)][ValidateSet('x64','x86','arm64')][string]$Arch = 'x64',
  [Parameter(Mandatory=$false)][string]$Version = '133.0.3065.92',
  [Parameter(Mandatory=$false)][string]$ConfigMode = 'fixed',
  [Parameter(Mandatory=$false)][switch]$SkipDownload
)

$ErrorActionPreference = 'Stop'

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
Set-Location $repoRoot

$srcTauri = Join-Path $repoRoot 'src-tauri'
if (!(Test-Path $srcTauri)) { throw "src-tauri not found: $srcTauri" }

function Use-FixedConfig {
  param([string]$arch, [string]$version)
  Write-Host "[win7-support] Switching tauri.windows.conf.json => webview2.$arch.json"
  $targetConf = Join-Path $srcTauri 'tauri.windows.conf.json'
  if (Test-Path $targetConf) { Remove-Item $targetConf -Force }
  Copy-Item (Join-Path $srcTauri "webview2.$arch.json") $targetConf -Force

  # Patch fixed runtime path to match selected version/arch
  $raw = Get-Content $targetConf -Raw
  $patched = $raw -replace 'Microsoft\.WebView2\.FixedVersionRuntime\.[^"/]+\.' + $arch, "Microsoft.WebView2.FixedVersionRuntime.$version.$arch"
  if ($patched -ne $raw) {
    Set-Content -Path $targetConf -Value $patched -Encoding UTF8
    Write-Host "[win7-support] Patched fixed runtime path => Microsoft.WebView2.FixedVersionRuntime.$version.$arch"
  }
}

function Use-BootstrapperConfig {
  Write-Host "[win7-support] Using original embedBootstrapper config (no changes)"
}

if ($ConfigMode -eq 'fixed') {
  $cabName = "Microsoft.WebView2.FixedVersionRuntime.$Version.$Arch.cab"
  $cabUrl  = "https://github.com/westinyang/WebView2RuntimeArchive/releases/download/$Version/$cabName"

  if (-not $SkipDownload) {
    Write-Host "[win7-support] Downloading WebView2 FixedVersionRuntime: $cabUrl"
    Invoke-WebRequest -Uri $cabUrl -OutFile $cabName
  } else {
    Write-Host "[win7-support] SkipDownload enabled (expect CAB file already present): $cabName"
    if (!(Test-Path $cabName)) { throw "CAB not found: $cabName" }
  }

  Write-Host "[win7-support] Expanding CAB into src-tauri/..."
  Expand .\$cabName -F:* $srcTauri

  Use-FixedConfig -arch $Arch

  Write-Host "[win7-support] Done. Next: pnpm tauri build --target <target>"
  Write-Host "[win7-support] Tip: you can try older WebView2 versions via -Version <ver> if Win7 fails."
}
elseif ($ConfigMode -eq 'bootstrapper') {
  Use-BootstrapperConfig
}
else {
  throw "Unknown ConfigMode: $ConfigMode (use 'fixed' or 'bootstrapper')"
}
