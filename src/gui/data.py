#!/usr/bin/env python3
"""Data models and metadata for sudo-make-me-a-sandwich GUI."""

from dataclasses import dataclass, field
import importlib
import os
from pathlib import Path
import re
import shutil

PROJECT_ROOT = Path(__file__).resolve().parent.parent.parent

CATEGORIES = [
    ("browsers", "Browsers", "🌐"),
    ("productivity", "Productivity", "💼"),
    ("ides", "IDEs & Editors", "💻"),
    ("terminals", "Terminals", "🖥️"),
    ("shells", "Shells", "🐚"),
    ("dev_tools", "Dev Tools", "🔧"),
    ("languages", "Languages", "📜"),
    ("pentest", "Pentesting", "🛡️"),
    ("frameworks", "Frameworks", "🧱"),
    ("agentic_ides", "Agentic IDEs", "🤖"),
]

# Supplementary descriptions and tips for pentest tools and any missing tools
EXTRA_TOOL_DESCRIPTIONS: dict[str, tuple[str, list[str]]] = {
    "nmap": (
        "Industry-standard network exploration tool and security/port scanner.",
        [
            "Syntax: nmap -sC -sV -p- <target> for full service scan",
            "Fast scan: nmap -T4 -F <target>",
            "NSE scripts: nmap --script vuln <target> for known vulnerabilities",
        ],
    ),
    "masscan": (
        "Ultra-fast TCP port scanner; capable of scanning the entire Internet in minutes.",
        [
            "Transmits SYN packets asynchronously without maintaining state",
            "Syntax: masscan -p80,443 192.168.1.0/24 --rate=1000",
            "Always specify --rate carefully to avoid saturating network links",
        ],
    ),
    "netcat-openbsd": (
        "TCP/IP swiss army knife for reading and writing connections across networks.",
        [
            "Banner grabbing: nc -v -n <ip> <port>",
            "Simple listener: nc -lvnp <port>",
            "File transfer: nc -lvnp 9000 > file.bin (receiver) / nc <ip> 9000 < file.bin (sender)",
        ],
    ),
    "rustscan": (
        "Extremely fast modern port scanner powered by Rust with automatic Nmap piping.",
        [
            "Discovers open ports in milliseconds, then triggers nmap on findings",
            "Syntax: rustscan -a <target> -- -A -sC",
            "Highly customizable batch sizes and timeouts",
        ],
    ),
    "gobuster": (
        "Fast directory, DNS subdomain, and virtual host bruteforcer written in Go.",
        [
            "Directory busting: gobuster dir -u <url> -w <wordlist>",
            "DNS subdomain discovery: gobuster dns -d <domain> -w <wordlist>",
            "VHost busting: gobuster vhost -u <url> -w <wordlist>",
        ],
    ),
    "ffuf": (
        "Blazing fast web fuzzer written in Go for discovering endpoints, parameters, and headers.",
        [
            "Syntax: ffuf -u http://target.com/FUZZ -w wordlist.txt",
            "Filter responses: -fc 404 (filter status code), -fs 1234 (filter response size)",
            "Post data fuzzing: ffuf -u <url> -X POST -d 'user=FUZZ' -w <wordlist>",
        ],
    ),
    "nikto": (
        "Comprehensive web server vulnerability scanner for dangerous files and misconfigurations.",
        [
            "Standard scan: nikto -h <target_url>",
            "SSL scan: nikto -h <target_url> -ssl",
            "Exports reports to HTML, XML, or CSV formats",
        ],
    ),
    "sqlmap": (
        "Automatic SQL injection detection, exploitation, and database takeover engine.",
        [
            "Scan URL parameter: sqlmap -u 'http://target.com/item?id=1' --dbs",
            "Extract tables: sqlmap -u '<url>' -D <dbname> --tables",
            "Interactive OS shell: sqlmap -u '<url>' --os-shell",
        ],
    ),
    "whatweb": (
        "Next generation web scanner identifying CMS, blogging platforms, JavaScript libraries, and servers.",
        [
            "Basic identification: whatweb <url>",
            "Aggressive scan: whatweb -a 3 <url>",
            "Batch scan from file: whatweb -i targets.txt",
        ],
    ),
    "wfuzz": (
        "Modular web application fuzzer for assessing security of web parameters and paths.",
        [
            "Basic fuzz: wfuzz -c -z file,wordlist.txt --hc 404 http://target.com/FUZZ",
            "Headers fuzzing: wfuzz -H 'Cookie: admin=FUZZ' -w wordlist.txt <url>",
        ],
    ),
    "dirsearch": (
        "Advanced command-line directory brute-forcer with multi-threading and recursion.",
        [
            "Syntax: dirsearch -u <url> -e php,html,js,json",
            "Custom wordlists with -w <file>",
            "Automatic rate-limiting and proxy support",
        ],
    ),
    "Burp Suite": (
        "The world's leading web application security testing platform and interception proxy.",
        [
            "Inspect and modify raw HTTP/WebSocket traffic in real-time",
            "Repeater for testing individual requests with manual edits",
            "Intruder for automated customized web attacks",
        ],
    ),
    "hydra": (
        "Very fast multi-threaded network logon cracker supporting SSH, FTP, HTTP, SMB, and more.",
        [
            "SSH brute force: hydra -l user -P passwords.txt ssh://<ip>",
            "HTTP-POST form: hydra -l admin -P pass.txt <ip> http-post-form '...'",
            "Use -t to control concurrent worker threads",
        ],
    ),
    "john": (
        "John the Ripper - versatile, high-performance password hash cracking tool.",
        [
            "Auto-detect format: john hashes.txt",
            "Use custom wordlist: john --wordlist=passwords.txt hashes.txt",
            "Use rules: john --wordlist=pass.txt --rules hashes.txt",
        ],
    ),
    "hashcat": (
        "World's fastest and most advanced password recovery tool with full GPU acceleration.",
        [
            "Benchmark: hashcat -b",
            "MD5 attack: hashcat -m 0 hashes.txt wordlist.txt",
            "NTLM attack: hashcat -m 1000 hashes.txt wordlist.txt -r rules/best64.rule",
        ],
    ),
    "searchsploit": (
        "Command-line search utility for Exploit-DB, finding offline public exploits quickly.",
        [
            "Search exploits: searchsploit apache 2.4",
            "Examine exploit: searchsploit -x <exploit_id>",
            "Copy exploit locally: searchsploit -m <exploit_id>",
        ],
    ),
    "theHarvester": (
        "OSINT gathering tool for finding emails, subdomains, employee names, and open ports.",
        [
            "Gather domain intel: theHarvester -d target.com -b all -l 500",
            "Query multiple search engines and threat intelligence APIs",
        ],
    ),
    "recon-ng": (
        "Full-featured reconnaissance framework with a modular interface similar to Metasploit.",
        [
            "Interactive console: launch with 'recon-ng'",
            "Install modules: marketplace install all",
            "Organized workspace and database storage for all findings",
        ],
    ),
    "sherlock": (
        "Find usernames across hundreds of social networks and online communities simultaneously.",
        [
            "Hunt username: sherlock <username>",
            "Save results to folder: sherlock --folderoutput results <username>",
            "Tor routing support with --tor",
        ],
    ),
    "exiftool": (
        "Read, write, and manipulate EXIF, IPTC, and XMP metadata in images, PDFs, and video files.",
        [
            "Read metadata: exiftool photo.jpg",
            "Strip all metadata: exiftool -all= photo.jpg",
            "Batch rename by timestamp: exiftool '-FileName<DateTimeOriginal' -d %Y%m%d_%H%M%S.%%e dir/",
        ],
    ),
    "steghide": (
        "Steganography program that hides secret data inside JPEG, BMP, WAV, and AU files.",
        [
            "Embed file: steghide embed -cf cover.jpg -ef secret.txt",
            "Extract file: steghide extract -sf cover.jpg",
            "View info: steghide info cover.jpg",
        ],
    ),
    "binwalk": (
        "Firmware analysis tool for reverse engineering, extracting file systems, and identifying embedded code.",
        [
            "Scan binary: binwalk firmware.bin",
            "Extract all files: binwalk -e firmware.bin",
            "Entropy graph: binwalk -E firmware.bin",
        ],
    ),
    "aircrack-ng": (
        "Complete suite of security tools to assess WiFi network security (WEP/WPA/WPA2-PSK).",
        [
            "Monitor mode: airmon-ng start wlan0",
            "Capture handshakes: airodump-ng -c <channel> --bssid <bssid> -w capture wlan0mon",
            "Crack WPA handshake: aircrack-ng -w wordlist.txt -b <bssid> capture-01.cap",
        ],
    ),
    "bettercap": (
        "The Swiss Army knife for WiFi, Bluetooth Low Energy (BLE), and Ethernet MITM attacks.",
        [
            "Interactive interface: bettercap -iface eth0",
            "Network recon, spoofing, and credentials sniffing in real-time",
            "Built-in web UI caplet support",
        ],
    ),
    "reaver": (
        "Brute force attack tool against WiFi Protected Setup (WPS) registrar PINs to recover WPA keys.",
        [
            "Syntax: reaver -i wlan0mon -b <bssid> -vv",
            "Pixie Dust attack support with -K 1",
        ],
    ),
    "proxychains": (
        "Redirects any command through SOCKS4, SOCKS5, or HTTP proxy chains.",
        [
            "Syntax: proxychains4 <command> [args]",
            "Route nmap via Tor: proxychains4 nmap -sT -PN <target>",
            "Configuration in /etc/proxychains4.conf",
        ],
    ),
    "tor": (
        "The Onion Router network client for anonymous communications and privacy.",
        [
            "Starts SOCKS5 proxy on 127.0.0.1:9050",
            "Pair with proxychains or browser for full anonymity",
            "Manage service with systemctl start tor",
        ],
    ),
    "wireshark": (
        "The world's foremost network packet analyzer with rich protocol decoding and filtering.",
        [
            "Interactive GUI for deep packet inspection",
            "Includes tshark CLI tool for headless packet capture",
            "Display filters: http.request.method == 'POST' or ip.addr == 192.168.1.1",
        ],
    ),
    "tcpdump": (
        "Powerful command-line packet capture and protocol analyzer tool.",
        [
            "Capture interface: tcpdump -i eth0 -n",
            "Save to pcap file: tcpdump -i eth0 -w traffic.pcap",
            "Filter host and port: tcpdump -i any host 10.0.0.1 and port 80",
        ],
    ),
}


