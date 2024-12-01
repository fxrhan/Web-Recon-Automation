# Automated Reconnaissance Script
## Overview
This Bash script automates the reconnaissance phase for penetration testing and bug bounty hunting. It identifies subdomains, checks for alive domains, scans for potential vulnerabilities, and gathers useful data like wayback URLs, open ports, and JavaScript files. 
The script is optimized for efficiency and uses popular tools to streamline the reconnaissance process.
## Features
- Harvests subdomains using **AssetFinder** and **Amass**.
- Checks for alive domains with **httprobe**.
- Scans for potential subdomain takeovers using **Subjack**.
- Identifies open ports using **Nmap**.
- Scrapes Wayback Machine data for parameters and file extensions.
- Categorizes important files (e.g., `.js`, `.json`, `.php`) for further analysis.
- Generates screenshots of live domains with **EyeWitness**.
## Dependencies
Ensure the following tools are installed and added to your `PATH`:
- [AssetFinder](https://github.com/tomnomnom/assetfinder)
- [Amass](https://github.com/OWASP/Amass)
- [httprobe](https://github.com/tomnomnom/httprobe)
- [Subjack](https://github.com/haccer/subjack)
- [Nmap](https://nmap.org/)
- [Waybackurls](https://github.com/tomnomnom/waybackurls)
- [EyeWitness](https://github.com/FortyNorthSecurity/EyeWitness)
## Setup
1. Clone the repository or download the script.
2. Ensure the script has execute permissions:
   ```bash
   chmod +x recon_script.sh
## Usage
Run the script with the target domain as an argument:
```bash
./recon_script.sh <target_domain>
For example:
./recon_script.sh google.com
```
## Generated Output
```bash
<target_domain>/
└── recon/
    ├── eyewitness/
    ├── httprobe/
    │   └── alive.txt
    ├── potential_takeovers/
    │   └── potential_takeovers.txt
    ├── scans/
    │   └── scanned.txt
    ├── wayback/
    │   ├── wayback_output.txt
    │   ├── params/
    │   │   └── wayback_params.txt
    │   └── extensions/
    │       ├── js.txt
    │       ├── php.txt
    │       ├── json.txt
    │       ├── jsp.txt
    │       └── aspx.txt
    └── final.txt
```
## Customization
You can modify the script to include additional tools or steps:
- Add more file extensions for extraction.
- Integrate custom tools or APIs.
## Disclaimer
This script is intended for ethical hacking, penetration testing, and bug bounty purposes with proper authorization. Unauthorized usage against targets is illegal and unethical.
## Contributing
Feel free to submit issues, suggest features, or create pull requests to improve the script.







