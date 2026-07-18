#!/usr/bin/env python3
"""Productivity module — Obsidian, WPS Office, OBS Studio, ffmpeg, yt-dlp"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

TOOLS: list[tuple[str, str, str]] = [
    ("Obsidian", "install_obsidian", "obsidian"),
    ("WPS Office", "install_wps", "wps"),
    ("OBS Studio", "install_obs_studio", "obs-studio"),
    ("ffmpeg", "install_ffmpeg", "ffmpeg"),
    ("yt-dlp", "install_yt_dlp", "yt-dlp"),
]


def install(name: str) -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed, DISTRO
    from src.tui.confirm import confirm_install
    from src.core.installers import with_fallback, check_deps
    from src.core.package_manager import install_native
    import subprocess

    # ---- ffmpeg ----
    if name == "ffmpeg":
        if is_installed("ffmpeg"):
            log_message("WARN", "ffmpeg is already installed.")
            return 0
        confirm_install("ffmpeg", "ffmpeg")
        return with_fallback("ffmpeg", "ffmpeg", "ffmpeg", "org.ffmpeg.ffmpeg", "ffmpeg")

    # ---- yt-dlp ----
    if name == "yt-dlp":
        if is_installed("yt-dlp"):
            log_message("WARN", "yt-dlp is already installed.")
            return 0
        confirm_install("yt-dlp", "yt-dlp")
        return with_fallback("yt-dlp", "yt-dlp", "yt-dlp", "", "yt-dlp")

    # ---- OBS Studio ----
    if name == "OBS Studio":
        if is_installed("obs"):
            log_message("WARN", "OBS Studio is already installed.")
            return 0
        confirm_install("OBS Studio", "obs-studio")
        if DISTRO == "debian":
            check_deps("OBS Studio (recommended)", "libavcodec-extra")
        return with_fallback("OBS Studio", "obs-studio", "obs-studio", "com.obsproject.Studio", "obs")

    # ---- WPS Office ----
    if name == "WPS Office":
        if is_installed("wps"):
            log_message("WARN", "WPS Office is already installed.")
            return 0
        confirm_install("WPS Office", "")

        if DISTRO == "debian":
            if subprocess.run("command -v flatpak", shell=True, capture_output=True).returncode == 0:
                r = subprocess.run(["flatpak", "install", "-y", "flathub", "com.wps.Office"],
                                   capture_output=True, text=True, timeout=300)
                return r.returncode
            else:
                install_native("flatpak")
                subprocess.run(["flatpak", "remote-add", "--if-not-exists", "flathub",
                                "https://flathub.org/repo/flathub.flatpakrepo"],
                               capture_output=True, timeout=60)
                r = subprocess.run(["flatpak", "install", "-y", "flathub", "com.wps.Office"],
                                   capture_output=True, text=True, timeout=300)
                return r.returncode
        elif DISTRO == "arch":
            return with_fallback("WPS Office", "", "wps-office", "com.wps.Office", "wps")
        else:
            return with_fallback("WPS Office", "", "", "com.wps.Office", "wps")

    # ---- Obsidian ----
    if name == "Obsidian":
        return _install_obsidian()

    log_message("ERROR", f"Unknown tool: {name}")
    return 1


def _install_obsidian() -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed, DISTRO
    from src.tui.confirm import confirm_install
    from src.core.package_manager import install_native
    from src.core.installers import with_fallback, check_deps
    import subprocess
    import json

    if is_installed("obsidian"):
        log_message("WARN", "Obsidian is already installed.")
        return 0
    confirm_install("Obsidian", "obsidian")

    if DISTRO != "debian":
        if DISTRO == "arch":
            return with_fallback("Obsidian", "obsidian", "obsidian", "md.obsidian.Obsidian", "obsidian")
        return with_fallback("Obsidian", "obsidian", "", "md.obsidian.Obsidian", "obsidian")

    # Debian: apt -> flatpak -> direct download
    if subprocess.run("apt-cache show obsidian &>/dev/null", shell=True).returncode == 0:
        return install_native("obsidian")

    if subprocess.run("command -v flatpak", shell=True, capture_output=True).returncode == 0:
        r = subprocess.run(["flatpak", "install", "-y", "flathub", "md.obsidian.Obsidian"],
                           capture_output=True, text=True, timeout=300)
        if r.returncode == 0:
            log_message("SUCCESS", "Obsidian installed via Flatpak.")
        return r.returncode

    check_deps("Obsidian", "curl", "jq", "wget")
    log_message("INFO", "Downloading latest Obsidian .deb...")
    r = subprocess.run(
        "curl -s https://api.github.com/repos/obsidianmd/obsidian-releases/releases/latest "
        "| jq -r '.assets[] | select(.name | endswith(\"_amd64.deb\")) | .browser_download_url' "
        "| head -1",
        capture_output=True, text=True, timeout=30, shell=True,
    )
    deb_url = r.stdout.strip()
    if not deb_url or deb_url == "null":
        log_message("ERROR", "Could not fetch Obsidian .deb URL.")
        return 1

    r = subprocess.run(["wget", "--progress=bar:force", "-O", "/tmp/obsidian.deb", deb_url],
                       capture_output=True, text=True, timeout=120)
    if r.returncode != 0:
        log_message("ERROR", "Failed to download Obsidian .deb.")
        return r.returncode

    r = subprocess.run("dpkg -i /tmp/obsidian.deb || apt install -f -y",
                       capture_output=True, text=True, timeout=120, shell=True)
    os.unlink("/tmp/obsidian.deb")
    if r.returncode == 0:
        log_message("SUCCESS", "Obsidian installed via .deb.")
    return r.returncode


def install_all() -> int:
    from src.core.logging import log_message

    log_message("INFO", "--- Installing All Productivity Tools ---")
    ec = 0
    for name, _, _ in TOOLS:
        if install(name) != 0:
            ec = 1
    return ec


def check() -> None:
    from src.core.logging import log_message
    from src.core.distro import is_installed

    log_message("INFO", "--- Checking Productivity Installations ---")
    bins = {
        "Obsidian": "obsidian",
        "WPS Office": "wps",
        "OBS Studio": "obs",
        "ffmpeg": "ffmpeg",
        "yt-dlp": "yt-dlp",
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
        print("Usage: productivity.py <install|install_all|check> [name]")
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
