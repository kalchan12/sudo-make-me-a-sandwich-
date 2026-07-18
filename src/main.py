#!/usr/bin/env python3

import sys
import os
import subprocess

SCRIPT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, SCRIPT_DIR)

from src.core import logging


def cmd_banner() -> None:
    pass


def cmd_persona() -> None:
    from rich import box
    from rich.panel import Panel
    from rich.table import Table

    console = logging._console

    distro_id = ""
    pretty_name = ""
    if os.path.exists("/etc/os-release"):
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("ID="):
                    distro_id = line.split("=", 1)[1].strip().strip('"')
                elif line.startswith("PRETTY_NAME="):
                    pretty_name = line.split("=", 1)[1].strip().strip('"')

    kernel = os.uname().release
    de = os.environ.get("XDG_CURRENT_DESKTOP", "Unknown")

    cpu_model = "Unknown"
    cpu_cores = 0
    try:
        with open("/proc/cpuinfo") as f:
            for line in f:
                if line.startswith("model name"):
                    cpu_model = line.split(":", 1)[1].strip()
                    cpu_cores += 1
                elif line.startswith("processor"):
                    cpu_cores += 1
            else:
                cpu_cores = max(cpu_cores, 1)
    except FileNotFoundError:
        pass

    total_ram = 0
    try:
        with open("/proc/meminfo") as f:
            for line in f:
                if line.startswith("MemTotal:"):
                    total_ram = int(line.split()[1]) // 1024 // 1024
                    break
    except FileNotFoundError:
        pass

    table = Table(box=box.SIMPLE, border_style="green")
    table.add_column("Property", style="cyan", no_wrap=True)
    table.add_column("Value", style="green")

    table.add_row("Distro", f"{pretty_name} ({kernel})" if pretty_name else distro_id)
    table.add_row("DE / WM", de)
    table.add_row("CPU", f"{cpu_model} ({cpu_cores} cores)" if cpu_cores else cpu_model)
    table.add_row("Memory", f"{total_ram} GiB" if total_ram else "Unknown")

    panel = Panel(table, title="[magenta]System Profile[/]", box=box.HEAVY, border_style="magenta", padding=(1, 2))
    console.print()
    console.print(panel)
    console.print()


def cmd_exec(args: list[str]) -> None:
    script = os.path.join(SCRIPT_DIR, "setup.sh")
    os.execvp("bash", ["bash", script] + args)


def main() -> None:
    logging.setup()

    if len(sys.argv) < 2:
        cmd_persona()
        cmd_exec([])

    subcommand = sys.argv[1]
    rest = sys.argv[2:]

    if subcommand == "persona":
        cmd_persona()
    elif subcommand == "exec":
        cmd_exec(rest)
    else:
        cmd_exec(sys.argv[1:])


if __name__ == "__main__":
    main()
