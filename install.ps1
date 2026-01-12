$repo = "chang96/maira-releases"
$tool = "maira-cli"
$asset = "maira-cli-windows-x64.exe"

# Get latest release
$release = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest"
$tag = $release.tag_name

# Download
$url = "https://github.com/$repo/releases/download/$tag/$asset"
$dest = "$env:USERPROFILE\maira-cli.exe"

Write-Host "Downloading $tool $tag..."
Invoke-WebRequest $url -OutFile $dest

# Add to PATH
$binDir = "$env:USERPROFILE\bin"
New-Item -ItemType Directory -Force -Path $binDir | Out-Null
Move-Item $dest "$binDir\$tool.exe" -Force

[Environment]::SetEnvironmentVariable(
  "PATH",
  "$binDir;$([Environment]::GetEnvironmentVariable('PATH', 'User'))",
  "User"
)

Write-Host "✅ Installed maira-cli"
Write-Host "Restart your terminal and run: maira-cli"
