from rich.console import Console
from rich.panel import Panel
from rich.table import Table
from rich.text import Text
from rich import box

console = Console(highlight=False)


def show_main_menu() -> str:
    from rich.prompt import Prompt

    console.clear()
    console.print()

    title = Text("╔══╗╚══╝", style="magenta")
    title.append("\n")

    table = Table(box=box.SIMPLE, border_style="magenta", show_header=False, pad_edge=False)
    table.add_column(style="yellow", width=3)
    table.add_column(style="green")

    categories = [
        ("1", "Browsers"),
        ("2", "Productivity"),
        ("3", "IDEs & Editors"),
        ("4", "Terminals"),
        ("5", "Shells"),
        ("6", "Dev Tools"),
        ("7", "Languages"),
        ("8", "Pentesting"),
        ("9", "Frameworks"),
    ]

    for num, name in categories:
        table.add_row(f"{num})", name)

    table.add_section()
    table.add_row("10)", "[green]Full Install (everything)[/]")
    table.add_row("11)", "[green]Minimal Install (browsers + terminals)[/]")
    table.add_section()
    table.add_row("12)", "[red]Exit[/]")

    panel = Panel(
        table,
        title="[magenta]╔══╗╚══╝[/]",
        box=box.HEAVY,
        border_style="magenta",
        padding=(1, 2),
    )
    console.print(panel)
    console.print()
    console.print("[magenta]Enter a number to install, or e<N> for details (e.g., e1)[/]")

    choice = Prompt.ask("[magenta]Select option[/]", default="")
    return choice.strip()


def render_menu(
    tools: list[tuple[str, str]],
    title: str,
    on_all: str = "",
    on_check: str = "",
    on_back: str = "",
) -> str:
    from rich.prompt import Prompt

    console.print()

    table = Table(
        box=box.SIMPLE,
        border_style="magenta",
        show_header=False,
        pad_edge=False,
        title=f"[magenta]── {title} ──[/]",
    )
    table.add_column(style="yellow", width=3)
    table.add_column(style="green")

    for i, (name, _) in enumerate(tools, 1):
        table.add_row(f"{i})", name)

    table.add_section()
    table.add_row(f"{len(tools) + 1})", "[green]Install All[/]")
    table.add_row(f"{len(tools) + 2})", "[green]Check Installations[/]")
    table.add_row(f"{len(tools) + 3})", "[green]Back[/]")

    console.print(table)
    console.print()
    console.print(f"[magenta]Enter a number to install, or e<N> for details (e.g., e1)[/]")

    choice = Prompt.ask("[magenta]Select option[/]", default="")
    return choice.strip()
