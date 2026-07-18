#!/usr/bin/env python3
"""Browsers module — 8 browsers"""

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
    from src.core.logging import log_message

    dispatch = {
        "Brave": _install_via_bash,
        "Google Chrome": _install_via_bash,
        "Firefox": _install_firefox,
        "Vivaldi": _install_via_bash,
        "Chromium": _install_chromium,
        "Firefox Developer Edition": _install_via_bash,
        "Ungoogled Chromium": _install_via_bash,
        "LibreWolf": _install_via_bash,
    }

    fn = dispatch.get(name)
    if not fn:
        log_message("ERROR", f"Unknown browser: {name}")
        return 1
    return fn(name)


def _install_via_bash(name: str) -> int:
    from src.core.logging import log_message
    from src.tui.confirm import confirm_install
    from src.core import bash

    bin_map = {
        "Brave": "brave-browser",
        "Google Chrome": "google-chrome-stable",
        "Vivaldi": "vivaldi-stable",
        "Firefox Developer Edition": "firefox-dev",
        "Ungoogled Chromium": "ungoogled-chromium",
        "LibreWolf": "librewolf",
    }

    bash_fn_map = {
        "Brave": "install_brave",
        "Google Chrome": "install_chrome",
        "Vivaldi": "install_vivaldi",
        "Firefox Developer Edition": "install_firefox_dev",
        "Ungoogled Chromium": "install_ungoogled_chromium",
        "LibreWolf": "install_librewolf",
    }

    binary = bin_map.get(name)
    bash_fn = bash_fn_map.get(name)
    if not binary or not bash_fn:
        return 1

    confirm_install(name, binary)
    log_message("INFO", f"Installing {name} (via bash)...")
    code, out, err = bash.call(bash_fn)
    if code == 0:
        log_message("SUCCESS", f"{name} installed.")
    else:
        log_message("ERROR", f"{name} install failed (exit code {code}).")
        if err:
            log_message("ERROR", err)
    return code


def _install_firefox(name: str) -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed
    from src.tui.confirm import confirm_install
    from src.core.installers import with_fallback

    if is_installed("firefox"):
        log_message("WARN", "Firefox is already installed.")
        return 0
    confirm_install("Firefox", "firefox")
    return with_fallback("Firefox", "firefox", "firefox", "org.mozilla.firefox", "firefox")


def _install_chromium(name: str) -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed, DISTRO
    from src.tui.confirm import confirm_install
    from src.core.installers import with_fallback

    if is_installed("chromium") or is_installed("chromium-browser"):
        log_message("WARN", "Chromium is already installed.")
        return 0

    confirm_install("Chromium", "chromium")

    if DISTRO == "debian":
        from src.core.package_manager import install_native
        code = install_native("chromium")
        if code != 0:
            code = install_native("chromium-browser")
        return code
    elif DISTRO == "arch":
        return with_fallback("Chromium", "chromium", "chromium", "org.chromium.Chromium", "chromium")
    else:
        return with_fallback("Chromium", "chromium", "", "org.chromium.Chromium", "chromium")


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
    bins = {
        "Brave": "brave-browser",
        "Google Chrome": "google-chrome-stable",
        "Firefox": "firefox",
        "Vivaldi": "vivaldi-stable",
        "Chromium": "chromium",
        "Firefox Developer Edition": "firefox-dev",
        "Ungoogled Chromium": "ungoogled-chromium",
        "LibreWolf": "librewolf",
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
