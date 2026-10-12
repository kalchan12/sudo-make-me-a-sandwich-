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

CATEGORY = "Bug Bounty"

TOOLS: list[tuple[str, str, str]] = [
    ("subfinder", "install_subfinder", "subfinder"),
    ("httpx", "install_httpx", "httpx-toolkit"),
    ("nuclei", "install_nuclei", "nuclei"),
    ("katana", "install_katana", "katana"),
    ("ghidra", "install_ghidra", "ghidra"),
    ("caido", "install_caido", "caido"),
]

BINS: dict[str, str] = {
    "subfinder": "subfinder",
    "httpx": "httpx httpx-toolkit",
    "nuclei": "nuclei",
    "katana": "katana",
    "ghidra": "ghidra ghidraRun",
    "caido": "caido caido-cli",
}


def install(name: str) -> int:
    return _install(TOOLS, name)


def install_all() -> int:
    return _install_all(TOOLS, CATEGORY)


def check() -> None:
    _check(TOOLS, BINS, CATEGORY)


if __name__ == "__main__":
    cli_main(TOOLS, BINS, CATEGORY, os.path.basename(__file__))
