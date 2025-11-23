# Web Recon Automation

A powerful, automated reconnaissance script for bug bounty hunters and penetration testers. This script streamlines the process of subdomain enumeration, live host discovery, vulnerability scanning, and reporting.

## 🚀 Features

*   **Automated Dependency Checks**: Ensures all required tools are installed before running.
*   **Subdomain Enumeration**: Uses `subfinder` and `assetfinder` to discover subdomains.
*   **Live Host Discovery**: Probes for alive hosts using `httprobe`.
*   **Subdomain Takeover**: Checks for potential subdomain takeovers using `subjack`.
*   **Port Scanning**: Scans for open ports using `nmap`.
*   **Wayback Machine Recon**: Extracts parameters and interesting file extensions from the Wayback Machine.
*   **Vulnerability Scanning**: Integrates `nuclei` for automated vulnerability detection.
*   **Reporting**: Generates a summary Markdown report (`report.md`).

## 🛠️ Tools Used

Ensure you have the following tools installed and in your PATH:

*   [Subfinder](https://github.com/projectdiscovery/subfinder)
*   [Assetfinder](https://github.com/tomnomnom/assetfinder)
*   [Httprobe](https://github.com/tomnomnom/httprobe)
*   [Subjack](https://github.com/haccer/subjack)
*   [Nmap](https://nmap.org/)
*   [Waybackurls](https://github.com/tomnomnom/waybackurls)
*   [Nuclei](https://github.com/projectdiscovery/nuclei)

## 📥 Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/fxrhan/Web-Recon-Automation.git
    cd Web-Recon-Automation
    ```
2.  Make the script executable:
    ```bash
    chmod +x recon.sh
    ```

## 📖 Usage

```bash
./recon.sh -d <domain> [-o <output_dir>] [-s]
```

### Options

*   `-d <domain>`: Target domain (e.g., `example.com`). **Required**.
*   `-o <output_dir>`: Custom output directory. Defaults to the domain name.
*   `-s`: Silent mode. Suppresses the banner.
*   `-h`: Show help message.

### Example

```bash
./recon.sh -d tesla.com
```

## 📂 Output Structure

The script creates the following directory structure:

```
domain.com/
├── recon/
│   ├── final.txt                 # Unique subdomains
│   ├── httprobe/
│   │   └── alive.txt             # Live hosts
│   ├── potential_takeovers/      # Takeover results
│   ├── scans/                    # Nmap scans
│   ├── wayback/                  # Wayback data
│   │   ├── params/               # Extracted parameters
│   │   └── extensions/           # File extensions (js, php, etc.)
│   └── nuclei/                   # Nuclei report
└── report.md                     # Summary report
```

## 📝 License

This project is licensed under the MIT License.
