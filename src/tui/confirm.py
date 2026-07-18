import os
from ..core import bash
from ..core.logging import log_message, DRY_RUN


def confirm_install(display_name: str, pkg_name: str = "", extra_info: str = "") -> bool:
    from ..core import distro

    if extra_info:
        log_message("INFO", f"{display_name}: {extra_info}")

    if pkg_name and distro.is_available(pkg_name):
        code, out, _ = bash.call("show_package_info", pkg_name)
        if code == 0 and out.strip():
            print(out)

    yes_mode = os.environ.get("YES_MODE") == "true"
    selection_mode = os.environ.get("SELECTION_MODE") == "true"

    if yes_mode or selection_mode or DRY_RUN:
        return True

    try:
        response = input(f"Install {display_name}? [y/N]: ").strip().lower()
        return response in ("y", "yes")
    except (EOFError, KeyboardInterrupt):
        print()
        return False
