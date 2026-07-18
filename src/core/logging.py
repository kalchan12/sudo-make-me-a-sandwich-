from datetime import datetime
from rich.console import Console
from rich.style import Style

LOG_FILE: str = ""
VERBOSE_MODE: bool = False
DRY_RUN: bool = False

_console = Console(highlight=False)
_colors = {
    "INFO": "blue",
    "SUCCESS": "green",
    "WARN": "yellow",
    "ERROR": "red",
}


def setup(log_path: str = "", verbose: bool = False, dry_run: bool = False) -> None:
    global LOG_FILE, VERBOSE_MODE, DRY_RUN
    LOG_FILE = log_path
    VERBOSE_MODE = verbose
    DRY_RUN = dry_run


def log_message(msg_type: str, msg: str) -> None:
    style = _colors.get(msg_type, "white")
    _console.print(f"[{style}][{msg_type}][/] {msg}")
    if LOG_FILE:
        ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        with open(LOG_FILE, "a") as f:
            f.write(f"[{ts}] [{msg_type}] {msg}\n")


def verbose_cmd(cmd: str) -> None:
    if VERBOSE_MODE:
        _console.print(f"[magenta][CMD][/] {cmd}", style=Style(dim=True))


def dry_run_cmd(cmd: str) -> None:
    if DRY_RUN:
        _console.print(f"[yellow][DRY-RUN][/] {cmd}")
