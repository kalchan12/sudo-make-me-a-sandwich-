#!/usr/bin/env python3

import sys
import os
import subprocess

SCRIPT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, SCRIPT_DIR)

from src.core import logging


def cmd_persona() -> None:
    from rich import box
    from rich.panel import Panel
    from rich.table import Table

    console = logging._console

    pretty_name = ""
    if os.path.exists("/etc/os-release"):
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("PRETTY_NAME="):
                    pretty_name = line.split("=", 1)[1].strip().strip('"')

    kernel = os.uname().release
    de = os.environ.get("XDG_CURRENT_DESKTOP", "Unknown")

    cpu_model = "Unknown"
    cpu_cores = 0
    try:
        with open("/proc/cpuinfo") as f:
            for line in f:
                if line.startswith("model name"):
                    cpu_model = line.split(":", 1)[1].strip()
                elif line.startswith("processor"):
                    cpu_cores += 1
        cpu_cores = max(cpu_cores, 1)
    except FileNotFoundError:
        pass

    total_ram = 0
    try:
        with open("/proc/meminfo") as f:
            for line in f:
                if line.startswith("MemTotal:"):
                    total_ram = int(line.split()[1]) // 1024 // 1024
                    break
    except FileNotFoundError:
        pass

    table = Table(box=box.SIMPLE, border_style="green")
    table.add_column("Property", style="cyan", no_wrap=True)
    table.add_column("Value", style="green")

    table.add_row("Distro", f"{pretty_name} ({kernel})" if pretty_name else kernel)
    table.add_row("DE / WM", de)
    table.add_row("CPU", f"{cpu_model} ({cpu_cores} cores)" if cpu_cores else cpu_model)
    table.add_row("Memory", f"{total_ram} GiB" if total_ram else "Unknown")

    panel = Panel(table, title="[magenta]System Profile[/]", box=box.HEAVY,
                  border_style="magenta", padding=(1, 2))
    console.print()
    console.print(panel)
    console.print()


def cmd_explain(name: str) -> int:
    from src.core.bash import setup as bash_setup, call

    bash_setup(SCRIPT_DIR)
    code, out, err = call("_explain_tool", name)
    if out.strip():
        print(out)
    if err.strip():
        print(err, file=sys.stderr)
    return code


def cmd_list() -> None:
    categories = [
        ("Browsers", ["Brave", "Google Chrome", "Firefox", "Vivaldi", "Chromium",
                       "Firefox Developer Edition", "Ungoogled Chromium", "LibreWolf"]),
        ("Productivity", ["Obsidian", "WPS Office", "OBS Studio", "ffmpeg", "yt-dlp"]),
        ("IDEs & Editors", ["VS Code", "Sublime Text", "JetBrains Toolbox"]),
        ("Terminals", ["Kitty", "Alacritty", "Tilix", "GNOME Terminal"]),
        ("Shells", ["Zsh", "Fish", "Dash", "Ksh", "Tcsh", "Nushell", "Elvish", "Xonsh"]),
        ("Dev Tools", ["tmux", "Neovim", "Docker", "jq", "ripgrep", "fzf", "bat", "fd",
                        "btop", "lazygit", "zoxide", "delta", "tldr", "httpie", "glances",
                        "thefuck", "eza", "dust", "Flameshot", "KeePassXC", "mpv",
                        "Syncthing", "VLC"]),
        ("Languages", ["Python", "Node.js", "TypeScript", "Go", "Rust", "Java (OpenJDK)",
                        "C/C++ (GCC)", "C# (.NET)", "Ruby", "PHP", "Lua", "R", "Zig",
                        "Dart", "Kotlin"]),
        ("Pentesting", ["nmap", "masscan", "netcat", "rustscan", "gobuster", "ffuf",
                         "nikto", "sqlmap", "whatweb", "wfuzz", "dirsearch", "Burp Suite",
                         "hydra", "john", "hashcat", "searchsploit", "theHarvester",
                         "recon-ng", "sherlock", "exiftool", "steghide", "binwalk",
                         "aircrack-ng", "bettercap", "reaver", "proxychains", "tor",
                         "wireshark", "tcpdump"]),
        ("Frameworks", ["Flutter", "React Native", "Next.js", "Node.js (Latest)",
                         "Electron", "Tauri", "Deno", "Bun"]),
        ("Agentic IDEs", ["OpenCode", "ZCode", "Antigravity", "Kiro"]),
    ]

    for cat_name, tools in categories:
        print(f"\n[{cat_name}]:")
        for t in tools:
            print(f"  - {t}")


def cmd_menu(category: str = "main") -> None:
    from src.tui.render import show_main_menu, render_menu
    from rich.console import Console

    console = Console()

    if category == "main":
        choice = show_main_menu()
    else:
        tools_list = []
        try:
            import json
            tools_list = json.loads(category)
        except (json.JSONDecodeError, TypeError):
            pass
        choice = render_menu(tools_list, "Category")

    console.print(f"[dim]Selected: {choice}[/]")
    print(choice)


def cmd_exec(args: list[str]) -> None:
    script = os.path.join(SCRIPT_DIR, "setup.sh")
    os.execvp("bash", ["bash", script] + args)


def main() -> None:
    logging.setup()

    if len(sys.argv) < 2:
        cmd_persona()
        cmd_exec([])

    subcommand = sys.argv[1]
    rest = sys.argv[2:]

    if subcommand == "persona":
        cmd_persona()
    elif subcommand == "menu":
        cmd_menu(rest[0] if rest else "main")
    elif subcommand == "explain":
        if rest:
            sys.exit(cmd_explain(" ".join(rest)))
        else:
            print("Usage: main.py explain <tool_name>")
            sys.exit(1)
    elif subcommand == "list":
        cmd_list()
    elif subcommand == "exec":
        cmd_exec(rest)
    else:
        cmd_exec(sys.argv[1:])


if __name__ == "__main__":
    main()
