# scripts/build.ps1 â€” build release artifacts into dist/
#
#   .\scripts\build.ps1 -Version 1.0.0
#
# Produces:
#   dist/flip30-<version>.love        LÃ–VE archive (all platforms)
#   dist/flip30-<version>-win64.zip   Fused Windows build (no install needed)
#   dist/RELEASE_NOTES.md             Notes extracted from CHANGELOG.md
param(
  [Parameter(Mandatory = $true)]
  [string]$Version,

  # Where LÃ–VE is installed (contains love.exe + DLLs). Auto-detected if omitted.
  [string]$LovePath
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$dist = Join-Path $root "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null

# ---------------------------------------------------------------- .love file
$loveArchive = Join-Path $dist "flip30-$Version.love"
if (Test-Path $loveArchive) { Remove-Item $loveArchive -Force }

$gameFiles = @(
  "conf.lua",
  "main.lua",
  "LICENSE",
  "README.md",
  "src",
  "rules",
  "assets/brand"
)

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$archive = [System.IO.Compression.ZipFile]::Open($loveArchive, [System.IO.Compression.ZipArchiveMode]::Create)
try {
  foreach ($entry in $gameFiles) {
    $full = Join-Path $root $entry
    if (Test-Path $full -PathType Leaf) {
      [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
        $archive, $full, $entry, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
    } else {
      Get-ChildItem $full -Recurse -File | ForEach-Object {
        $relative = $_.FullName.Substring($root.Length).TrimStart('\', '/') -replace '\\', '/'
        [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
          $archive, $_.FullName, $relative, [System.IO.Compression.CompressionLevel]::Optimal) | Out-Null
      }
    }
  }
} finally {
  $archive.Dispose()
}
Write-Output "built $loveArchive"

# ------------------------------------------------------- Windows fused build
if (-not $LovePath) {
  foreach ($candidate in @("$env:ProgramFiles\LOVE", "${env:ProgramFiles(x86)}\LOVE")) {
    if (Test-Path (Join-Path $candidate "love.exe")) { $LovePath = $candidate; break }
  }
}

$bundleDir = Join-Path $dist "flip30-$Version-win64"
if (Test-Path $bundleDir) { Remove-Item $bundleDir -Recurse -Force }
New-Item -ItemType Directory -Force -Path $bundleDir | Out-Null

if ($LovePath -and (Test-Path (Join-Path $LovePath "love.exe"))) {
  Copy-Item (Join-Path $LovePath "*") $bundleDir -Recurse -Force
  $exe = Join-Path $bundleDir "love.exe"
  $fused = Join-Path $bundleDir "Flip30.exe"
  Rename-Item $exe $fused
  Remove-Item (Join-Path $bundleDir "lovec.exe") -ErrorAction SilentlyContinue
  Remove-Item (Join-Path $bundleDir "changes.txt") -ErrorAction SilentlyContinue
  Remove-Item (Join-Path $bundleDir "game.ico") -ErrorAction SilentlyContinue
  Remove-Item (Join-Path $bundleDir "love.ico") -ErrorAction SilentlyContinue
  Remove-Item (Join-Path $bundleDir "Uninstall.exe") -ErrorAction SilentlyContinue

  # Fuse: append the .love archive to the executable
  $bytes = [System.IO.File]::ReadAllBytes($loveArchive)
  $stream = [System.IO.File]::Open($fused, [System.IO.FileMode]::Append)
  try {
    $stream.Write($bytes, 0, $bytes.Length)
  } finally {
    $stream.Dispose()
  }
  Copy-Item (Join-Path $root "README.md") $bundleDir
  Copy-Item (Join-Path $root "LICENSE") $bundleDir
  Copy-Item (Join-Path $root "CHANGELOG.md") $bundleDir

  $zipPath = Join-Path $dist "flip30-$Version-win64.zip"
  if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
  Compress-Archive -Path (Join-Path $bundleDir "*") -DestinationPath $zipPath
  Remove-Item $bundleDir -Recurse -Force
  Write-Output "built $zipPath"
} else {
  Write-Warning "LÃ–VE installation not found; skipping the Windows bundle (only the .love was built)."
  Write-Warning "Pass -LovePath 'C:\Program Files\LOVE' to enable it."
}

# ------------------------------------------------------------ release notes
$changelog = Join-Path $root "CHANGELOG.md"
$notes = Join-Path $dist "RELEASE_NOTES.md"
$content = Get-Content $changelog -Raw
$escaped = [regex]::Escape($Version)
$pattern = "(?s)## \[${escaped}\][^\n]*\r?\n(.*?)(?=\r?\n## \[|\z)"
$match = [regex]::Match($content, $pattern)
if ($match.Success) {
  $body = "# Flip30 v$Version`r`n`r`n" + $match.Groups[1].Value.Trim() + "`r`n"
  Set-Content -Path $notes -Value $body -Encoding utf8 -NoNewline
  Write-Output "wrote $notes"
} else {
  Write-Warning "could not extract [$Version] from CHANGELOG.md; $notes not written"
}
