#!/bin/bash

# Check if a URL is provided, otherwise exit with usage instructions
if [ -z "$1" ]; then
    echo "Usage: $0 <url>"
    exit 1
fi

url=$1

# Function to create directories if they do not exist
create_dir() {
    [ ! -d "$1" ] && mkdir -p "$1"
}

# Setting up directory structure
echo "[+] Setting up directories..."
create_dir "$url/recon/eyewitness"       # For storing screenshots from EyeWitness
create_dir "$url/recon/scans"            # For storing Nmap scan results
create_dir "$url/recon/httprobe"         # For storing live domain results
create_dir "$url/recon/potential_takeovers" # For storing potential takeover findings
create_dir "$url/recon/wayback/params"   # For storing parameters extracted from Wayback data
create_dir "$url/recon/wayback/extensions" # For categorizing Wayback file extensions

# Ensure required files exist for downstream processing
touch "$url/recon/httprobe/alive.txt" "$url/recon/final.txt"

# Subdomain enumeration using assetfinder
echo "[+] Harvesting subdomains with assetfinder..."
assetfinder --subs-only "$url" | grep "$url" >> "$url/recon/final.txt" &

# Subdomain enumeration using amass
echo "[+] Double-checking with amass..."
amass enum -d "$url" >> "$url/recon/final.txt" &
wait # Wait for background processes to finish

# Deduplicate subdomains to avoid redundant processing
echo "[+] Removing duplicate subdomains..."
sort -u "$url/recon/final.txt" -o "$url/recon/final.txt"

# Probing for live domains with httprobe
echo "[+] Probing for alive domains..."
cat "$url/recon/final.txt" | httprobe -c 50 | sed 's|https\?://||' > "$url/recon/httprobe/alive.txt"

# Subdomain takeover check using Subjack
echo "[+] Checking for subdomain takeovers..."
subjack -w "$url/recon/final.txt" -t 100 -timeout 30 -ssl \
-c ~/go/src/github.com/haccer/subjack/fingerprints.json \
-o "$url/recon/potential_takeovers/potential_takeovers.txt"

# Port scanning with Nmap
echo "[+] Scanning for open ports..."
nmap -iL "$url/recon/httprobe/alive.txt" -T4 -oA "$url/recon/scans/scanned"

# Scraping Wayback Machine data
echo "[+] Scraping Wayback Machine data..."
cat "$url/recon/final.txt" | waybackurls | sort -u > "$url/recon/wayback/wayback_output.txt"

# Extracting parameters from Wayback Machine data
echo "[+] Extracting parameters from Wayback Machine data..."
cat "$url/recon/wayback/wayback_output.txt" | grep '?*=' | cut -d '=' -f 1 | sort -u > "$url/recon/wayback/params/wayback_params.txt"

# Categorizing files by extensions
echo "[+] Extracting specific file extensions from Wayback Machine data..."
while read -r line; do
    ext="${line##*.}"
    case "$ext" in
        js) echo "$line" >> "$url/recon/wayback/extensions/js.txt" ;;
        json) echo "$line" >> "$url/recon/wayback/extensions/json.txt" ;;
        php) echo "$line" >> "$url/recon/wayback/extensions/php.txt" ;;
        aspx) echo "$line" >> "$url/recon/wayback/extensions/aspx.txt" ;;
        jsp) echo "$line" >> "$url/recon/wayback/extensions/jsp.txt" ;;
    esac
done < "$url/recon/wayback/wayback_output.txt"

# Running EyeWitness for screenshots
echo "[+] Running EyeWitness on live domains..."
python3 EyeWitness/EyeWitness.py --web -f "$url/recon/httprobe/alive.txt" -d "$url/recon/eyewitness" --resolve

echo "[+] Recon stage completed successfully!"
