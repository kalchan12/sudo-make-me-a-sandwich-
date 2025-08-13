# sudo-make-me-a-sandwich

A modular Linux bootstrapper for Debian-based distros.  
Instead of hunting down install commands every time you reinstall, this script automates installing your favorite tools with a single command.

## Features
- **Modular design** – add/remove apps without touching the core logic.
- **User choice** – run installs automatically or select apps manually.
- **Future-ready** – framework allows adding Fedora/Arch support later.
- **Python-ready** – can embed Python modules if needed in the future.

## Requirements
- A Debian-based Linux distro (Ubuntu, Kali, Mint, Parrot, Debian, etc.).
- `bash` shell (most distros have it by default).
- Internet connection.
- `curl` or `wget` installed (for downloading .deb packages or keys).

## How to Run
```bash
git clone https://github.com/kalchan12/sudo-make-me-a-sandwich-.git
cd sudo-make-me-a-sandwich
chmod +x setup.sh
./setup.sh
```

## Roadmap

* [ ] Core modular Bash installer
* [ ] App selection menu
* [ ] Add Fedora/Arch compatibility
* [ ] Add package manager search mode
* [ ] Python integration for advanced tasks
