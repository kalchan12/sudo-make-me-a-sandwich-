#!/usr/bin/env python3

import sys
import os
import subprocess

SCRIPT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, SCRIPT_DIR)

from src.core import logging


def cmd_persona() -> None:
    from rich import box
    from rich.panel import Panel
    from rich.table import Table

    console = logging._console

    pretty_name = ""
    if os.path.exists("/etc/os-release"):
        with open("/etc/os-release") as f:
            for line in f:
                if line.startswith("PRETTY_NAME="):
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
                elif line.startswith("processor"):
                    cpu_cores += 1
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

    table.add_row("Distro", f"{pretty_name} ({kernel})" if pretty_name else kernel)
    table.add_row("DE / WM", de)
    table.add_row("CPU", f"{cpu_model} ({cpu_cores} cores)" if cpu_cores else cpu_model)
    table.add_row("Memory", f"{total_ram} GiB" if total_ram else "Unknown")

    panel = Panel(table, title="[magenta]System Profile[/]", box=box.HEAVY,
                  border_style="magenta", padding=(1, 2))
    console.print()
    console.print(panel)
    console.print()


def cmd_explain(name: str) -> int:
    from src.core.bash import setup as bash_setup, call

    bash_setup(SCRIPT_DIR)
    code, out, err = call("_explain_tool", name)
    if out.strip():
        print(out)
    if err.strip():
        print(err, file=sys.stderr)
    return code


def cmd_list() -> None:
    from src.core import catalog

    for group in catalog.groups():
        print(f"\n[{catalog.title_of(group)}]:")
        for cat in catalog.categories(group):
            subs = catalog.subgroups(cat)
            if subs:
                for sub in subs:
                    print(f"  [{catalog.title_of(sub)}]:")
                    for t in catalog.tools_at(sub):
                        print(f"    - {t.name}")
            else:
                print(f"  [{catalog.title_of(cat)}]:")
                for t in catalog.tools_at(cat):
                    print(f"    - {t.name}")


def cmd_menu(category: str = "main") -> None:
    from src.tui.render import show_main_menu, render_menu
    from rich.console import Console

    console = Console()

    if category == "main":
        choice = show_main_menu()
    else:
        tools_list = []
        try:
            import json
            tools_list = json.loads(category)
        except (json.JSONDecodeError, TypeError):
            pass
        choice = render_menu(tools_list, "Category")

    console.print(f"[dim]Selected: {choice}[/]")
    print(choice)


