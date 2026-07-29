# QR code for a demo link. Free api.qrserver.com, no key needed.
# Usage: .\scripts\qr.ps1 -Url "https://..." -OutFile sites\<slug>\qr.png
param(
    [Parameter(Mandatory=$true)][string]$Url,
    [Parameter(Mandatory=$true)][string]$OutFile
)

$dir = Split-Path $OutFile -Parent
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }

$api = 'https://api.qrserver.com/v1/create-qr-code/?size=600x600&margin=20&data=' + [uri]::EscapeDataString($Url)
Invoke-WebRequest -Uri $api -OutFile $OutFile -UseBasicParsing -TimeoutSec 60
Write-Host "$OutFile <- $Url"
