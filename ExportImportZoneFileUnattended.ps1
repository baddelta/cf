param (
    [string]$cloudflareEmail,
    [string]$cloudflareApiKey,
    [string]$zoneId
)

# Function to export DNS zone file
function Export-DNSZone {
    param (
        [string]$cloudflareEmail,
        [string]$cloudflareApiKey,
        [string]$zoneId
    )

    $headers = @{
        "Content-Type" = "application/json"
        "X-Auth-Email" = $cloudflareEmail
        "X-Auth-Key" = $cloudflareApiKey
    }

    $uri = "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records/export"

    try {
        $response = Invoke-WebRequest -Uri $uri -Method GET -Headers $headers -UseBasicParsing
        $responseString = [System.Text.Encoding]::UTF8.GetString($response.RawContentStream.ToArray())
        Write-Host "Response content: $responseString"

        $exportedFileName = "exported_dns_zone_$zoneId.txt"
        $response.RawContentStream.Position = 0
        $reader = [System.IO.StreamReader]::new($response.RawContentStream)
        $fileContent = $reader.ReadToEnd()
        $reader.Close()
        $fileContent | Set-Content -Path $exportedFileName -Encoding UTF8 -Force
        Write-Host "DNS Zone file exported successfully to $exportedFileName"
    } catch {
        Write-Error "Failed to export DNS Zone file: $_"
    }
}

# Function to import DNS zone file
function Import-DNSZone {
    param (
        [string]$cloudflareEmail,
        [string]$cloudflareApiKey,
        [string]$zoneId
    )

    $filePath = ".\bind_config.txt"
    if (-not (Test-Path $filePath)) {
        Write-Host "The file $filePath does not exist."
        return
    }
    $fileContent = Get-Content $filePath -Raw

    $boundary = "----WebKitFormBoundary7MA4YWxkTrZu0gW"
    $headers = @{
        "Content-Type" = "multipart/form-data; boundary=$boundary"
        "X-Auth-Email" = $cloudflareEmail
        "X-Auth-Key" = $cloudflareApiKey
    }

    $body = @"
--$boundary
Content-Disposition: form-data; name="file"; filename="bind_config.txt"
Content-Type: text/plain

$fileContent

--$boundary--
"@

    $uri = "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records/import"

    try {
        $response = Invoke-WebRequest -Uri $uri -Method POST -Headers $headers -Body $body -ContentType "multipart/form-data; boundary=$boundary"
        $responseContent = $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
        $responseFileName = "importResponse_$zoneId.txt"
        $responseContent | Out-File -FilePath $responseFileName -Encoding UTF8 -Force
        Write-Host "Import response saved successfully to $responseFileName"
    } catch {
        Write-Error "Failed to import DNS Zone file: $_"
    }
}

# Determine action based on script arguments
switch ($args[0]) {
    "export" {
        Export-DNSZone -cloudflareEmail $cloudflareEmail -cloudflareApiKey $cloudflareApiKey -zoneId $zoneId
    }
    "import" {
        Import-DNSZone -cloudflareEmail $cloudflareEmail -cloudflareApiKey $cloudflareApiKey -zoneId $zoneId
    }
    default {
        Write-Host "Unsupported command. Use 'export' or 'import'."
    }
}
