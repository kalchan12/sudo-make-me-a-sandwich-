#!/usr/bin/env python3
"""Frameworks module — Flutter, React Native, Next.js, Node.js LTS, Electron, Tauri, Deno, Bun"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

TOOLS: list[tuple[str, str, str]] = [
    ("Flutter", "install_flutter", "flutter"),
    ("React Native", "install_react_native", ""),
    ("Next.js", "install_nextjs", ""),
    ("Node.js (Latest)", "install_nodejs_latest", "nodejs"),
    ("Electron", "install_electron", ""),
    ("Tauri", "install_tauri", ""),
    ("Deno", "install_deno", "deno"),
    ("Bun", "install_bun", "bun"),
]


def install(name: str) -> int:
    from src.core.logging import log_message

    dispatch = {
        "Flutter": _install_flutter,
        "React Native": _install_react_native,
        "Next.js": _install_nextjs,
        "Node.js (Latest)": _install_nodejs_latest,
        "Electron": _install_electron,
        "Tauri": _install_tauri,
        "Deno": _install_deno,
        "Bun": _install_bun,
    }

    fn = dispatch.get(name)
    if not fn:
        log_message("ERROR", f"Unknown framework: {name}")
        return 1
    return fn()


def _install_flutter() -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed, DISTRO
    from src.tui.confirm import confirm_install
    from src.core.package_manager import install_native
    from src.core.installers import check_deps, with_fallback
    import subprocess

    if is_installed("flutter"):
        log_message("WARN", "Flutter is already installed.")
        return 0
    confirm_install("Flutter", "flutter")

    if DISTRO == "debian":
        check_deps("Flutter", "curl", "git", "unzip", "xz-utils", "zip", "libglu1-mesa")
        snap_ok = subprocess.run("command -v snap", shell=True, capture_output=True).returncode == 0
        if not snap_ok:
            log_message("INFO", "Installing snapd for Flutter...")
            install_native("snapd")
        r = subprocess.run(["snap", "install", "flutter", "--classic"], capture_output=True, text=True, timeout=300)
        return r.returncode
    elif DISTRO == "arch":
        return with_fallback("Flutter", "", "flutter", "", "flutter")
    elif DISTRO == "fedora":
        check_deps("Flutter", "curl", "git", "unzip", "xz", "mesa-libGLU")
        snap_ok = subprocess.run("command -v snap", shell=True, capture_output=True).returncode == 0
        if not snap_ok:
            install_native("snapd")
            subprocess.run(["systemctl", "enable", "--now", "snapd.socket"], capture_output=True)
            os.symlink("/var/lib/snapd/snap", "/snap")
        r = subprocess.run(["snap", "install", "flutter", "--classic"], capture_output=True, text=True, timeout=300)
        return r.returncode
    return 1


def _install_react_native() -> int:
    from src.core.logging import log_message
    from src.tui.confirm import confirm_install
    import subprocess

    confirm_install("React Native", "", "Requires Node.js and npm")
    r = subprocess.run("command -v npx", shell=True, capture_output=True)
    if r.returncode != 0:
        log_message("ERROR", "Node.js/npm required. Install Node.js first.")
        return 1

    log_message("INFO", "Installing React Native CLI globally...")
    r = subprocess.run(["npm", "install", "-g", "@react-native-community/cli"], capture_output=True, text=True, timeout=300)
    if r.returncode == 0:
        log_message("SUCCESS", "React Native CLI installed.")
    else:
        log_message("ERROR", "Failed to install React Native CLI.")
    return r.returncode


def _install_nextjs() -> int:
    from src.core.logging import log_message
    from src.tui.confirm import confirm_install

    confirm_install("Next.js", "", "Requires Node.js and npm")
    log_message("INFO", "Next.js is available via npx. No global install needed.")
    return 0


def _install_nodejs_latest() -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed, DISTRO
    from src.tui.confirm import confirm_install
    from src.core.package_manager import install_native
    import subprocess

    confirm_install("Node.js (Latest LTS)", "nodejs")

    if DISTRO == "debian":
        log_message("INFO", "Setting up NodeSource repository...")
        r = subprocess.run(
            "curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -",
            capture_output=True, text=True, timeout=120, shell=True,
        )
        if r.returncode != 0:
            log_message("ERROR", "NodeSource setup failed.")
            return r.returncode
        return install_native("nodejs")
    elif DISTRO == "arch":
        return install_native("nodejs", "npm")
    elif DISTRO == "fedora":
        r = subprocess.run(
            "curl -fsSL https://rpm.nodesource.com/setup_lts.x | bash -",
            capture_output=True, text=True, timeout=120, shell=True,
        )
        if r.returncode != 0:
            log_message("ERROR", "NodeSource setup failed.")
            return r.returncode
        return install_native("nodejs")
    return 1


def _install_electron() -> int:
    from src.core.logging import log_message
    from src.tui.confirm import confirm_install
    import subprocess

    confirm_install("Electron", "", "Requires Node.js and npm")
    r = subprocess.run("command -v npm", shell=True, capture_output=True)
    if r.returncode != 0:
        log_message("ERROR", "npm required. Install Node.js first.")
        return 1

    log_message("INFO", "Installing Electron globally...")
    r = subprocess.run(["npm", "install", "-g", "electron"], capture_output=True, text=True, timeout=300)
    if r.returncode == 0:
        log_message("SUCCESS", "Electron installed.")
    else:
        log_message("ERROR", "Failed to install Electron.")
    return r.returncode


def _install_tauri() -> int:
    from src.core.logging import log_message
    from src.tui.confirm import confirm_install
    import subprocess

    confirm_install("Tauri", "", "Requires Rust (cargo)")
    r = subprocess.run("command -v cargo", shell=True, capture_output=True)
    if r.returncode != 0:
        log_message("ERROR", "cargo required. Install Rust first.")
        return 1

    log_message("INFO", "Installing Tauri CLI...")
    r = subprocess.run(["cargo", "install", "tauri-cli"], capture_output=True, text=True, timeout=600)
    if r.returncode == 0:
        log_message("SUCCESS", "Tauri CLI installed.")
    else:
        log_message("ERROR", "Failed to install Tauri CLI.")
    return r.returncode


def _install_deno() -> int:
    from src.core.logging import log_message
    from src.core.distro import DISTRO
    from src.tui.confirm import confirm_install
    from src.core.package_manager import install_native
    import subprocess

    confirm_install("Deno", "deno")

    if DISTRO == "arch":
        return install_native("deno")
    else:
        log_message("INFO", "Installing Deno via install script...")
        r = subprocess.run(
            "curl -fsSL https://deno.land/install.sh | sh",
            capture_output=True, text=True, timeout=120, shell=True,
        )
        if r.returncode == 0:
            log_message("SUCCESS", "Deno installed.")
        else:
            log_message("ERROR", "Deno install failed.")
        return r.returncode


def _install_bun() -> int:
    from src.core.logging import log_message
    from src.tui.confirm import confirm_install
    import subprocess

    confirm_install("Bun", "bun")
    log_message("INFO", "Installing Bun via install script...")
    r = subprocess.run(
        "curl -fsSL https://bun.sh/install | bash",
        capture_output=True, text=True, timeout=120, shell=True,
    )
    if r.returncode == 0:
        log_message("SUCCESS", "Bun installed.")
    else:
        log_message("ERROR", "Bun install failed.")
    return r.returncode


def install_all() -> int:
    from src.core.logging import log_message

    log_message("INFO", "--- Installing All Frameworks ---")
    ec = 0
    for name, _, _ in TOOLS:
        if install(name) != 0:
            ec = 1
    return ec


def check() -> None:
    from src.core.logging import log_message
    from src.core.distro import is_installed

    log_message("INFO", "--- Checking Framework Installations ---")
    bins = {
        "Flutter": "flutter",
        "React Native": "npx",
        "Next.js": "npx",
        "Node.js (Latest)": "node",
        "Electron": "electron",
        "Tauri": "tauri",
        "Deno": "deno",
        "Bun": "bun",
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
        print("Usage: frameworks.py <install|install_all|check> [name]")
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
