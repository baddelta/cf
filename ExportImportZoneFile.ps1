# Use Cloudflare email, Zone ID and API key from environment variables
$cloudflareEmail = $env:CLOUDFLARE_EMAIL
$cloudflareApiKey = $env:CLOUDFLARE_API_KEY
$zoneId = $env:CLOUDFLARE_ZONE_ID

# Print the environment variables for verification
Write-Host "Cloudflare Email: $($env:CLOUDFLARE_EMAIL)"
Write-Host "Cloudflare API Key: $($env:CLOUDFLARE_API_KEY)"
Write-Host "Cloudflare Zone ID: $($env:CLOUDFLARE_ZONE_ID)"

# Function to export DNS zone file
function Export-DNSZone {
    $cloudflareEmail = $env:CLOUDFLARE_EMAIL
    $cloudflareApiKey = $env:CLOUDFLARE_API_KEY
    $zoneId = $env:CLOUDFLARE_ZONE_ID

    $headers = @{
        "Content-Type" = "application/json"
        "X-Auth-Email" = $cloudflareEmail
        "X-Auth-Key" = $cloudflareApiKey
    }

    $uri = "https://api.cloudflare.com/client/v4/zones/$zoneId/dns_records/export"

    try {
        $response = Invoke-WebRequest -Uri $uri -Method GET -Headers $headers -UseBasicParsing

        # Attempting to handle the response as a string directly for display
        $responseString = [System.Text.Encoding]::UTF8.GetString($response.RawContentStream.ToArray())
        Write-Host "Response content: $responseString"

        # Prompt for saving the response
        $saveResponse = Read-Host "Do you want to save the response to a file? (Y/N)"
        if ($saveResponse -eq "Y" -or $saveResponse -eq "y") {
            $exportedFileName = "exported_dns_zone_$zoneId.txt"
            # Saving the response content directly from the RawContentStream
            $response.RawContentStream.Position = 0 # Reset stream position before reading
            $reader = [System.IO.StreamReader]::new($response.RawContentStream)
            $fileContent = $reader.ReadToEnd()
            $reader.Close()
            $fileContent | Set-Content -Path $exportedFileName -Encoding UTF8 -Force
            Write-Host "DNS Zone file exported successfully to $exportedFileName"
        }
    } catch {
        Write-Error "Failed to export DNS Zone file: $_"
    }
}

# Function to import DNS zone file
function Import-DNSZone {
    $cloudflareEmail = $env:CLOUDFLARE_EMAIL
    $cloudflareApiKey = $env:CLOUDFLARE_API_KEY
    $zoneId = $env:CLOUDFLARE_ZONE_ID

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
        
        # Convert the response content to a JSON string
        $responseContent = $response.Content | ConvertFrom-Json | ConvertTo-Json -Depth 10
        
        # Define the path for the response file
        $responseFileName = "importResponse_$zoneId.txt"
        
        # Save the response content to the file
        $responseContent | Out-File -FilePath $responseFileName -Encoding UTF8 -Force

        Write-Host "Import response saved successfully to $responseFileName"
    } catch {
        Write-Error "Failed to import DNS Zone file: $_"
    }
}

# Main menu loop
do {
    Write-Host "Please select an option:"
    Write-Host "1. Export DNS Zone file"
    Write-Host "2. Import DNS Zone file"
    Write-Host "3. Exit"
    $option = Read-Host "Enter your choice (1, 2, 3)"

    switch ($option) {
        "1" {
            Export-DNSZone
        }
        "2" {
            Import-DNSZone
        }
        "3" {
            Write-Host "Exiting..."
            break
        }
        default {
            Write-Host "Invalid option, please choose 1, 2, or 3."
        }
    }
} while ($option -ne "3")
