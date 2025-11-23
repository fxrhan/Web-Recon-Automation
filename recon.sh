#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
DOMAIN=""
OUTPUT_DIR=""
SILENT=false

# Function to print banner
print_banner() {
    echo -e "${BLUE}"
    echo "    ____  ____  ___  ____  ____ "
    echo "   / __ \/ __ \/ _ \/ __ \/ __ \\"
    echo "  / /_/ / /_/ /  __/ /_/ / / / /"
    echo " / _, _/ .___/\___/\____/_/ /_/ "
    echo "/_/ |_/_/                       "
    echo "                                "
    echo -e "${NC}"
    echo -e "${YELLOW}Automated Web Reconnaissance Script${NC}"
    echo "-----------------------------------"
}

# Function to display usage
usage() {
    echo -e "Usage: $0 -d <domain> [-o <output_dir>] [-s]"
    echo ""
    echo "Options:"
    echo "  -d    Target domain (required)"
    echo "  -o    Output directory (optional, defaults to domain name)"
    echo "  -s    Silent mode (suppress banner)"
    echo "  -h    Show this help message"
    exit 1
}

# Parse arguments
while getopts "d:o:sh" opt; do
    case $opt in
        d) DOMAIN=$OPTARG ;;
        o) OUTPUT_DIR=$OPTARG ;;
        s) SILENT=true ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Check if domain is provided
if [ -z "$DOMAIN" ]; then
    echo -e "${RED}[!] Error: Domain is required.${NC}"
    usage
fi

# Set output directory if not provided
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="$DOMAIN"
fi

# Print banner unless silent
if [ "$SILENT" = false ]; then
    print_banner
fi

# Function to check dependencies
check_dependencies() {
    echo -e "${BLUE}[*] Checking installed dependencies...${NC}"
    local deps=("assetfinder" "amass" "httprobe" "subjack" "nmap" "waybackurls" "subfinder" "nuclei")
    local missing=false

    for tool in "${deps[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo -e "${RED}[!] $tool is not installed.${NC}"
            missing=true
        else
            echo -e "${GREEN}[+] $tool is installed.${NC}"
        fi
    done

    if [ "$missing" = true ]; then
        echo -e "${RED}[!] Please install missing tools before running this script.${NC}"
        exit 1
    fi
}

# Function to create directories
setup_directories() {
    echo -e "${BLUE}[*] Setting up directory structure in $OUTPUT_DIR...${NC}"
    mkdir -p "$OUTPUT_DIR/recon/scans"
    mkdir -p "$OUTPUT_DIR/recon/httprobe"
    mkdir -p "$OUTPUT_DIR/recon/potential_takeovers"
    mkdir -p "$OUTPUT_DIR/recon/wayback/params"
    mkdir -p "$OUTPUT_DIR/recon/wayback/extensions"
    mkdir -p "$OUTPUT_DIR/recon/nuclei"
    
    # Create placeholder files
    touch "$OUTPUT_DIR/recon/httprobe/alive.txt"
    touch "$OUTPUT_DIR/recon/final.txt"
}

# Main execution flow
check_dependencies
setup_directories

# Function for subdomain enumeration
enumerate_subdomains() {
    echo -e "${BLUE}[*] Starting subdomain enumeration...${NC}"
    
    # Subfinder
    if command -v subfinder &> /dev/null; then
        echo -e "${YELLOW}[*] Running subfinder...${NC}"
        subfinder -d "$DOMAIN" -silent >> "$OUTPUT_DIR/recon/final.txt"
    fi

    # Assetfinder
    if command -v assetfinder &> /dev/null; then
        echo -e "${YELLOW}[*] Running assetfinder...${NC}"
        assetfinder --subs-only "$DOMAIN" >> "$OUTPUT_DIR/recon/final.txt"
    fi

    # Amass (Optional/Background)
    # Uncomment if you want to use amass (it can be slow)
    # if command -v amass &> /dev/null; then
    #     echo -e "${YELLOW}[*] Running amass (this might take a while)...${NC}"
    #     amass enum -d "$DOMAIN" >> "$OUTPUT_DIR/recon/final.txt"
    # fi

    # Deduplicate
    echo -e "${BLUE}[*] Deduplicating subdomains...${NC}"
    sort -u "$OUTPUT_DIR/recon/final.txt" -o "$OUTPUT_DIR/recon/final.txt"
    echo -e "${GREEN}[+] Found $(wc -l < "$OUTPUT_DIR/recon/final.txt") unique subdomains.${NC}"
}