@dataclass
class ToolInfo:
    name: str
    category_id: str
    category_title: str
    category_icon: str
    bash_func: str
    pkg_name: str
    bin_names: list[str] = field(default_factory=list)
    description: str = ""
    tips: list[str] = field(default_factory=list)

    @property
    def is_installed(self) -> bool:
        return check_tool_installed(self)


_EXPLANATIONS_CACHE: dict[str, tuple[str, list[str]]] | None = None


def _load_explanations_from_sh() -> dict[str, tuple[str, list[str]]]:
    """Parse explanations from core/explanations.sh."""
    global _EXPLANATIONS_CACHE
    if _EXPLANATIONS_CACHE is not None:
        return _EXPLANATIONS_CACHE

    explanations: dict[str, tuple[str, list[str]]] = {}
    exp_file = PROJECT_ROOT / "core" / "explanations.sh"
    if exp_file.exists():
        content = exp_file.read_text(encoding="utf-8", errors="ignore")
        pattern = re.compile(
            r'^\s+(\"?([A-Za-z0-9_.+ -]+)\"?)\)\s*\n(.*?)\n\s+;;',
            re.MULTILINE | re.DOTALL,
        )
        for match in pattern.finditer(content):
            tool_name = match.group(2).strip()
            body = match.group(3)
            lines = []
            for raw_line in body.splitlines():
                raw_line = raw_line.strip()
                m = re.match(r'(?:gecho|echo -e)\s+\"?(.*?)\"?$', raw_line)
                if m:
                    clean = re.sub(r'\$\{[A-Za-z0-9_]+\}', '', m.group(1)).strip()
                    if clean and not clean.startswith("=="):
                        lines.append(clean)
                elif raw_line and not raw_line.startswith("#") and not raw_line.startswith("case"):
                    lines.append(raw_line)

            if lines:
                desc = lines[0]
                tips = []
                for l in lines[1:]:
                    if l.startswith("•") or l.startswith("-") or l.startswith("Tips:"):
                        tips.append(l.lstrip("•- ").strip())
                    elif not desc or desc == tool_name:
                        desc = l
                    else:
                        tips.append(l)
                explanations[tool_name] = (desc, [t for t in tips if t and t != "Tips:"])

    _EXPLANATIONS_CACHE = explanations
    return explanations


