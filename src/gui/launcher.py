#!/usr/bin/env python3
"""GUI launcher with toolkit auto-detection (GTK 3 primary, Tkinter fallback)."""

import os
import sys


def is_gui_available() -> bool:
    """Check if graphical environment and at least one GUI library is available."""
    has_display = bool(os.environ.get("DISPLAY") or os.environ.get("WAYLAND_DISPLAY"))
    if not has_display:
        return False

    # Check GTK 3
    try:
        import gi
        gi.require_version("Gtk", "3.0")
        from gi.repository import Gtk
        ok, _ = Gtk.init_check()
        if ok:
            return True
    except Exception:
        pass

    # Check Tkinter
    try:
        import tkinter
        tk = tkinter.Tk()
        tk.destroy()
        return True
    except Exception:
        pass

    return False


def launch_gui(initial_dry_run: bool = False, initial_verbose: bool = False) -> int:
    """Launch the best available GUI."""
    has_display = bool(os.environ.get("DISPLAY") or os.environ.get("WAYLAND_DISPLAY"))
    if not has_display:
        print("[ERROR] No graphical display detected (DISPLAY / WAYLAND_DISPLAY not set).", file=sys.stderr)
        return 1

    # 1. Try GTK 3 (native Linux desktop)
    try:
        import gi
        gi.require_version("Gtk", "3.0")
        from gi.repository import Gtk
        ok, _ = Gtk.init_check()
        if ok:
            from src.gui.app_gtk import run_gtk_app
            return run_gtk_app(initial_dry_run=initial_dry_run, initial_verbose=initial_verbose)
    except Exception as e:
        print(f"[DEBUG] GTK initialization failed: {e}", file=sys.stderr)

    # 2. Try Tkinter fallback
    try:
        from src.gui.app_tk import run_tk_app
        return run_tk_app(initial_dry_run=initial_dry_run, initial_verbose=initial_verbose)
    except Exception as e:
        print(f"[ERROR] Could not start GUI: {e}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    dry = "--dry-run" in sys.argv
    verb = "-v" in sys.argv or "--verbose" in sys.argv
    sys.exit(launch_gui(initial_dry_run=dry, initial_verbose=verb))
