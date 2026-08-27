#!/usr/bin/env python3
"""Shared helpers for tool modules — install, check, CLI dispatch."""

import shutil
import sys
import os


def install(tools: list[tuple[str, str, str]], name: str) -> int:
    """Install a single tool by display name."""
    from src.core import bash
    from src.core.logging import log_message
    for display, bash_fn, _ in tools:
        if display == name:
            log_message("INFO", f"Installing {name}...")
            code, out, err = bash.call(bash_fn)
            if code == 0:
                log_message("SUCCESS", f"{name} installed.")
            else:
                log_message("ERROR", f"{name} install failed (exit {code}).")
                if err:
                    log_message("ERROR", err)
            return code
    log_message("ERROR", f"Unknown tool: {name}")
    return 1


def install_all(tools: list[tuple[str, str, str]], category: str) -> int:
    """Install every tool in the list."""
    from src.core.logging import log_message
    log_message("INFO", f"--- Installing All {category} ---")
    ec = 0
    for name, _, _ in tools:
        if install(tools, name) != 0:
            ec = 1
    return ec


def check(tools: list[tuple[str, str, str]], bins: dict[str, str], category: str) -> None:
    """Check which tools are installed using shutil.which() (binary lookup on PATH)."""
    from src.core.logging import log_message
    from rich.console import Console
    console = Console(highlight=False)
    log_message("INFO", f"--- Checking {category} Installations ---")
    for name, _, _ in tools:
        binary = bins.get(name, name.lower())
        if shutil.which(binary):
            console.print(f"[bold green][✔] {name} is installed.[/]")
        else:
            console.print(f"[red][✘] {name} is NOT installed.[/]")


def cli_main(tools: list[tuple[str, str, str]], bins: dict[str, str], category: str, usage_name: str) -> None:
    """Shared __main__ CLI handler."""
    from src.core.bash import setup as bash_setup
    bash_setup(os.path.join(os.path.dirname(__file__), "..", ".."))
    if len(sys.argv) < 2:
        print(f"Usage: {usage_name} <install|install_all|check> [name]")
        sys.exit(1)
    cmd = sys.argv[1]
    if cmd == "install" and len(sys.argv) > 2:
        sys.exit(install(tools, sys.argv[2]))
    elif cmd == "install" and len(sys.argv) == 2:
        print(f"Usage: {usage_name} install <tool_name>")
        sys.exit(1)
    elif cmd == "install_all":
        sys.exit(install_all(tools, category))
    elif cmd == "check":
        check(tools, bins, category)
    else:
        print(f"Unknown command: {cmd}")
        sys.exit(1)
