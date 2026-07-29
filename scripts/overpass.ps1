# Overpass API query: businesses of given type in radius, WITHOUT website/contact:website tags.
# Usage: .\scripts\overpass.ps1 -Lat 50.4501 -Lon 30.5234 -Radius 2000 -Type dentist -OutFile data\runs\<id>\candidates.json
# Type: key from the map below OR raw OSM selector "key=value" (e.g. "shop=jewelry").

param(
    [Parameter(Mandatory=$true)][double]$Lat,
    [Parameter(Mandatory=$true)][double]$Lon,
    [Parameter(Mandatory=$true)][int]$Radius,
    [Parameter(Mandatory=$true)][string]$Type,
    [Parameter(Mandatory=$true)][string]$OutFile
)

$typeMap = @{
    'dentist'     = 'amenity=dentist'
    'clinic'      = 'amenity=clinic'
    'vet'         = 'amenity=veterinary'
    'pharmacy'    = 'amenity=pharmacy'
    'cafe'        = 'amenity=cafe'
    'restaurant'  = 'amenity=restaurant'
    'bar'         = 'amenity=bar'
    'beauty'      = 'shop=beauty'
    'hairdresser' = 'shop=hairdresser'
    'car_repair'  = 'shop=car_repair'
    'florist'     = 'shop=florist'
    'bakery'      = 'shop=bakery'
    'tattoo'      = 'shop=tattoo'
    'optician'    = 'shop=optician'
    'lawyer'      = 'office=lawyer'
    'accountant'  = 'office=accountant'
    'fitness'     = 'leisure=fitness_centre'
}

if ($typeMap.ContainsKey($Type)) { $selector = $typeMap[$Type] }
elseif ($Type -match '^[a-z_:]+=[a-z_;|]+$') { $selector = $Type }
else {
    Write-Error "Unknown type '$Type'. Available: $($typeMap.Keys -join ', ') or a raw key=value selector."
    exit 1
}

$key, $value = $selector -split '=', 2

$latS = $Lat.ToString([System.Globalization.CultureInfo]::InvariantCulture)
$lonS = $Lon.ToString([System.Globalization.CultureInfo]::InvariantCulture)

$query = (
    '[out:json][timeout:90];',
    ('nwr["' + $key + '"="' + $value + '"](around:' + $Radius + ',' + $latS + ',' + $lonS + ')->.all;'),
    'nwr.all[!"website"][!"contact:website"];',
    'out center tags;'
) -join "`n"

Write-Host "Overpass: $selector, radius ${Radius}m around $latS,$lonS ..."

$body = 'data=' + [uri]::EscapeDataString($query)
$headers = @{ 'Accept' = 'application/json' }
$ua = 'local-business-site-factory/1.0 (research script; contact via github)'
$mirrors = @(
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter'
)
# PS 5.1 decodes JSON responses without an explicit charset as ISO-8859-1, mangling
# Cyrillic. Take raw bytes and decode as UTF-8 ourselves.
$resp = $null
foreach ($url in $mirrors) {
    try {
        $raw = Invoke-WebRequest -Method Post -Uri $url -UserAgent $ua -Headers $headers `
            -ContentType 'application/x-www-form-urlencoded' -Body $body -TimeoutSec 120 `
            -UseBasicParsing -ErrorAction Stop
        $json = [System.Text.Encoding]::UTF8.GetString($raw.RawContentStream.ToArray())
        $resp = $json | ConvertFrom-Json
        break
    } catch {
        Write-Warning "Mirror failed: $url ($($_.Exception.Message))"
    }
}
if ($null -eq $resp) { Write-Error 'All Overpass mirrors failed.'; exit 1 }

$results = @()
foreach ($el in $resp.elements) {
    $t = $el.tags
    if ($null -eq $t) { continue }
    if ($el.type -eq 'node') { $elat = $el.lat; $elon = $el.lon }
    else { $elat = $el.center.lat; $elon = $el.center.lon }
    $phone = $null
    if ($t.phone) { $phone = $t.phone } elseif ($t.'contact:phone') { $phone = $t.'contact:phone' }
    $results += [pscustomobject]@{
        osm_id  = "$($el.type)/$($el.id)"
        name    = $t.name
        lat     = $elat
        lon     = $elon
        phone   = $phone
        street  = $t.'addr:street'
        housenr = $t.'addr:housenumber'
        city    = $t.'addr:city'
        hours   = $t.opening_hours
        brand   = $t.brand
        socials = @($t.'contact:instagram', $t.'contact:facebook') | Where-Object { $_ }
        tags    = $t
    }
}

$dir = Split-Path $OutFile -Parent
if ($dir -and -not (Test-Path $dir)) { New-Item -ItemType Directory -Force $dir | Out-Null }

ConvertTo-Json @($results) -Depth 6 | Out-File -FilePath $OutFile -Encoding utf8
Write-Host "Found without website tag: $($results.Count) -> $OutFile"