_ALL_TOOLS_CACHE: list[ToolInfo] | None = None


def get_all_tools() -> list[ToolInfo]:
    """Load all tools from src/modules/."""
    global _ALL_TOOLS_CACHE
    if _ALL_TOOLS_CACHE is not None:
        return _ALL_TOOLS_CACHE

    sh_explanations = _load_explanations_from_sh()
    tools: list[ToolInfo] = []

    for cat_id, cat_title, cat_icon in CATEGORIES:
        try:
            mod = importlib.import_module(f"src.modules.{cat_id}")
            raw_tools = getattr(mod, "TOOLS", [])
            bins_map = getattr(mod, "BINS", {})

            for item in raw_tools:
                display_name = item[0]
                bash_func = item[1]
                pkg_name = item[2] if len(item) > 2 else ""

                bin_str = bins_map.get(display_name, display_name.lower())
                bin_list = bin_str.split() if bin_str else [display_name.lower()]

                desc = ""
                tips = []

                if display_name in sh_explanations:
                    desc, tips = sh_explanations[display_name]
                elif display_name in EXTRA_TOOL_DESCRIPTIONS:
                    desc, tips = EXTRA_TOOL_DESCRIPTIONS[display_name]
                else:
                    desc = f"Utility {display_name} in category {cat_title}."
                    tips = [f"Install via {bash_func}"]

                tool = ToolInfo(
                    name=display_name,
                    category_id=cat_id,
                    category_title=cat_title,
                    category_icon=cat_icon,
                    bash_func=bash_func,
                    pkg_name=pkg_name,
                    bin_names=bin_list,
                    description=desc,
                    tips=tips,
                )
                tools.append(tool)
        except Exception as e:
            print(f"[WARN] Failed to load module {cat_id}: {e}")

    _ALL_TOOLS_CACHE = tools
    return tools


