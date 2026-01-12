$ErrorActionPreference = "Stop"

# --- Configuration ---
$Repo      = "chang96/maira-releases"
$ToolName  = "maira-cli"
$AssetName = "maira-cli-windows-x64.exe"
$BinDir    = "$env:USERPROFILE\bin"
$TempFile  = "$env:TEMP\$ToolName.exe"
# ---------------------

# 1. Ensure PowerShell version
if ($PSVersionTable.PSVersion.Major -lt 5) {
  Write-Error "PowerShell 5.0 or higher is required."
}

# 2. Fetch latest release
Write-Host "🔍 Fetching latest release info..."
try {
  $Release = Invoke-RestMethod `
    -Uri "https://api.github.com/repos/$Repo/releases/latest" `
    -Headers @{ "User-Agent" = "maira-cli-installer" }
} catch {
  Write-Error "Failed to fetch release information from GitHub."
}

$Tag = $Release.tag_name
if (-not $Tag) {
  Write-Error "Could not determine latest release tag."
}

# 3. Construct download URL
$DownloadUrl = "https://github.com/$Repo/releases/download/$Tag/$AssetName"
Write-Host "⬇️  Downloading $ToolName ($Tag)..."
Write-Host "    Source: $DownloadUrl"

# 4. Download to temp location
try {
  Invoke-WebRequest `
    -Uri $DownloadUrl `
    -OutFile $TempFile `
    -UseBasicParsing
} catch {
  Write-Error "Download failed."
}

# 5. Verify download
if (-not (Test-Path $TempFile)) {
  Write-Error "Downloaded file not found."
}

if ((Get-Item $TempFile).Length -eq 0) {
  Write-Error "Downloaded file is empty."
}

# 6. Ensure bin directory exists
New-Item -ItemType Directory -Force -Path $BinDir | Out-Null

# 7. Install
Write-Host "📦 Installing to $BinDir..."
Move-Item `
  -Path $TempFile `
  -Destination "$BinDir\$ToolName.exe" `
  -Force

# 8. Add to PATH (idempotent)
$UserPath = [Environment]::GetEnvironmentVariable("PATH", "User")

if ($UserPath -notmatch [Regex]::Escape($BinDir)) {
  [Environment]::SetEnvironmentVariable(
    "PATH",
    "$BinDir;$UserPath",
    "User"
  )
  Write-Host "➕ Added $BinDir to PATH"
} else {
  Write-Host "ℹ️  $BinDir already in PATH"
}

# 9. Verify installation
$ExePath = "$BinDir\$ToolName.exe"
if (-not (Test-Path $ExePath)) {
  Write-Error "Installation failed: executable not found."
}

Write-Host "✅ Successfully installed $ToolName!"
Write-Host "👉 Restart your terminal and run: $ToolName"
