import os
from rich.panel import Panel
from rich.table import Table
from rich.text import Text
from rich.prompt import Prompt
from rich import box
from ..core import bash, distro
from ..core.logging import log_message, DRY_RUN


def confirm_install(display_name: str, pkg_name: str = "", extra_info: str = "") -> bool:
    from ..tui.render import console

    yes_mode = os.environ.get("YES_MODE") == "true"
    selection_mode = os.environ.get("SELECTION_MODE") == "true"

    if yes_mode or selection_mode or DRY_RUN:
        return True

    table = Table(box=box.SIMPLE, border_style="green", show_header=False, pad_edge=False)
    table.add_column(style="cyan", width=16)
    table.add_column(style="green")

    table.add_row("Package", display_name)

    if pkg_name and distro.is_available(pkg_name):
        code, out, _ = bash.call("show_package_info", pkg_name)
        if code == 0 and out.strip():
            for line in out.strip().split("\n"):
                if ":" in line:
                    key, val = line.split(":", 1)
                    table.add_row(key.strip(), val.strip())

    if extra_info:
        table.add_row("Info", extra_info)

    panel = Panel(table, title=f"[yellow]Install {display_name}?[/]", border_style="green", padding=(1, 1))
    console.print()
    console.print(panel)
    console.print()

    try:
        response = Prompt.ask("[magenta]Proceed?[/]", choices=["y", "n", "Y", "N"], default="n")
        return response.lower() == "y"
    except (EOFError, KeyboardInterrupt):
        print()
        return False
