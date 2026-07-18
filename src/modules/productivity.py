#!/usr/bin/env python3

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

TOOLS: list[tuple[str, str, str]] = [
    ("Obsidian", "install_obsidian", "obsidian"),
    ("WPS Office", "install_wps", "wps"),
    ("OBS Studio", "install_obs_studio", "obs-studio"),
    ("ffmpeg", "install_ffmpeg", "ffmpeg"),
    ("yt-dlp", "install_yt_dlp", "yt-dlp"),
]


def install(name: str) -> int:
    from src.core import bash
    from src.core.logging import log_message
    for display, bash_fn, _ in TOOLS:
        if display == name:
            log_message("INFO", f"Installing {name}...")
            code, out, err = bash.call(bash_fn)
            if code == 0:
                log_message("SUCCESS", f"{name} installed.")
            else:
                log_message("ERROR", f"{name} install failed (exit {code}).")
                if err:
                    log_message("ERROR", err)
            return code
    log_message("ERROR", f"Unknown tool: {name}")
    return 1


def install_all() -> int:
    from src.core.logging import log_message
    log_message("INFO", "--- Installing All Productivity Tools ---")
    ec = 0
    for name, _, _ in TOOLS:
        if install(name) != 0:
            ec = 1
    return ec


def check() -> None:
    from src.core.logging import log_message
    from src.core.distro import is_installed
    log_message("INFO", "--- Checking Productivity Installations ---")
    bins = {"Obsidian": "obsidian", "WPS Office": "wps",
            "OBS Studio": "obs", "ffmpeg": "ffmpeg", "yt-dlp": "yt-dlp"}
    for name, _, _ in TOOLS:
        binary = bins.get(name, name.lower())
        if is_installed(binary):
            print(f"\033[1;32m[✔] {name} is installed.\033[0m")
        else:
            print(f"\033[0;31m[✘] {name} is NOT installed.\033[0m")


if __name__ == "__main__":
    from src.core.bash import setup as bash_setup
    bash_setup(os.path.join(os.path.dirname(__file__), "..", ".."))
    if len(sys.argv) < 2:
        print("Usage: productivity.py <install|install_all|check> [name]")
        sys.exit(1)
    cmd = sys.argv[1]
    if cmd == "install" and len(sys.argv) > 2:
        sys.exit(install(sys.argv[2]))
    elif cmd == "install_all":
        sys.exit(install_all())
    elif cmd == "check":
        check()
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)
