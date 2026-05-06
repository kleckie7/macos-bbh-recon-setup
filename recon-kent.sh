#!/bin/zsh
DOMAIN="kentlphotography.com"
echo "=== Full recon on $DOMAIN ==="

subfinder -d $DOMAIN -o subs.txt
cat subs.txt 2>/dev/null | sort -u > all_subs.txt
httpx -l all_subs.txt -o live.txt

sudo nmap -Pn -sV -sC -T3 $DOMAIN -oN nmap.txt

ffuf -u https://$DOMAIN/FUZZ -w ~/SecLists/Discovery/Web-Content/common.txt -mc 200,204,301,302,307,401,403 -o fuzz.json -t 50

# === Visual recon (screenshots) - slower to avoid rate limits ===
mkdir -p ~/screenshots
echo "Taking screenshots (this may take 20-40 seconds)..."
gowitness scan file -f live.txt --screenshot-path ~/screenshots/ --delay 5

# === Full fingerprint & vulnerability scan ===
echo "Running nikto scan..."
nikto -h https://$DOMAIN -o ~/nikto.txt -Tuning x -maxtime 300

echo "✅ Full recon complete!"
echo "Screenshots → ~/screenshots/"
echo "Nikto report → ~/nikto.txt"
ls -l ~/screenshots/ | tail -5
