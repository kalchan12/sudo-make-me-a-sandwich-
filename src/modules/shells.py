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

CATEGORY = "Shells"

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

BINS: dict[str, str] = {
    "Zsh": "zsh", "Fish": "fish", "Dash": "dash", "Ksh": "ksh", "Tcsh": "tcsh", "Nushell": "nu", "Elvish": "elvish", "Xonsh": "xonsh"
}


def install(name: str) -> int:
    return _install(TOOLS, name)


def install_all() -> int:
    return _install_all(TOOLS, CATEGORY)


def check() -> None:
    _check(TOOLS, BINS, CATEGORY)


if __name__ == "__main__":
    cli_main(TOOLS, BINS, CATEGORY, os.path.basename(__file__))
