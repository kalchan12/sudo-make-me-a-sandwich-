# sudo-make-me-a-sandwich

A modular Linux bootstrapper for Debian-based distros.  
Instead of hunting down install commands every time you reinstall, this script automates installing your favorite tools with a single command.

## Features
- **Modular design** – add/remove apps without touching the core logic.
- **Rich TUI** – interactive menu with system profile, tool categories, and install confirmation (auto-detects Python 3 + rich).
- **Verbose mode** – `--verbose` / `-v` shows every command before it runs.
- **Dry-run** – `DRY_RUN=true` previews commands without executing.
- **One-liner install** – no manual cloning needed.

## Requirements
- A Debian-based Linux distro (Ubuntu, Kali, Mint, Parrot, Debian, etc.).
- `bash` shell (most distros have it by default).
- Internet connection.
- `curl` or `wget` (for downloading .deb packages or keys).
- Python 3 + `rich` (optional — auto-detected; falls back to bash menus if not available).

## One-Liner Install
```bash
curl -fsSL https://raw.githubusercontent.com/kalchan12/sudo-make-me-a-sandwich-/main/install.sh | bash
```

Or with flags:

```bash
curl -fsSL https://raw.githubusercontent.com/kalchan12/sudo-make-me-a-sandwich-/main/install.sh | bash -s -- --verbose --install nmap,burpsuite
```

## Manual Install
```bash
git clone https://github.com/kalchan12/sudo-make-me-a-sandwich-.git
cd sudo-make-me-a-sandwich
chmod +x setup.sh
./setup.sh
```

## Roadmap

* [x] Core modular Bash installer
* [x] App selection menu (bash + rich TUI)
* [x] Python integration (rich TUI menus, confirmation dialogs, explanations)
* [ ] Add Fedora/Arch compatibility
* [ ] Add package manager search mode
