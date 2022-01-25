# Web-Recon-Automation
A bash script to automate the necessary Reconnaissance task for websites. <br>
NOTE: This is not some major project. I just created this script because in my opinion the Reconnaissance Phase was too time consuming and I had to write almost the same set of commands on different websites. <br>
This scirpt automates that process and save your precious time.

# What does this script do?
- Harvests all the Sub-domains with Assetfinder and Amass. (It also filters duplicate subdomains)
- Checks if the domains discovered are working or not.
- Checks for possible Sub-domain takeover using Subjack tool.
- Scans all the Sub-domains for open ports with Nmap.
- Scrapes wayback data and compile all possible parameters in wayback data.
- Runs EyeWitness against all the compiled domains.

# Usage
- Open the Linux/Mac terminal and run the following command :
- ``` chmod +x recon.sh ``` 
- ``` sudo ./recon.sh domain-name ```
- Now just sit back and enjoy your cup of coffee and let it do your work.

# Requirements
For this script to work you need to have the following tools installed on you machine :-
- <p> <a href="https://github.com/tomnomnom/assetfinder">AssetFinder</a></p>
- <p><a href="https://github.com/OWASP/Amass">Amass</a></p>
- <p><a href="https://github.com/tomnomnom/httprobe">HTTPROBE</a></p>
- <p><a href="https://github.com/haccer/subjack">Subjack</a></p>
- <p><a href="https://github.com/tomnomnom/waybackurls">WaybackUrls</a></p>
- <p><a href="https://github.com/aboul3la/Sublist3r">Sublist3r</a></p>
- <p><a href="https://github.com/FortyNorthSecurity/EyeWitness">EyeWitness</a></p>
-  Also, have GoLang installed on you machine.

# Wait a min
As usual, this is an open-source project. Feel free to make any changes are per your specific needs. <br>
Happy Hacking :)
