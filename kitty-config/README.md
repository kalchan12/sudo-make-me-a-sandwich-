# 🐱 Kitty Terminal & Zsh Hacker Suite (Modular Edition)

Portable, modular hacker setup for Kitty Terminal and Zsh Shell with real-time syntax highlighting, history-based command prediction, and live theme switching across 19 custom themes.

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

## 🎨 19 Compelling Themes (Dark & High-Contrast)

All themes feature ultra-dark or pitch-black backdrops with high-contrast text that never causes eye fatigue. Switch instantly without restarting Kitty:

```bash
kitty-theme                 # List all available themes & show active one
kitty-theme <themename>     # Activate theme & instantly live-reload Kitty
```

### 💀 9 Hacker Themes
* **`cyberpunk-neon`** *(Default)*: Obsidian navy-black backdrop (`#0a0b10`) with glowing neon cyan, magenta, and laser yellow.
* **`matrix-green`**: CRT phosphor green aesthetic with pitch black and digital rain highlights (`#00ff66`).
* **`ghost-in-the-shell`**: Deep cybernetic void (`#05080f`) with electric cyan, cyber violet, and ice accents.
* **`mr-robot`**: Pure black `#000000` FSociety terminal with amber-gold phosphor and warning red.
* **`kali-dragon`**: OffSec electric blue (`#00a8ff`) and crimson accents on midnight black (`#07080d`).
* **`neon-abyss`**: Pitch navy void (`#04040a`) with glowing toxic emerald (`#00e676`) and ultraviolet pink.
* **`black-hat`**: Stealth charcoal (`#080808`) with venom green (`#39ff14`) and crisp silver.
* **`cyber-blood`**: Red Team offensive security theme with glowing crimson, hazard amber, and silver text.
* **`synthwave-retro`**: 80s outrun cyberpunk theme with deep violet, neon pink, and bright cyan.

### 💻 10 Modern Dev Themes (Eye-Friendly & Productive)
* **`catppuccin-mocha`**: Soothing velvet dark (`#0f0f17`) with pastel lavender, sky blue, and peach.
* **`tokyo-night-storm`**: Modern deep slate (`#0e1017`) with calm cyan, storm violet, and mint.
* **`gruvbox-dark-hard`**: Warm retro dark (`#141617`) with comfortable contrast; zero blue-light strain.
* **`nord-deep-abyss`**: Deep arctic night (`#0a0e14`) with frost blue and aurora green.
* **`rose-pine-moon`**: Elegant muted slate (`#0f0d19`) with soft rosé, gold, and foam teal.
* **`kanagawa-wave`**: Traditional Japanese ink (`#0d0e12`) with sumi ink and autumn peach/wave blues.
* **`onedark-pro`**: Iconic Atom slate (`#0f1117`) with vibrant syntax colors and balanced contrast.
* **`everforest-deep`**: Natural forest night (`#0e1411`) with calming matcha green and earth amber.
* **`solarized-dark-cyan`**: True deep solarized (`#001117`) without muddy tones; razor-sharp cyan and yellow.
* **`dracula-midnight`**: Vampiric obsidian (`#08070d`) with neon purple, pink, and bright cyan.

> [!TIP]
> You can also press **`Ctrl+Shift+F5`** inside Kitty anytime to live-reload configuration changes.

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
├── themes/               # 19 Modular theme palette files (.conf)
├── scripts/
│   └── kitty-theme       # Live theme switcher CLI
├── zsh/
│   ├── .zshrc           # Configured Zsh with autosuggestions & highlighting
│   └── themes/          # Custom OMZ themes (kali-hacker & cyberpunk)
├── install.sh            # One-click importer for any Linux distribution
└── README.md
```
