from pathlib import Path
from . import bash

OS_PRETTY_NAME: str = ""
OS_ID: str = ""
OS_ID_LIKE: str = ""
DISTRO: str = ""
PKG_MANAGER: str = ""


def detect() -> None:
    global OS_PRETTY_NAME, OS_ID, OS_ID_LIKE, DISTRO, PKG_MANAGER

    os_release = Path("/etc/os-release")
    if os_release.exists():
        for line in os_release.read_text().splitlines():
            if line.startswith("PRETTY_NAME="):
                OS_PRETTY_NAME = line.split("=", 1)[1].strip().strip('"')
            elif line.startswith("ID="):
                OS_ID = line.split("=", 1)[1].strip().strip('"')
            elif line.startswith("ID_LIKE="):
                OS_ID_LIKE = line.split("=", 1)[1].strip().strip('"')

    if Path("/etc/debian_version").exists():
        DISTRO = "debian"
        PKG_MANAGER = "apt"
    elif Path("/etc/arch-release").exists():
        DISTRO = "arch"
        PKG_MANAGER = "pacman"
    elif Path("/etc/fedora-release").exists() or OS_ID == "fedora":
        DISTRO = "fedora"
        PKG_MANAGER = "dnf"
    else:
        for line in Path("/etc/os-release").read_text().splitlines():
            if line.startswith("ID_LIKE="):
                like = line.split("=", 1)[1].strip().strip('"')
                if "debian" in like:
                    DISTRO = "debian"
                    PKG_MANAGER = "apt"
                elif "fedora" in like:
                    DISTRO = "fedora"
                    PKG_MANAGER = "dnf"
                elif "arch" in like:
                    DISTRO = "arch"
                    PKG_MANAGER = "pacman"
                break
        else:
            DISTRO = "unknown"
            PKG_MANAGER = "unknown"


def is_installed(pkg: str) -> bool:
    code, _, _ = bash.call("pkg_is_installed", pkg)
    return code == 0


def is_available(pkg: str) -> bool:
    code, _, _ = bash.call("pkg_is_available", pkg)
    return code == 0