def get_tools_by_category(category_id: str) -> list[ToolInfo]:
    """Return tools belonging to a category or all tools if category_id == 'all'."""
    all_tools = get_all_tools()
    if category_id == "all":
        return all_tools
    return [t for t in all_tools if t.category_id == category_id]


def check_tool_installed(tool: ToolInfo) -> bool:
    """Fast check whether a tool is installed on the system."""
    for b in tool.bin_names:
        if shutil.which(b):
            return True

    # Known absolute / custom paths
    custom_paths = {
        "Firefox Developer Edition": "/opt/firefox-developer/firefox",
        "JetBrains Toolbox": "/opt/jetbrains-toolbox/jetbrains-toolbox",
        "ZCode": "/opt/zcode",
        "Antigravity": "/opt/antigravity",
        "Kiro": "/opt/kiro",
    }
    if tool.name in custom_paths:
        p = Path(custom_paths[tool.name])
        if p.exists():
            return True

    return False


def get_status_map() -> dict[str, bool]:
    """Return a mapping of tool_name -> is_installed for all tools."""
    return {t.name: check_tool_installed(t) for t in get_all_tools()}


def get_system_profile() -> dict[str, str]:
    """Collect system profile details."""
    pretty_name = "Linux"
    if os.path.exists("/etc/os-release"):
        with open("/etc/os-release", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if line.startswith("PRETTY_NAME="):
                    pretty_name = line.split("=", 1)[1].strip().strip('"')
                    break

    kernel = os.uname().release
    de = os.environ.get("XDG_CURRENT_DESKTOP", os.environ.get("DESKTOP_SESSION", "Unknown"))

    cpu_model = "Unknown"
    cpu_cores = 0
    try:
        with open("/proc/cpuinfo", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if line.startswith("model name"):
                    cpu_model = line.split(":", 1)[1].strip()
                elif line.startswith("processor"):
                    cpu_cores += 1
        cpu_cores = max(cpu_cores, 1)
    except FileNotFoundError:
        pass

    total_ram = "Unknown"
    try:
        with open("/proc/meminfo", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if line.startswith("MemTotal:"):
                    kb = int(line.split()[1])
                    total_ram = f"{round(kb / (1024 * 1024), 1)} GiB"
                    break
    except FileNotFoundError:
        pass

    return {
        "distro": pretty_name,
        "kernel": kernel,
        "de": de,
        "cpu": f"{cpu_model} ({cpu_cores} cores)" if cpu_cores else cpu_model,
        "ram": total_ram,
    }
