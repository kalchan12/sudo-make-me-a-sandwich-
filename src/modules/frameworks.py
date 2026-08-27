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

CATEGORY = "Frameworks"

TOOLS: list[tuple[str, str, str]] = [
    ("Flutter", "install_flutter", "flutter"),
    ("React Native", "install_react_native", "react-native"),
    ("Next.js", "install_nextjs", "next"),
    ("Node.js (Latest)", "install_nodejs_latest", "node"),
    ("Electron", "install_electron", "electron"),
    ("Tauri", "install_tauri", "tauri"),
    ("Deno", "install_deno", "deno"),
    ("Bun", "install_bun", "bun"),
]

BINS: dict[str, str] = {
    "Flutter": "flutter", "React Native": "react-native", "Next.js": "next", "Node.js (Latest)": "node", "Electron": "electron", "Tauri": "cargo-tauri", "Deno": "deno", "Bun": "bun"
}


def install(name: str) -> int:
    return _install(TOOLS, name)


def install_all() -> int:
    return _install_all(TOOLS, CATEGORY)


def check() -> None:
    _check(TOOLS, BINS, CATEGORY)


if __name__ == "__main__":
    cli_main(TOOLS, BINS, CATEGORY, os.path.basename(__file__))
