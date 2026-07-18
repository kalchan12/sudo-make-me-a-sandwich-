#!/usr/bin/env python3
"""Agentic IDEs module — OpenCode, ZCode, Antigravity, Kiro"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

TOOLS: list[tuple[str, str, str]] = [
    ("OpenCode", "install_opencode", "opencode"),
    ("ZCode", "install_zcode", "zcode"),
    ("Antigravity", "install_antigravity", "antigravity"),
    ("Kiro", "install_kiro", "kiro"),
]


def install(name: str) -> int:
    from src.core.logging import log_message
    from src.tui.confirm import confirm_install
    from src.core import bash

    bin_map = {
        "OpenCode": "opencode",
        "ZCode": "zcode",
        "Antigravity": "antigravity",
        "Kiro": "kiro",
    }
    bash_fn_map = {
        "OpenCode": "install_opencode",
        "ZCode": "install_zcode",
        "Antigravity": "install_antigravity",
        "Kiro": "install_kiro",
    }
    alt_check = {
        "ZCode": ("zcode", "/opt/zcode"),
        "Antigravity": ("antigravity", "/opt/antigravity"),
        "Kiro": ("kiro", "/opt/kiro"),
    }

    binary = bin_map.get(name)
    if not binary:
        log_message("ERROR", f"Unknown tool: {name}")
        return 1

    if name in alt_check:
        b, d = alt_check[name]
        from src.core.distro import is_installed
        if is_installed(b) or os.path.isdir(d):
            log_message("WARN", f"{name} is already installed.")
            return 0
    else:
        from src.core.distro import is_installed
        if is_installed(binary):
            log_message("WARN", f"{name} is already installed.")
            return 0

    confirm_install(name, binary)
    log_message("INFO", f"Installing {name} (via bash)...")
    bash_fn = bash_fn_map.get(name)
    if not bash_fn:
        return 1
    code, out, err = bash.call(bash_fn)
    if code == 0:
        log_message("SUCCESS", f"{name} installed.")
    else:
        log_message("ERROR", f"{name} install failed (exit code {code}).")
        if err:
            log_message("ERROR", err)
    return code


def install_all() -> int:
    from src.core.logging import log_message

    log_message("INFO", "--- Installing All Agentic IDEs ---")
    ec = 0
    for name, _, _ in TOOLS:
        if install(name) != 0:
            ec = 1
    return ec


def check() -> None:
    from src.core.logging import log_message
    from src.core.distro import is_installed

    log_message("INFO", "--- Checking Agentic IDE Installations ---")
    bins = {
        "OpenCode": "opencode",
        "ZCode": "zcode",
        "Antigravity": "antigravity",
        "Kiro": "kiro",
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
        print("Usage: agentic_ides.py <install|install_all|check> [name]")
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
