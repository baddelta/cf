# Cloudflare Scripts

## ExportImportZoneFile.py and ExportImportZoneFile.ps1
These scripts complete the following tasks via the Cloudflare API:
- To export DNS records.
- To import records using with a properly formatted file.

The following must be set as environmental variables for the script to work (Applies to both Python and PowerShell versions):
- Zone ID
- Cloudflare Email
- Cloudflare API Key

##ExportImportZoneFileUnattended.ps1
These scripts complete the following tasks via the Cloudflare API:
- To export DNS records.
- To import records using with a properly formatted file. (File must be named "bind_config.txt" and stored in the same location as the script)

The following must be paased when calling the script:
- cloudflareEmail
- cloudflareApiKey
- zoneId

### Example Usage
#### Export
.\ExportImportZoneFileUnattended.ps1 -cloudflareEmail "example@example.com" -cloudflareApiKey "your_api_key" -zoneId "your_zone_id" export
#### Import
.\ExportImportZoneFileUnattended.ps1 -cloudflareEmail "example@example.com" -cloudflareApiKey "your_api_key" -zoneId "your_zone_id" import

[Cloudflare Documentation > Import and export records](https://developers.cloudflare.com/dns/manage-dns-records/how-to/import-and-export/)

[Third-party tool to create BIND zone files](https://pgl.yoyo.org/as/bind-zone-file-creator.php)
