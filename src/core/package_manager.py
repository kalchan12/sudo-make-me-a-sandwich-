from . import bash, distro
from .logging import log_message, verbose_cmd, dry_run_cmd, DRY_RUN


def install_native(*pkgs: str) -> int:
    for pkg in pkgs:
        verbose_cmd(f"{distro.PKG_MANAGER} install -y -V {pkg}")
        dry_run_cmd(f"{distro.PKG_MANAGER} install -y -V {pkg}")
        if DRY_RUN:
            continue
        code, _, _ = bash.call("pkg_install_native", pkg)
        if code != 0:
            log_message("ERROR", f"Package install failed for {pkg} (exit code {code}).")
            return code
    return 0


def remove(*pkgs: str) -> int:
    for pkg in pkgs:
        verbose_cmd(f"{distro.PKG_MANAGER} remove -y {pkg}")
        dry_run_cmd(f"{distro.PKG_MANAGER} remove -y {pkg}")
        if DRY_RUN:
            continue
        code, _, _ = bash.call("pkg_remove", pkg)
        if code != 0:
            log_message("ERROR", f"Package remove failed for {pkg} (exit code {code}).")
            return code
    return 0


def update_system() -> int:
    cmd_map = {
        "apt": "apt update && apt upgrade -y -V",
        "pacman": "pacman -Syu --noconfirm",
        "dnf": "dnf upgrade -y",
    }
    cmd = cmd_map.get(distro.PKG_MANAGER, "")
    if not cmd:
        return 1
    verbose_cmd(cmd)
    dry_run_cmd(cmd)
    if DRY_RUN:
        return 0
    log_message("INFO", "Updating package lists and upgrading system...")
    code, _, _ = bash.call("pkg_update_system")
    if code == 0:
        log_message("SUCCESS", "System is up to date.")
    else:
        log_message("ERROR", f"System update failed (exit code {code}).")
    return code
