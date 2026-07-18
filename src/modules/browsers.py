#!/usr/bin/env python3

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

TOOLS: list[tuple[str, str, str]] = [
    ("Brave", "install_brave", "brave-browser"),
    ("Google Chrome", "install_chrome", "google-chrome-stable"),
    ("Firefox", "install_firefox", "firefox"),
    ("Vivaldi", "install_vivaldi", "vivaldi-stable"),
    ("Chromium", "install_chromium", "chromium"),
    ("Firefox Developer Edition", "install_firefox_dev", "firefox-dev"),
    ("Ungoogled Chromium", "install_ungoogled_chromium", "ungoogled-chromium"),
    ("LibreWolf", "install_librewolf", "librewolf"),
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
    log_message("INFO", "--- Installing All Browsers ---")
    ec = 0
    for name, _, _ in TOOLS:
        if install(name) != 0:
            ec = 1
    return ec


def check() -> None:
    from src.core.logging import log_message
    from src.core.distro import is_installed
    log_message("INFO", "--- Checking Browser Installations ---")
    bins = {"Brave": "brave-browser", "Google Chrome": "google-chrome-stable",
            "Firefox": "firefox", "Vivaldi": "vivaldi-stable",
            "Chromium": "chromium", "Firefox Developer Edition": "firefox-dev",
            "Ungoogled Chromium": "ungoogled-chromium", "LibreWolf": "librewolf"}
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
        print("Usage: browsers.py <install|install_all|check> [name]")
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
