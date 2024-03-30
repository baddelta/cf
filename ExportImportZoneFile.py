import http.client
import os

# Configuration variables
cf_zone_id = os.getenv("CF_ZONE_ID")
cf_email = os.getenv("CF_EMAIL")
cf_api_key = os.getenv("CF_API_KEY")
filename_to_import = "bind_config.txt" # Assumes this file exists in the same folder

def export_dns_records(cf_zone_id, cf_email, cf_api_key):
    conn = http.client.HTTPSConnection("api.cloudflare.com")
    headers = {
        'Content-Type': "application/json",
        'X-Auth-Email': cf_email,
        'X-Auth-Key': cf_api_key,
    }
    conn.request("GET", f"/client/v4/zones/{cf_zone_id}/dns_records/export", headers=headers)
    res = conn.getresponse()
    data = res.read()

    decoded_data = data.decode("utf-8")
    print(decoded_data)  # Print the exported data

    # Save the exported data to a file
    with open("dns_records_export.txt", "w") as file:
        file.write(decoded_data)
    print("Exported DNS records have been saved to 'dns_records_export.txt'.")

def import_dns_records(cf_zone_id, cf_email, cf_api_key, filename):
    # Open and read the DNS records file
    with open(filename, 'r') as file:
        dns_records = file.read()

    boundary = "011000010111000001101001"
    payload = f"""--{boundary}\r\nContent-Disposition: form-data; name=\"file\"\r\n\r\n{dns_records}\r\n--{boundary}--\r\n"""
    
    headers = {
        'Content-Type': f"multipart/form-data; boundary={boundary}",
        'X-Auth-Email': cf_email,
        'X-Auth-Key': cf_api_key,
    }

    conn = http.client.HTTPSConnection("api.cloudflare.com")
    conn.request("POST", f"/client/v4/zones/{cf_zone_id}/dns_records/import", payload, headers)
    res = conn.getresponse()
    data = res.read()

    # Save the response as binary
    with open("import-response.json", "wb") as file:
        file.write(data)
    print("Import operation response has been saved to 'import-response.json' in its original format.")

def main_menu():
    print("Select an operation to perform:")
    print("1. Export DNS Records")
    print("2. Import DNS Records")
    choice = input("Enter your choice (1 or 2): ")

    if choice == '1':
        export_dns_records(cf_zone_id, cf_email, cf_api_key)
    elif choice == '2':
        # Directly use the predefined filename for importing without asking the user
        import_dns_records(cf_zone_id, cf_email, cf_api_key, filename_to_import)
    else:
        print("Invalid choice. Please enter 1 or 2.")

if __name__ == "__main__":
    main_menu()