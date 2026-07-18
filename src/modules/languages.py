#!/usr/bin/env python3
"""Languages module — 15 programming languages"""

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", ".."))

TOOLS: list[tuple[str, str, str]] = [
    ("Python", "install_python", "python3"),
    ("Node.js", "install_nodejs", "nodejs"),
    ("TypeScript", "install_typescript", ""),
    ("Go", "install_go", "golang"),
    ("Rust", "install_rust", "rust"),
    ("Java (OpenJDK)", "install_java", "default-jdk"),
    ("C/C++ (GCC)", "install_gcc", "build-essential"),
    ("C# (.NET)", "install_dotnet", "dotnet-sdk"),
    ("Ruby", "install_ruby", "ruby"),
    ("PHP", "install_php", "php"),
    ("Lua", "install_lua", "lua"),
    ("R", "install_r", "r-base"),
    ("Zig", "install_zig", "zig"),
    ("Dart", "install_dart", "dart"),
    ("Kotlin", "install_kotlin", "kotlin"),
]


def install(name: str) -> int:
    from src.core.logging import log_message

    dispatch = {
        "Python": _install_python,
        "Node.js": _install_nodejs,
        "TypeScript": _install_typescript,
        "Go": _install_simple,
        "Rust": _install_rust,
        "Java (OpenJDK)": _install_simple,
        "C/C++ (GCC)": _install_gcc,
        "C# (.NET)": _install_dotnet,
        "Ruby": _install_simple,
        "PHP": _install_simple,
        "Lua": _install_simple,
        "R": _install_simple,
        "Zig": _install_simple,
        "Dart": _install_dart,
        "Kotlin": _install_simple,
    }

    fn = dispatch.get(name)
    if not fn:
        log_message("ERROR", f"Unknown language: {name}")
        return 1
    return fn(name)


def _install_simple(name: str) -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed, DISTRO
    from src.tui.confirm import confirm_install
    from src.core.installers import with_fallback

    config = {
        "Go": ("Go", "golang", "go", "", "go"),
        "Java (OpenJDK)": ("Java (OpenJDK)", "default-jdk", "jdk-openjdk", "", "java"),
        "Ruby": ("Ruby", "ruby", "", "", "ruby"),
        "PHP": ("PHP", "php", "", "", "php"),
        "Lua": ("Lua", "lua", "", "", "lua"),
        "R": ("R", "r-base", "r", "", "R"),
        "Zig": ("Zig", "zig", "", "", "zig"),
        "Kotlin": ("Kotlin", "kotlin", "", "", "kotlin"),
    }

    cfg = config.get(name)
    if not cfg:
        return 1

    display, native, aur, flatpak, binary = cfg
    if is_installed(binary):
        log_message("WARN", f"{name} is already installed.")
        return 0
    confirm_install(name, native)
    return with_fallback(display, native, aur, flatpak, binary)


def _install_python(name: str) -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed, DISTRO
    from src.tui.confirm import confirm_install
    from src.core.package_manager import install_native

    if is_installed("python3"):
        log_message("WARN", "Python is already installed.")
        return 0
    confirm_install("Python", "python3")
    if DISTRO == "debian":
        return install_native("python3", "python3-pip")
    elif DISTRO == "arch":
        return install_native("python", "python-pip")
    else:
        return install_native("python3", "python3-pip")


def _install_nodejs(name: str) -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed, DISTRO
    from src.tui.confirm import confirm_install

    if is_installed("node"):
        log_message("WARN", "Node.js is already installed.")
        return 0
    confirm_install("Node.js", "nodejs")

    if DISTRO == "debian":
        import subprocess
        log_message("INFO", "Installing Node.js via NodeSource...")
        r1 = subprocess.run(
            "curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -",
            capture_output=True, text=True, timeout=120, shell=True,
        )
        if r1.returncode != 0:
            log_message("ERROR", "NodeSource setup failed.")
            return r1.returncode
        from src.core.package_manager import install_native
        return install_native("nodejs")
    else:
        from src.core.package_manager import install_native
        return install_native("nodejs", "npm")


