from . import bash, distro
from .logging import log_message, verbose_cmd, DRY_RUN


def with_fallback(
    display_name: str,
    pkg_native: str = "",
    pkg_aur: str = "",
    flatpak_id: str = "",
    bin_check: str = "",
) -> int:
    if not bin_check:
        bin_check = pkg_native

    if distro.is_installed(bin_check) or distro.is_available(bin_check):
        native(display_name, pkg_native, bin_check)
        return 0

    if distro.DISTRO == "arch" and pkg_aur:
        log_message("INFO", f"Installing {display_name} via AUR...")
        code, _, _ = bash.call("aur_install", pkg_aur)
        if code == 0:
            log_message("SUCCESS", f"{display_name} installed via AUR.")
            return 0

    if flatpak_id:
        code = flatpak_install(display_name, flatpak_id, bin_check)
        return code

    log_message("ERROR", f"{display_name} is not available in any source.")
    return 1


def native(display_name: str, pkg: str, bin_check: str = "") -> int:
    from .package_manager import install_native

    log_message("INFO", f"Installing {display_name} via {distro.PKG_MANAGER}...")
    code = install_native(pkg)
    if code == 0:
        log_message("SUCCESS", f"{display_name} installed.")
    else:
        log_message("ERROR", f"Failed to install {display_name}.")
    return code


def flatpak_install(display_name: str, flatpak_id: str, bin_check: str = "") -> int:
    verbose_cmd(f"flatpak install -y flathub {flatpak_id}")
    if DRY_RUN:
        return 0

    import subprocess

    result = subprocess.run(
        ["flatpak", "install", "-y", "flathub", flatpak_id],
        capture_output=True,
        text=True,
        timeout=300,
    )
    if result.returncode == 0:
        log_message("SUCCESS", f"{display_name} installed via Flatpak.")
    else:
        log_message("ERROR", f"Flatpak install failed for {display_name}.")
    return result.returncode


def aur_install(pkg: str) -> int:
    verbose_cmd(f"yay -S --noconfirm {pkg}")
    if DRY_RUN:
        return 0
    return bash.call("aur_install", pkg)[0]


def ensure_prerequisites() -> None:
    from .package_manager import install_native

    missing = []
    for cmd, pkg in (("curl", "curl"), ("wget", "wget"), ("gpg", "gnupg"), ("jq", "jq"), ("flatpak", "flatpak")):
        import shutil

        if not shutil.which(cmd):
            missing.append(pkg)
    if missing:
        log_message("INFO", f"Installing missing prerequisites: {', '.join(missing)}")
        install_native(*missing)


def check_deps(tool: str, *deps: str) -> bool:
    import shutil

    missing = [d for d in deps if not shutil.which(d)]
    if not missing:
        return True

    from .logging import log_message

    log_message("INFO", f"{tool} requires: {', '.join(missing)}")

    from ..tui.confirm import confirm_install

    if not confirm_install(f"dependencies ({', '.join(missing)})", ""):
        return False

    from .package_manager import install_native

    code = install_native(*missing)
    return code == 0
