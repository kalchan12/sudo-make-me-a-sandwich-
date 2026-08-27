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

CATEGORY = "Terminals"

TOOLS: list[tuple[str, str, str]] = [
    ("Kitty", "install_kitty", "kitty"),
    ("Alacritty", "install_alacritty", "alacritty"),
    ("Tilix", "install_tilix", "tilix"),
    ("GNOME Terminal", "install_gnome_terminal", "gnome-terminal"),
]

BINS: dict[str, str] = {
    "Kitty": "kitty", "Alacritty": "alacritty", "Tilix": "tilix", "GNOME Terminal": "gnome-terminal"
}


def install(name: str) -> int:
    return _install(TOOLS, name)


def install_all() -> int:
    return _install_all(TOOLS, CATEGORY)


def check() -> None:
    _check(TOOLS, BINS, CATEGORY)


if __name__ == "__main__":
    cli_main(TOOLS, BINS, CATEGORY, os.path.basename(__file__))
