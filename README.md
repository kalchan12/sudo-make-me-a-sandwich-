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

### 🖥️ Launching the GUI
Simply run the script in a desktop environment to launch the Graphical User Interface:

```bash
./setup.sh
```

Or explicitly force GUI mode:
```bash
./setup.sh --gui
```

### 💻 Running in Terminal Mode
To force the interactive terminal interface (Rich TUI / Bash menu) in a desktop environment, use `--cli` or `--tui`:

```bash
./setup.sh --cli
# or
./setup.sh --tui
```

*Note: In headless environments, servers, or SSH sessions without a graphical display, `setup.sh` automatically falls back to the terminal mode.*

### ⚡ Direct Command-Line Installation
You can directly pass flags to install specific tools without opening any UI:

```bash
sudo ./setup.sh --install nmap,burpsuite,tmux
sudo ./setup.sh --minimal    # Browsers and Terminals only
sudo ./setup.sh --full       # Everything
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
* [ ] Add Fedora/Arch compatibility
* [ ] Add package manager search mode