def cmd_interactive(show_splash: bool = True) -> None:
    """Full interactive TUI: banner → persona → main menu → catalog browser → install"""
    import shutil

    from src.core import bash as bash_module
    from src.core import catalog
    from src.core.bash import call as bash_call
    from src.core.logging import log_message
    from src.tui.render import show_main_menu, render_menu

    bash_module.setup(SCRIPT_DIR)
    from src.core import distro
    distro.detect()

    if show_splash:
        subprocess.run(
            ["bash", os.path.join(SCRIPT_DIR, "setup.sh"), "--skip-python", "--banner-only"],
            capture_output=False,
        )
        cmd_persona()

    def run_tool(t) -> None:
        log_message("INFO", f"Installing {t.name}...")
        code, out, err = bash_call(t.fn)
        if code == 0:
            log_message("SUCCESS", f"{t.name} installed.")
        else:
            log_message("ERROR", f"{t.name} install failed (exit {code}).")
            if err:
                log_message("ERROR", err)

    def install_tools(tools, title: str) -> None:
        log_message("INFO", f"--- Installing All {title} ---")
        for t in tools:
            run_tool(t)

    def check_tools(tools, title: str) -> None:
        from rich.console import Console

        log_message("INFO", f"--- Checking {title} Installations ---")
        console = Console(highlight=False)
        for t in tools:
            if any(shutil.which(b) for b in t.bin_names):
                console.print(f"[bold green][✔] {t.name} is installed.[/]")
            else:
                console.print(f"[red][✘] {t.name} is NOT installed.[/]")

    def browse(node_path: str) -> None:
        while True:
            subs = catalog.subgroups(node_path)
            tools = catalog.tools_at(node_path)
            entries: list[tuple[str, str, object]] = [
                (catalog.title_of(s), "node", s) for s in subs
            ] + [(t.name, "tool", t) for t in tools]
            title = catalog.title_of(node_path)
            sub_choice = render_menu([(label, "") for label, _, _ in entries], title)

            back = str(len(entries) + 3)
            check = str(len(entries) + 2)
            all_choice = str(len(entries) + 1)

            if sub_choice == back or sub_choice.lower() in ("back", "b"):
                return

            if sub_choice == check or sub_choice.lower() in ("check", "c"):
                check_tools(catalog.tools_under(node_path), title)
                continue

            if sub_choice == all_choice or sub_choice.lower() in ("all", "a"):
                install_tools(catalog.tools_under(node_path), title)
                continue

            if sub_choice.startswith("e"):
                try:
                    idx = int(sub_choice[1:])
                    if 1 <= idx <= len(entries):
                        label, kind, val = entries[idx - 1]
                        if kind == "tool":
                            cmd_explain(val.name)
                        else:
                            code, out, err = bash_call("_explain_tool", label)
                            if out.strip():
                                print(out)
                            if err.strip():
                                print(err, file=sys.stderr)
                except ValueError:
                    pass
                continue

            try:
                idx = int(sub_choice) - 1
            except ValueError:
                continue
            if not 0 <= idx < len(entries):
                continue
            _, kind, val = entries[idx]
            if kind == "node":
                browse(val)
            else:
                run_tool(val)

    def presets_menu() -> None:
        names = catalog.presets()
        if not names:
            log_message("WARN", "No presets found (presets/).")
            return
        entries = [(n, "preset", n) for n in names]
        while True:
            sub_choice = render_menu([(n, "") for n in names], "Presets & Profiles")
            back = str(len(entries) + 3)
            if sub_choice == back or sub_choice.lower() in ("back", "b"):
                return
            try:
                idx = int(sub_choice) - 1
            except ValueError:
                continue
            if not 0 <= idx < len(entries):
                continue
            name = entries[idx][0]
            tools = catalog.preset_tools(name)
            log_message("INFO", f"--- Applying profile '{name}' ({len(tools)} tools) ---")
            install_tools(tools, name)

    while True:
        choice = show_main_menu()

        if choice in ("15", "exit", "q"):
            break

        if choice.lower() in ("g", "gui"):
            from src.gui.launcher import is_gui_available
            if is_gui_available():
                cmd_gui([])
                break
            else:
                log_message("WARN", "GUI is not available (no display detected).")
                continue

        if choice in ("14", "update"):
            log_message("INFO", "--- Updating System ---")
            bash_call("pkg_update_system")
            continue

        if choice in ("12", "full", "all"):
            log_message("INFO", "--- Full Install ---")
            install_tools(catalog.all_tools(), "All Tools")
            continue

        if choice in ("13", "minimal"):
            log_message("INFO", "--- Minimal Install ---")
            install_tools(catalog.tools_under("general/browsers"), "Browsers")
            install_tools(catalog.tools_under("general/terminal_shells/terminals"), "Terminals")
            continue

        if choice.lower() == "p":
            presets_menu()
            continue

        try:
            idx = int(choice)
        except ValueError:
            continue
        groups = catalog.groups()
        if 0 <= idx < len(groups):
            browse(catalog.group_path(groups[idx]))


def cmd_exec(args: list[str]) -> None:
    script = os.path.join(SCRIPT_DIR, "setup.sh")
    os.execvp("bash", ["bash", script] + args)


def cmd_gui(args: list[str]) -> None:
    from src.gui.launcher import launch_gui
    dry = "--dry-run" in args
    verb = "-v" in args or "--verbose" in args
    sys.exit(launch_gui(initial_dry_run=dry, initial_verbose=verb))


def main() -> None:
    logging.setup()

    if len(sys.argv) < 2:
        from src.gui.launcher import is_gui_available
        if sys.stdin.isatty() and is_gui_available():
            print("\n  Select interface mode:")
            print("    1) Terminal Interactive Menu (CLI / TUI)  [Default]")
            print("    2) Graphical User Interface (Desktop GUI)\n")
            try:
                import select
                rlist, _, _ = select.select([sys.stdin], [], [], 10.0)
                choice = sys.stdin.readline().strip() if rlist else ""
            except Exception:
                try:
                    choice = input("  Enter choice [1/2] (Default: 1): ").strip()
                except Exception:
                    choice = ""

            if choice in ("2", "g", "G", "gui", "GUI"):
                cmd_gui([])
            else:
                cmd_interactive(show_splash=True)
        elif is_gui_available():
            cmd_gui([])
        else:
            cmd_interactive(show_splash=True)
        return

    subcommand = sys.argv[1]
    rest = sys.argv[2:]

    if subcommand in ("gui", "--gui"):
        cmd_gui(rest)
    elif subcommand in ("interactive", "cli", "tui", "--cli", "--tui"):
        cmd_interactive(show_splash=False)
    elif subcommand == "persona":
        cmd_persona()
    elif subcommand == "menu":
        cmd_menu(rest[0] if rest else "main")
    elif subcommand == "explain":
        if rest:
            sys.exit(cmd_explain(" ".join(rest)))
        else:
            print("Usage: main.py explain <tool_name>")
            sys.exit(1)
    elif subcommand == "list":
        cmd_list()
    elif subcommand == "exec":
        cmd_exec(rest)
    else:
        cmd_exec(sys.argv[1:])


if __name__ == "__main__":
    main()

