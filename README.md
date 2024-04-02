# Cloudflare Scripts

## ExportImport Zone File
These scripts complete the following tasks via the Cloudflare API:
- To export DNS records.
- To import records using with a properly formatted file.

The following must be set as environmental variables for the script to work (Applies to both Python and PowerShell versions):
- Zone ID
- Cloudflare Email
- Cloudflare API Key

[Cloudflare Documentation > Import and export records](https://developers.cloudflare.com/dns/manage-dns-records/how-to/import-and-export/)

[Third-party tool to create BIND zone files](https://pgl.yoyo.org/as/bind-zone-file-creator.php)
