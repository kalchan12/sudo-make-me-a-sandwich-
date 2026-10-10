#!/usr/bin/env python3
"""Psycho module for sudo-make-me-a-sandwich."""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

from src.modules.base import (
    install as _install,
    install_all as _install_all,
    check as _check,
    cli_main,
)

CATEGORY = "Psycho"

TOOLS: list[tuple[str, str, str]] = [
    ("Kitty (Hacker Suite)", "install_kitty_psycho", "kitty"),
    ("Brave", "install_brave", "brave-browser"),
    ("WPS Office", "install_wps", "wps"),
    ("OBS Studio", "install_obs_studio", "obs-studio"),
    ("ffmpeg", "install_ffmpeg", "ffmpeg"),
    ("yt-dlp", "install_yt_dlp", "yt-dlp"),
    ("Redshift", "install_redshift", "redshift"),
]

BINS: dict[str, str] = {
    "Kitty (Hacker Suite)": "kitty",
    "Brave": "brave-browser brave",
    "WPS Office": "wps",
    "OBS Studio": "obs",
    "ffmpeg": "ffmpeg",
    "yt-dlp": "yt-dlp",
    "Redshift": "redshift",
}


def install(name: str) -> int:
    return _install(TOOLS, name)


def install_all() -> int:
    return _install_all(TOOLS, CATEGORY)


def check() -> None:
    _check(TOOLS, BINS, CATEGORY)


if __name__ == "__main__":
    cli_main(TOOLS, BINS, CATEGORY, os.path.basename(__file__))
