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


def cmd_interactive(show_splash: bool = True) -> None:
    """Full interactive TUI: banner → persona → main menu → category menus → install"""
    from src.core import bash as bash_module
    from src.core.bash import call as bash_call
    from src.tui.render import show_main_menu, render_menu
    from src.core.logging import log_message
    import importlib
    import subprocess

    bash_module.setup(SCRIPT_DIR)
    from src.core import distro
    distro.detect()

    if show_splash:
        subprocess.run(
            ["bash", os.path.join(SCRIPT_DIR, "setup.sh"), "--skip-python", "--banner-only"],
            capture_output=False,
        )
        cmd_persona()

    ALL_MODULES = {
        "1": ("browsers", "Browsers"),
        "2": ("productivity", "Productivity"),
        "3": ("ides", "IDEs & Editors"),
        "4": ("terminals", "Terminals"),
        "5": ("shells", "Shells"),
        "6": ("dev_tools", "Dev Tools"),
        "7": ("languages", "Languages"),
        "8": ("pentest", "Pentesting"),
        "9": ("frameworks", "Frameworks"),
    }

    while True:
        choice = show_main_menu()

        if choice in ("12", "exit", "q"):
            break

        if choice in ("10", "full", "all"):
            log_message("INFO", "--- Full Install ---")
            for key, (mod_name, _) in ALL_MODULES.items():
                mod = importlib.import_module(f"src.modules.{mod_name}")
                mod.install_all()
            continue

        if choice in ("11", "minimal"):
            log_message("INFO", "--- Minimal Install ---")
            mod = importlib.import_module("src.modules.browsers")
            mod.install_all()
            mod = importlib.import_module("src.modules.terminals")
            mod.install_all()
            continue

        if choice.startswith("e"):
            try:
                idx = int(choice[1:])
                name_list = ["Browsers", "Productivity", "IDEs & Editors", "Terminals",
                             "Shells", "Dev Tools", "Languages", "Pentesting", "Frameworks"]
                if 1 <= idx <= len(name_list):
                    bash_call("_explain_tool", name_list[idx - 1])
            except ValueError:
                pass
            continue

        mod_name, mod_title = ALL_MODULES.get(choice, (None, None))
        if mod_name is None:
            continue

        mod = importlib.import_module(f"src.modules.{mod_name}")
        tools_list = [(t[0], t[1]) for t in mod.TOOLS]

        while True:
            sub_choice = render_menu(tools_list, mod_title)

            if sub_choice == str(len(tools_list) + 3) or sub_choice.lower() in ("back", "b"):
                break

            if sub_choice == str(len(tools_list) + 2) or sub_choice.lower() in ("check", "c"):
                mod.check()
                continue

            if sub_choice == str(len(tools_list) + 1) or sub_choice.lower() in ("all", "a"):
                mod.install_all()
                continue

            if sub_choice.startswith("e"):
                try:
                    idx = int(sub_choice[1:])
                    if 1 <= idx <= len(tools_list):
                        cmd_explain(tools_list[idx - 1][0])
                except ValueError:
                    pass
                continue

            try:
                idx = int(sub_choice) - 1
                if 0 <= idx < len(tools_list):
                    mod.install(tools_list[idx][0])
            except ValueError:
                pass


def cmd_exec(args: list[str]) -> None:
    script = os.path.join(SCRIPT_DIR, "setup.sh")
    os.execvp("bash", ["bash", script] + args)


def main() -> None:
    logging.setup()

    if len(sys.argv) < 2:
        cmd_interactive(show_splash=True)
        return

    subcommand = sys.argv[1]
    rest = sys.argv[2:]

    if subcommand == "interactive":
        cmd_interactive(show_splash=False)
    elif subcommand == "persona":
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
