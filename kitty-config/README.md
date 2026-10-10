# 🐱 Kitty Terminal & Zsh Hacker Suite (Modular Edition)

Portable, modular hacker setup for Kitty Terminal and Zsh Shell with real-time syntax highlighting, command prediction, and live theme switching.

---

## ⚡ Quick Import on Any Linux OS

Clone this repo and run the importer:

```bash
git clone https://github.com/kalchan12/sudo-make-me-a-sandwich-.git
cd sudo-make-me-a-sandwich-
./kitty-config/install.sh
```

Supported distros: **Debian, Ubuntu, Kali Linux, Parrot, Arch Linux, Manjaro, Fedora, openSUSE, Alpine, Void**.

---

## 🎨 Modular Kitty Themes

Switch themes on the fly without restarting Kitty using the `kitty-theme` CLI:

```bash
kitty-theme                 # List all available themes & show active one
kitty-theme cyberpunk-neon  # Cyberpunk 2077 Night City aesthetic (Default)
kitty-theme matrix-green    # Phosphor CRT Matrix green
kitty-theme cyber-blood     # Red Team stealth / blood crimson
kitty-theme synthwave-retro # 80s outrun neon
```

Press **`Ctrl+Shift+F5`** inside Kitty anytime to live-reload configuration changes.

---

## 💻 Zsh Features

* **Command Prediction (`zsh-autosuggestions`)**: Automatically predicts and ghost-completes commands based on your command history.
  * Accept full command: <kbd>→</kbd> (Right Arrow), <kbd>Ctrl</kbd>+<kbd>Space</kbd>, or <kbd>Ctrl</kbd>+<kbd>F</kbd>
  * Accept single word: <kbd>Alt</kbd>+<kbd>F</kbd> or <kbd>Ctrl</kbd>+<kbd>→</kbd>
* **Syntax Highlighting (`zsh-syntax-highlighting`)**: Real-time feedback (green for valid commands, red for unknown tokens, yellow for options, cyan for paths).
* **Kali Hacker Prompt (`kali-hacker`)**: Preserves Kali Linux's signature two-line prompt with git branch indicator and command failure codes.

---

## 📁 Folder Structure

```
kitty-config/
├── kitty.conf            # Main modular Kitty configuration
├── themes/               # Modular theme palette files
│   ├── cyberpunk-neon.conf
│   ├── matrix-green.conf
│   ├── cyber-blood.conf
│   ├── synthwave-retro.conf
│   └── active-theme.conf # Symlinked active theme
├── scripts/
│   └── kitty-theme       # Live theme switcher CLI
├── zsh/
│   ├── .zshrc           # Configured Zsh with autosuggestions & highlighting
│   └── themes/          # Custom OMZ themes (kali-hacker & cyberpunk)
├── install.sh            # One-click importer for any Linux distribution
└── README.md
```