def _install_typescript(name: str) -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed
    from src.tui.confirm import confirm_install
    from src.core.installers import check_deps

    if is_installed("tsc"):
        log_message("WARN", "TypeScript is already installed.")
        return 0

    if not confirm_install("TypeScript", ""):
        return 0

    if not check_deps("TypeScript", "node", "npm"):
        return 1

    import subprocess
    log_message("INFO", "Installing TypeScript via npm...")
    r = subprocess.run(
        ["npm", "install", "-g", "typescript"],
        capture_output=True, text=True, timeout=120,
    )
    if r.returncode == 0:
        log_message("SUCCESS", "TypeScript installed.")
    else:
        log_message("ERROR", "npm install failed.")
    return r.returncode


def _install_rust(name: str) -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed
    from src.tui.confirm import confirm_install

    if is_installed("rustc"):
        log_message("WARN", "Rust is already installed.")
        return 0
    confirm_install("Rust", "rust")

    import subprocess
    log_message("INFO", "Installing Rust via rustup...")
    r = subprocess.run(
        "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y",
        capture_output=True, text=True, timeout=300, shell=True,
    )
    if r.returncode == 0:
        log_message("SUCCESS", "Rust installed.")
    else:
        log_message("ERROR", "Rust install failed.")
    return r.returncode


def _install_gcc(name: str) -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed, DISTRO
    from src.tui.confirm import confirm_install
    from src.core.package_manager import install_native

    if is_installed("gcc") and is_installed("g++"):
        log_message("WARN", "GCC is already installed.")
        return 0
    confirm_install("C/C++ (GCC)", "build-essential")

    if DISTRO == "debian":
        return install_native("build-essential")
    elif DISTRO == "arch":
        return install_native("base-devel")
    else:
        return install_native("gcc", "gcc-c++", "make")


def _install_dotnet(name: str) -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed, DISTRO
    from src.tui.confirm import confirm_install
    from src.core.package_manager import install_native

    if is_installed("dotnet"):
        log_message("WARN", ".NET SDK is already installed.")
        return 0
    confirm_install("C# (.NET)", "dotnet-sdk")

    if DISTRO == "debian":
        import subprocess
        log_message("INFO", "Setting up Microsoft repository...")
        subprocess.run(
            "wget -q https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb "
            "-O /tmp/packages-microsoft-prod.deb",
            capture_output=True, text=True, timeout=60, shell=True,
        )
        subprocess.run(
            "dpkg -i /tmp/packages-microsoft-prod.deb && rm -f /tmp/packages-microsoft-prod.deb",
            capture_output=True, text=True, timeout=60, shell=True,
        )
        return install_native("dotnet-sdk-8.0")
    elif DISTRO == "arch":
        return install_native("dotnet-sdk")
    else:
        return install_native("dotnet-sdk-8.0")


def _install_dart(name: str) -> int:
    from src.core.logging import log_message
    from src.core.distro import is_installed, DISTRO
    from src.tui.confirm import confirm_install
    from src.core.package_manager import install_native

    if is_installed("dart"):
        log_message("WARN", "Dart is already installed.")
        return 0
    confirm_install("Dart", "dart")

    if is_installed("dart"):
        return 0
    if DISTRO == "debian":
        import subprocess
        subprocess.run(
            "wget -qO /etc/apt/sources.list.d/dart_stable.list "
            "https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list",
            capture_output=True, text=True, timeout=30, shell=True,
        )
        return install_native("dart")
    else:
        return install_native("dart")


def install_all() -> int:
    from src.core.logging import log_message

    log_message("INFO", "--- Installing All Languages ---")
    ec = 0
    for name, _, _ in TOOLS:
        if install(name) != 0:
            ec = 1
    return ec


def check() -> None:
    from src.core.logging import log_message
    from src.core.distro import is_installed

    log_message("INFO", "--- Checking Language Installations ---")
    bins = {
        "Python": "python3",
        "Node.js": "node",
        "TypeScript": "tsc",
        "Go": "go",
        "Rust": "rustc",
        "Java (OpenJDK)": "java",
        "C/C++ (GCC)": "gcc",
        "C# (.NET)": "dotnet",
        "Ruby": "ruby",
        "PHP": "php",
        "Lua": "lua",
        "R": "R",
        "Zig": "zig",
        "Dart": "dart",
        "Kotlin": "kotlin",
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
        print("Usage: languages.py <install|install_all|check> [name]")
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
