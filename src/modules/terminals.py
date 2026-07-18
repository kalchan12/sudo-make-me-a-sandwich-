#!/usr/bin/env python3
"""Terminals module — Kitty, Alacritty, Tilix, GNOME Terminal"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

TOOLS: list[tuple[str, str, str]] = [
    ("Kitty", "install_kitty", "kitty"),
    ("Alacritty", "install_alacritty", "alacritty"),
    ("Tilix", "install_tilix", "tilix"),
    ("GNOME Terminal", "install_gnome_terminal", "gnome-terminal"),
]


def install(name: str) -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed
    from src.tui.confirm import confirm_install
    from src.core.package_manager import install_native

    pkg_map = {
        "Kitty": "kitty",
        "Alacritty": "alacritty",
        "Tilix": "tilix",
        "GNOME Terminal": "gnome-terminal",
    }

    cmd_map = {
        "Kitty": "kitty",
        "Alacritty": "alacritty",
        "Tilix": "tilix",
        "GNOME Terminal": "gnome-terminal",
    }

    pkg = pkg_map.get(name)
    binary = cmd_map.get(name)
    if not pkg or not binary:
        log_message("ERROR", f"Unknown terminal: {name}")
        return 1

    if is_installed(binary):
        log_message("WARN", f"{name} is already installed.")
        return 0

    confirm_install(name, pkg)
    log_message("INFO", f"Installing {name}...")
    code = install_native(pkg)
    if code == 0:
        log_message("SUCCESS", f"{name} installed.")
    return code


def install_all() -> int:
    from src.core.logging import log_message

    log_message("INFO", "--- Installing All Terminals ---")
    ec = 0
    for name, _, _ in TOOLS:
        if install(name) != 0:
            ec = 1
    return ec


def check() -> None:
    from src.core.logging import log_message
    from src.core.distro import is_installed

    log_message("INFO", "--- Checking Terminal Installations ---")
    bins = {
        "Kitty": "kitty",
        "Alacritty": "alacritty",
        "Tilix": "tilix",
        "GNOME Terminal": "gnome-terminal",
    }
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
        print("Usage: terminals.py <install|install_all|check> [name]")
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
