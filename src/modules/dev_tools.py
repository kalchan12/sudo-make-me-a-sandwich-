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

CATEGORY = "Dev Tools"

TOOLS: list[tuple[str, str, str]] = [
    ("tmux", "install_tmux", "tmux"),
    ("Neovim", "install_neovim", "neovim"),
    ("Docker", "install_docker", "docker"),
    ("jq", "install_jq", "jq"),
    ("ripgrep", "install_ripgrep", "ripgrep"),
    ("fzf", "install_fzf", "fzf"),
    ("bat", "install_bat", "bat"),
    ("fd", "install_fd", "fd"),
    ("btop", "install_btop", "btop"),
    ("lazygit", "install_lazygit", "lazygit"),
    ("zoxide", "install_zoxide", "zoxide"),
    ("delta", "install_delta", "delta"),
    ("tldr", "install_tldr", "tldr"),
    ("httpie", "install_httpie", "httpie"),
    ("glances", "install_glances", "glances"),
    ("thefuck", "install_thefuck", "thefuck"),
    ("eza", "install_eza", "eza"),
    ("dust", "install_dust", "dust"),
    ("Flameshot", "install_flameshot", "flameshot"),
    ("KeePassXC", "install_keepassxc", "keepassxc"),
    ("mpv", "install_mpv", "mpv"),
    ("Syncthing", "install_syncthing", "syncthing"),
    ("VLC", "install_vlc", "vlc"),
]

BINS: dict[str, str] = {
    "tmux": "tmux", "Neovim": "nvim", "Docker": "docker", "jq": "jq", "ripgrep": "rg", "fzf": "fzf", "bat": "bat", "fd": "fd", "btop": "btop", "lazygit": "lazygit", "zoxide": "zoxide", "delta": "delta", "tldr": "tldr", "httpie": "http", "glances": "glances", "thefuck": "thefuck", "eza": "eza", "dust": "dust", "Flameshot": "flameshot", "KeePassXC": "keepassxc", "mpv": "mpv", "Syncthing": "syncthing", "VLC": "vlc"
}


def install(name: str) -> int:
    return _install(TOOLS, name)


def install_all() -> int:
    return _install_all(TOOLS, CATEGORY)


def check() -> None:
    _check(TOOLS, BINS, CATEGORY)


if __name__ == "__main__":
    cli_main(TOOLS, BINS, CATEGORY, os.path.basename(__file__))
