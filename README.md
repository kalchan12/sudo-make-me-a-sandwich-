# sudo-make-me-a-sandwich

A modular Linux bootstrapper for Debian-based distros.  
Instead of hunting down install commands every time you reinstall, this script automates installing your favorite tools with a single command.

## Features
- **Modular design** – add/remove apps without touching the core logic.
- **Modern Desktop GUI** – graphical interface with category browsing, real-time search, multi-selection, live terminal log streaming, and system profile (auto-launches on desktop).
- **Rich TUI** – interactive terminal menu with system profile, tool categories, and install confirmation (auto-detects Python 3 + rich).
- **Verbose mode** – `--verbose` / `-v` shows every command before it runs.
- **Dry-run** – `DRY_RUN=true` or `--dry-run` previews commands without executing.
- **One-liner install** – no manual cloning needed.

## Requirements
- A Debian-based Linux distro (Ubuntu, Kali, Mint, Parrot, Debian, etc.).
- `bash` shell (most distros have it by default).
- Internet connection.
- `curl` or `wget` (for downloading .deb packages or keys).
- Python 3 + `PyGObject` (standard on Debian/Ubuntu/Mint desktops for the GUI) or `rich` for TUI.

## Usage

### 🚀 Running the Installer
Simply run the script in your terminal:

```bash
./setup.sh
```

When run in a desktop terminal, it lets you choose between the **Terminal Interactive Menu** (default) or the **Graphical User Interface (GUI)**. You can also switch between them at any time.

### 💻 Direct Terminal Mode
To jump directly into the interactive terminal menu (Rich TUI / Bash menu) without prompt:

```bash
./setup.sh --cli
# or
./setup.sh --tui
```

### 🖥️ Direct GUI Mode
To jump directly into the Graphical User Interface:

```bash
./setup.sh --gui
```

*Note: In headless environments, servers, or SSH sessions without a graphical display, `setup.sh` automatically falls back to terminal mode.*

### ⚡ Direct Command-Line Installation
You can directly pass flags to install specific tools without opening any UI:

```bash
sudo ./setup.sh --install nmap,burpsuite,tmux
sudo ./setup.sh --minimal    # Browsers and Terminals only
sudo ./setup.sh --full       # Everything
sudo ./setup.sh --profile psycho   # Install a preset from presets/
sudo ./setup.sh --list       # Browse the full catalog tree
sudo ./setup.sh --explain tmux
```

## Catalog Structure

All three interfaces (Bash CLI, Rich TUI, Desktop GUI) read the **same shared
catalog**, so what you see is identical everywhere. Every tool is a small file
with metadata at the top and its install function below:

```
catalog/
├── general/            # General
│   ├── apps/           # Apps         (obsidian, ffmpeg, wps, ...)
│   ├── browsers/       # Browsers
│   │   ├── mainstream/ # brave, chrome, chromium, firefox, firefox_dev, vivaldi
│   │   └── privacy/    # librewolf, ungoogled_chromium
│   ├── cli_utilities/  # CLI Utilities
│   ├── privacy/        # Privacy (passwords vaults, network anonymity)
│   └── terminal_shells/# Terminal & Shell (terminals/multiplexers/shells)
├── development/        # Development
│   ├── app_frameworks/ # App Frameworks (flutter, electron, tauri, ...)
│   ├── containers/     # Containers
│   ├── editors_ides/   # Editors & IDEs (editors/, ides/, ai_coding/)
│   └── languages/      # Languages
└── security/           # Security
    ├── credentials/    # Credentials (online attacks, offline cracking)
    ├── network/        # Network (scanning, sniffing & MITM, utilities)
    ├── recon_osint/    # Recon & OSINT
    ├── reverse_forensics/
    ├── web/            # Web (discovery & fuzzing, scanners, proxies, exploitation)
    └── wireless/       # Wireless
```

### Adding a Tool

1. Create `catalog/<group>/<category>[/<subgroup>]/<id>.sh`
2. Add the metadata header and installer (copy an existing file as a template):

```bash
# id: mytool
# name: My Tool
# desc: One-line description shown in every UI.
# method: apt
# pkg: mytool-package
# tags: terminal, dev
install_mytool() {
    install_with_fallback "My Tool" "mytool"
}
```

The file is picked up automatically — no lists to edit. A tool id must be a
valid bash function-name suffix (`[a-z0-9_]+`).

### Presets

Presets are simple lists of tool ids in `presets/<name>.list` and can be
installed with `sudo ./setup.sh --profile <name>`. Use the keyword `ALL` for
"everything in the catalog":

```bash
# presets/mysetup.list
kitty
brave
zellij
ALL
```

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
cd sudo-make-me-a-sandwich-
chmod +x setup.sh
./setup.sh
```

## Roadmap

* [x] Core modular Bash installer
* [x] App selection menu (bash + rich TUI)
* [x] Python integration (rich TUI menus, confirmation dialogs, explanations)
* [x] Modern Graphical User Interface (GTK 3 + Tkinter fallback) with real-time log output
* [x] Shared nested catalog (General / Development / Security) driving Bash, TUI and GUI
* [x] Presets (`presets/*.list`) with `--profile <name>`
* [ ] Add Fedora/Arch compatibility
* [ ] Add package manager search mode