# Function for live host discovery
check_live_hosts() {
    echo -e "${BLUE}[*] Probing for live hosts with httprobe...${NC}"
    cat "$OUTPUT_DIR/recon/final.txt" | httprobe -c 50 | sed 's|https\?://||' | sort -u > "$OUTPUT_DIR/recon/httprobe/alive.txt"
    echo -e "${GREEN}[+] Found $(wc -l < "$OUTPUT_DIR/recon/httprobe/alive.txt") live hosts.${NC}"
}

# Function for subdomain takeover check
check_takeovers() {
    echo -e "${BLUE}[*] Checking for subdomain takeovers...${NC}"
    if command -v subjack &> /dev/null; then
        subjack -w "$OUTPUT_DIR/recon/final.txt" -t 100 -timeout 30 -ssl \
        -c ~/go/src/github.com/haccer/subjack/fingerprints.json \
        -o "$OUTPUT_DIR/recon/potential_takeovers/potential_takeovers.txt" -v
    else
        echo -e "${RED}[!] subjack not found, skipping takeover check.${NC}"
    fi
}

# Function for port scanning
scan_ports() {
    echo -e "${BLUE}[*] Scanning for open ports with Nmap...${NC}"
    nmap -iL "$OUTPUT_DIR/recon/httprobe/alive.txt" -T4 -oA "$OUTPUT_DIR/recon/scans/scanned"
}

# Function for Wayback Machine recon
wayback_recon() {
    echo -e "${BLUE}[*] Scraping Wayback Machine data...${NC}"
    cat "$OUTPUT_DIR/recon/final.txt" | waybackurls | sort -u > "$OUTPUT_DIR/recon/wayback/wayback_output.txt"

    echo -e "${BLUE}[*] Extracting parameters and extensions...${NC}"
    # Extract params
    cat "$OUTPUT_DIR/recon/wayback/wayback_output.txt" | grep '?*=' | cut -d '=' -f 1 | sort -u > "$OUTPUT_DIR/recon/wayback/params/wayback_params.txt"

    # Extract extensions
    for ext in js json php aspx jsp; do
        grep "\.$ext$" "$OUTPUT_DIR/recon/wayback/wayback_output.txt" > "$OUTPUT_DIR/recon/wayback/extensions/$ext.txt"
    done
}

# Function for Nuclei scanning
run_nuclei() {
    echo -e "${BLUE}[*] Running Nuclei vulnerability scan...${NC}"
    if command -v nuclei &> /dev/null; then
        nuclei -l "$OUTPUT_DIR/recon/httprobe/alive.txt" -t nuclei-templates -o "$OUTPUT_DIR/recon/nuclei/nuclei_report.txt"
    else
        echo -e "${RED}[!] Nuclei not found, skipping vulnerability scan.${NC}"
    fi
}

# Function to generate a simple report
generate_report() {
    echo -e "${BLUE}[*] Generating summary report...${NC}"
    REPORT_FILE="$OUTPUT_DIR/report.md"
    
    echo "# Reconnaissance Report for $DOMAIN" > "$REPORT_FILE"
    echo "Date: $(date)" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    echo "## Subdomains" >> "$REPORT_FILE"
    echo "- Total Unique Subdomains: $(wc -l < "$OUTPUT_DIR/recon/final.txt")" >> "$REPORT_FILE"
    echo "- Live Hosts: $(wc -l < "$OUTPUT_DIR/recon/httprobe/alive.txt")" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    echo "## Findings" >> "$REPORT_FILE"
    if [ -s "$OUTPUT_DIR/recon/potential_takeovers/potential_takeovers.txt" ]; then
        echo "### Potential Subdomain Takeovers" >> "$REPORT_FILE"
        cat "$OUTPUT_DIR/recon/potential_takeovers/potential_takeovers.txt" >> "$REPORT_FILE"
    else
        echo "- No subdomain takeovers detected." >> "$REPORT_FILE"
    fi
    echo "" >> "$REPORT_FILE"
    
    echo "## Nuclei Results" >> "$REPORT_FILE"
    if [ -s "$OUTPUT_DIR/recon/nuclei/nuclei_report.txt" ]; then
        echo "### Vulnerabilities Found" >> "$REPORT_FILE"
        cat "$OUTPUT_DIR/recon/nuclei/nuclei_report.txt" >> "$REPORT_FILE"
    else
        echo "- No vulnerabilities found by Nuclei." >> "$REPORT_FILE"
    fi
    
    echo -e "${GREEN}[+] Report generated at $REPORT_FILE${NC}"
}

# Main execution flow
check_dependencies
setup_directories
enumerate_subdomains
check_live_hosts
check_takeovers
scan_ports
wayback_recon
run_nuclei
generate_report

echo -e "${GREEN}[+] All recon tasks completed successfully!${NC}"
