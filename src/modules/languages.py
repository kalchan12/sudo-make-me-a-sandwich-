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

CATEGORY = "Languages"

TOOLS: list[tuple[str, str, str]] = [
    ("Python", "install_python", "python3"),
    ("Node.js", "install_nodejs", "node"),
    ("TypeScript", "install_typescript", "typescript"),
    ("Go", "install_go", "go"),
    ("Rust", "install_rust", "rustc"),
    ("Java (OpenJDK)", "install_java", "java"),
    ("C/C++ (GCC)", "install_gcc", "gcc"),
    ("C# (.NET)", "install_dotnet", "dotnet"),
    ("Ruby", "install_ruby", "ruby"),
    ("PHP", "install_php", "php"),
    ("Lua", "install_lua", "lua"),
    ("R", "install_r", "r"),
    ("Zig", "install_zig", "zig"),
    ("Dart", "install_dart", "dart"),
    ("Kotlin", "install_kotlin", "kotlin"),
]

BINS: dict[str, str] = {
    "Python": "python3", "Node.js": "node", "TypeScript": "tsc", "Go": "go", "Rust": "rustc", "Java (OpenJDK)": "java", "C/C++ (GCC)": "gcc", "C# (.NET)": "dotnet", "Ruby": "ruby", "PHP": "php", "Lua": "lua", "R": "Rscript", "Zig": "zig", "Dart": "dart", "Kotlin": "kotlin"
}


def install(name: str) -> int:
    return _install(TOOLS, name)


def install_all() -> int:
    return _install_all(TOOLS, CATEGORY)


def check() -> None:
    _check(TOOLS, BINS, CATEGORY)


if __name__ == "__main__":
    cli_main(TOOLS, BINS, CATEGORY, os.path.basename(__file__))
