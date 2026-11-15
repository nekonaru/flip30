# scripts/build.ps1 - build release artifacts into dist/
#
#   .\scripts\build.ps1 -Version 1.0.0
#
# Produces:
#   dist/flip30-<version>.love        LOVE archive (all platforms)
#   dist/flip30-<version>-win64.zip   Fused Windows build (no install needed)
#   dist/RELEASE_NOTES.md             Notes from CHANGELOG.md + SHA-256 sums
param(
  [Parameter(Mandatory = $true)]
  [string]$Version,

  # Where LOVE is installed (contains love.exe + DLLs). Auto-detected if omitted.
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

$zipPath = $null
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
  Copy-Item (Join-Path $root "README.id.md") $bundleDir
  Copy-Item (Join-Path $root "LICENSE") $bundleDir
  Copy-Item (Join-Path $root "CHANGELOG.md") $bundleDir
  Copy-Item (Join-Path $root "CHANGELOG.id.md") $bundleDir

  $zipPath = Join-Path $dist "flip30-$Version-win64.zip"
  if (Test-Path $zipPath) { Remove-Item $zipPath -Force }
  Compress-Archive -Path (Join-Path $bundleDir "*") -DestinationPath $zipPath
  Remove-Item $bundleDir -Recurse -Force
  Write-Output "built $zipPath"
} else {
  Write-Warning "LOVE installation not found; skipping the Windows bundle (only the .love was built)."
  Write-Warning "Pass -LovePath 'C:\Program Files\LOVE' to enable it."
}

# ------------------------------------------------------------ release notes
# Notes are bilingual (English first, then Indonesian) and mirror the
# changelogs: same summary sentence, same New features / Improvements /
# Bug fixes sections. Publish with:
#   gh release create vX.Y.Z <artifacts> --title "Flip30 vX.Y.Z" --notes-file dist/RELEASE_NOTES.md
function Get-ReleaseSection($changelogPath, $version) {
  $content = Get-Content $changelogPath -Raw -Encoding UTF8
  $escaped = [regex]::Escape($version)
  $pattern = "(?s)## v${escaped}(\r?\n|$)(.*?)(?=\r?\n## |\z)"
  $match = [regex]::Match($content, $pattern)
  if ($match.Success) {
    return ($match.Groups[2].Value.Trim() -replace '(?m)^### ', '## ')
  }
  return $null
}

$enSection = Get-ReleaseSection (Join-Path $root "CHANGELOG.md") $Version
$idSection = Get-ReleaseSection (Join-Path $root "CHANGELOG.id.md") $Version
$notes = Join-Path $dist "RELEASE_NOTES.md"

if ($enSection -and $idSection) {
  # SHA-256 of the freshly built artifacts; the notes double as a manifest.
  $artifacts = @($loveArchive)
  if ($zipPath) { $artifacts += $zipPath }
  $checksumTable = "| File | SHA-256 |`r`n| --- | --- |`r`n"
  foreach ($file in $artifacts) {
    $hash = (Get-FileHash $file -Algorithm SHA256).Hash
    $checksumTable += "| ``$(Split-Path $file -Leaf)`` | ``$hash`` |`r`n"
  }

  $body = "# English`r`n`r`n" + $enSection + "`r`n`r`n"
  $body += "## Install / Update`r`n`r`n"
  $body += "Download the file for your platform from Assets below, open it and follow the prompts. Use ``flip30-$Version-win64.zip`` on Windows (no install needed). Use ``flip30-$Version.love`` with a LÖVE 11.x install on other platforms.`r`n`r`n"
  $body += "## Verify your download`r`n`r`n"
  $body += "SHA-256 of the artifacts attached to this release:`r`n`r`n" + $checksumTable + "`r`n"
  $body += "Verify with ``Get-FileHash .\flip30-$Version.love -Algorithm SHA256`` (PowerShell)`r`n"
  $body += "or ``shasum -a 256 flip30-$Version.love`` (macOS/Linux).`r`n`r`n"
  $body += "<br>`r`n`r`n---`r`n`r`n<br>`r`n`r`n"
  $body += "# Bahasa Indonesia`r`n`r`n" + $idSection + "`r`n`r`n"
  $body += "## Instalasi / Update`r`n`r`n"
  $body += "Download file untuk platformmu dari Assets di bawah, buka, lalu ikuti petunjuknya. Gunakan ``flip30-$Version-win64.zip`` di Windows (tidak perlu instalasi). Gunakan ``flip30-$Version.love`` dengan instalasi LÖVE 11.x di platform lain.`r`n`r`n"
  $body += "## Verifikasi unduhan`r`n`r`n"
  $body += "SHA-256 dari artifact yang terlampir di rilis ini:`r`n`r`n" + $checksumTable + "`r`n"
  $body += "Verifikasi dengan ``Get-FileHash .\flip30-$Version.love -Algorithm SHA256`` (PowerShell)`r`n"
  $body += "atau ``shasum -a 256 flip30-$Version.love`` (macOS/Linux)."

  Set-Content -Path $notes -Value $body -Encoding UTF8 -NoNewline
  Write-Output "wrote $notes"
} else {
  Write-Warning "could not extract the v$Version section from CHANGELOG.md and CHANGELOG.id.md; $notes not written"
}
