#!/usr/bin/env python3
"""Shells module — install Zsh, Fish, Dash, Ksh, Tcsh, Nushell, Elvish, Xonsh"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

TOOLS: list[tuple[str, str, str]] = [
    ("Zsh", "install_zsh", "zsh"),
    ("Fish", "install_fish", "fish"),
    ("Dash", "install_dash", "dash"),
    ("Ksh", "install_ksh", "ksh"),
    ("Tcsh", "install_tcsh", "tcsh"),
    ("Nushell", "install_nushell", "nushell"),
    ("Elvish", "install_elvish", "elvish"),
    ("Xonsh", "install_xonsh", "xonsh"),
]


def install(name: str) -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed
    from src.tui.confirm import confirm_install

    pkg_map = {
        "Zsh": ("zsh", "zsh", "", ""),
        "Fish": ("fish", "fish", "", ""),
        "Dash": ("dash", "dash", "", ""),
        "Ksh": ("ksh", "ksh", "", ""),
        "Tcsh": ("tcsh", "tcsh", "", ""),
        "Nushell": ("nushell", "nushell", "nushell-bin", ""),
        "Elvish": ("elvish", "elvish", "", ""),
        "Xonsh": ("xonsh", "xonsh", "", ""),
    }

    if name not in pkg_map:
        log_message("ERROR", f"Unknown shell: {name}")
        return 1

    bin_map = {
        "Zsh": "zsh",
        "Fish": "fish",
        "Dash": "dash",
        "Ksh": "ksh",
        "Tcsh": "tcsh",
        "Nushell": "nu",
        "Elvish": "elvish",
        "Xonsh": "xonsh",
    }

    binary = bin_map[name]
    if is_installed(binary):
        log_message("WARN", f"{name} is already installed.")
        return 0

    if not confirm_install(name, pkg_map[name][0]):
        return 0

    display, native_pkg, aur_pkg, flatpak_id = pkg_map[name]
    from src.core.installers import with_fallback
    return with_fallback(display, native_pkg, aur_pkg, flatpak_id, binary)


def install_all() -> int:
    from src.core.logging import log_message

    log_message("INFO", "--- Installing All Shells ---")
    ec = 0
    for name, _, _ in TOOLS:
        if install(name) != 0:
            ec = 1
    return ec


def check() -> None:
    from src.core.logging import log_message
    from src.core.distro import is_installed

    log_message("INFO", "--- Checking Shell Installations ---")
    bin_map = {
        "Zsh": "zsh",
        "Fish": "fish",
        "Dash": "dash",
        "Ksh": "ksh",
        "Tcsh": "tcsh",
        "Nushell": "nu",
        "Elvish": "elvish",
        "Xonsh": "xonsh",
    }
    for name, _, _ in TOOLS:
        binary = bin_map[name]
        if is_installed(binary):
            print(f"\033[1;32m[✔] {name} is installed.\033[0m")
        else:
            print(f"\033[0;31m[✘] {name} is NOT installed.\033[0m")


if __name__ == "__main__":
    from src.core.bash import setup as bash_setup
    from src.core import distro

    bash_setup(os.path.join(os.path.dirname(__file__), "..", ".."))

    if len(sys.argv) < 2:
        print("Usage: shells.py <install|install_all|check> [name]")
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
