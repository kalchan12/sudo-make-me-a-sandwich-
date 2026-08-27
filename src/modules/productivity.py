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

CATEGORY = "Productivity"

TOOLS: list[tuple[str, str, str]] = [
    ("Obsidian", "install_obsidian", "obsidian"),
    ("Telegram", "install_telegram", "telegram-desktop"),
    ("Proton Pass", "install_proton_pass", "proton-pass"),
    ("Proton VPN", "install_proton_vpn", "protonvpn"),
    ("WPS Office", "install_wps", "wps"),
    ("OBS Studio", "install_obs_studio", "obs-studio"),
    ("ffmpeg", "install_ffmpeg", "ffmpeg"),
    ("yt-dlp", "install_yt_dlp", "yt-dlp"),
]

BINS: dict[str, str] = {
    "Obsidian": "obsidian",
    "Telegram": "telegram-desktop",
    "Proton Pass": "proton-pass protonpass",
    "Proton VPN": "protonvpn-app protonvpn proton-vpn-gnome-desktop",
    "WPS Office": "wps",
    "OBS Studio": "obs",
    "ffmpeg": "ffmpeg",
    "yt-dlp": "yt-dlp",
}


def install(name: str) -> int:
    return _install(TOOLS, name)


def install_all() -> int:
    return _install_all(TOOLS, CATEGORY)


def check() -> None:
    _check(TOOLS, BINS, CATEGORY)


if __name__ == "__main__":
    cli_main(TOOLS, BINS, CATEGORY, os.path.basename(__file__))
