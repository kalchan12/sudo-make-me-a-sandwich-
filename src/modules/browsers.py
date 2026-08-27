#!/usr/bin/env python3

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from src.modules.base import (
    install as _install,
    install_all as _install_all,
    check as _check,
    cli_main,
)

CATEGORY = "Browsers"

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

BINS: dict[str, str] = {
    "Brave": "brave-browser", "Google Chrome": "google-chrome-stable", "Firefox": "firefox", "Vivaldi": "vivaldi-stable", "Chromium": "chromium", "Firefox Developer Edition": "firefox-dev", "Ungoogled Chromium": "ungoogled-chromium", "LibreWolf": "librewolf"
}


def install(name: str) -> int:
    return _install(TOOLS, name)


def install_all() -> int:
    return _install_all(TOOLS, CATEGORY)


def check() -> None:
    _check(TOOLS, BINS, CATEGORY)


if __name__ == "__main__":
    cli_main(TOOLS, BINS, CATEGORY, os.path.basename(__file__))
