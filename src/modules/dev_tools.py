#!/usr/bin/env python3
"""Dev Tools module — 23 developer utilities"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

TOOLS: list[tuple[str, str, str]] = [
    ("tmux", "install_tmux", "tmux"),
    ("Neovim", "install_neovim", "neovim"),
    ("Docker", "install_docker", "docker.io"),
    ("jq", "install_jq", "jq"),
    ("ripgrep", "install_ripgrep", "ripgrep"),
    ("fzf", "install_fzf", "fzf"),
    ("bat", "install_bat", "bat"),
    ("fd", "install_fd", "fd-find"),
    ("btop", "install_btop", "btop"),
    ("lazygit", "install_lazygit", "lazygit"),
    ("zoxide", "install_zoxide", "zoxide"),
    ("delta", "install_delta", "git-delta"),
    ("tldr", "install_tldr", "tldr"),
    ("httpie", "install_httpie", "httpie"),
    ("glances", "install_glances", "glances"),
    ("thefuck", "install_thefuck", "thefuck"),
    ("eza", "install_eza", "eza"),
    ("dust", "install_dust", "du-dust"),
    ("Flameshot", "install_flameshot", "flameshot"),
    ("KeePassXC", "install_keepassxc", "keepassxc"),
    ("mpv", "install_mpv", "mpv"),
    ("Syncthing", "install_syncthing", "syncthing"),
    ("VLC", "install_vlc", "vlc"),
]


def install_simple(name: str, display: str, native: str, aur: str = "", flatpak: str = "", binary: str = "") -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed
    from src.tui.confirm import confirm_install
    from src.core.installers import with_fallback

    b = binary or native.split(",")[0]
    if is_installed(b):
        log_message("WARN", f"{display} is already installed.")
        return 0

    if not confirm_install(display, native):
        return 0

    return with_fallback(display, native, aur, flatpak, b)


def install(name: str) -> int:
    config = {
        "tmux": ("tmux", "tmux"),
        "Neovim": ("Neovim", "neovim"),
        "Docker": ("Docker", "docker.io", "", "", "docker"),
        "jq": ("jq", "jq"),
        "ripgrep": ("ripgrep", "ripgrep"),
        "fzf": ("fzf", "fzf"),
        "bat": ("bat", "bat", "", "", "bat"),
        "fd": ("fd", "fd-find", "fd", "", "fd"),
        "btop": ("btop", "btop"),
        "lazygit": ("lazygit", "lazygit"),
        "zoxide": ("zoxide", "zoxide"),
        "delta": ("delta", "git-delta", "", "", "delta"),
        "tldr": ("tldr", "tldr"),
        "httpie": ("httpie", "httpie"),
        "glances": ("glances", "glances"),
        "thefuck": ("thefuck", "thefuck"),
        "eza": ("eza", "eza"),
        "dust": ("dust", "du-dust", "dust", "", "dust"),
        "Flameshot": ("Flameshot", "flameshot"),
        "KeePassXC": ("KeePassXC", "keepassxc"),
        "mpv": ("mpv", "mpv"),
        "Syncthing": ("Syncthing", "syncthing"),
        "VLC": ("VLC", "vlc"),
    }

    if name not in config:
        from src.core.logging import log_message

        log_message("ERROR", f"Unknown tool: {name}")
        return 1

    return install_simple(name, *config[name])


def install_all() -> int:
    from src.core.logging import log_message

    log_message("INFO", "--- Installing All Dev Tools ---")
    ec = 0
    for name, _, _ in TOOLS:
        if install(name) != 0:
            ec = 1
    return ec


def check() -> None:
    from src.core.logging import log_message
    from src.core.distro import is_installed

    log_message("INFO", "--- Checking Dev Tool Installations ---")
    bins = {
        "tmux": "tmux",
        "Neovim": "nvim",
        "Docker": "docker",
        "jq": "jq",
        "ripgrep": "rg",
        "fzf": "fzf",
        "bat": "bat",
        "fd": "fd",
        "btop": "btop",
        "lazygit": "lazygit",
        "zoxide": "zoxide",
        "delta": "delta",
        "tldr": "tldr",
        "httpie": "httpie",
        "glances": "glances",
        "thefuck": "thefuck",
        "eza": "eza",
        "dust": "dust",
        "Flameshot": "flameshot",
        "KeePassXC": "keepassxc",
        "mpv": "mpv",
        "Syncthing": "syncthing",
        "VLC": "vlc",
    }
    for name, _, _ in TOOLS:
        binary = bins.get(name, name.lower())
        if is_installed(binary):
            print(f"\033[1;32m[✔] {name} is installed.\033[0m")
        else:
            print(f"\033[0;31m[✘] {name} is NOT installed.\033[0m")


if __name__ == "__main__":
    from src.core.bash import setup as bash_setup
    from src.core import distro

    bash_setup(os.path.join(os.path.dirname(__file__), "..", ".."))

    if len(sys.argv) < 2:
        print("Usage: dev_tools.py <install|install_all|check> [name]")
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
