#!/usr/bin/env bash
# ==============================================================================
# KITTY-CONFIG & ZSH IMPORTER FOR ANY LINUX DISTRO
# ==============================================================================
# Usage:
#   cd sudo-make-me-a-sandwich-
#   ./kitty-config/install.sh
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║      IMPORTING KITTY & ZSH HACKER CONFIGURATION       ║${NC}"
echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════════════╝${NC}"

# Detect sudo privileges
SUDO=""
if [ "$EUID" -ne 0 ]; then
    if command -v sudo &>/dev/null; then
        SUDO="sudo"
    fi
fi

# Detect package manager
detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then PKG="apt";
    elif command -v pacman &>/dev/null; then PKG="pacman";
    elif command -v dnf &>/dev/null; then PKG="dnf";
    elif command -v zypper &>/dev/null; then PKG="zypper";
    elif command -v apk &>/dev/null; then PKG="apk";
    elif command -v xbps-install &>/dev/null; then PKG="xbps";
    else PKG="unknown"; fi
}
detect_pkg_manager

# Ensure zsh, kitty, git, curl are installed
install_dependencies() {
    echo -e "${CYAN}[*] Checking required dependencies (zsh, kitty, git, curl, fonts)...${NC}"
    case "$PKG" in
        apt)
            $SUDO apt-get update -y
            $SUDO apt-get install -y zsh kitty git curl fonts-firacode fonts-hack-ttf
            ;;
        pacman)
            $SUDO pacman -Sy --noconfirm zsh kitty git curl ttf-fira-code ttf-hack
            ;;
        dnf)
            $SUDO dnf install -y zsh kitty git curl fira-code-fonts
            ;;
        zypper)
            $SUDO zypper --non-interactive install zsh kitty git curl fira-code-fonts
            ;;
        apk)
            $SUDO apk add zsh kitty git curl font-fira-code
            ;;
        xbps)
            $SUDO xbps-install -Sy zsh kitty git curl font-fira-code
            ;;
        *)
            echo -e "${YELLOW}[!] Unknown package manager. Please ensure zsh, kitty, git, curl are installed.${NC}"
            ;;
    esac
}

install_dependencies

# Set default shell to zsh if not already
if [ "$(basename "$SHELL")" != "zsh" ]; then
    echo -e "${CYAN}[*] Setting default shell to zsh...${NC}"
    chsh -s "$(command -v zsh)" "$USER" || echo -e "${YELLOW}[!] Please run: chsh -s $(which zsh)${NC}"
fi

# Setup Oh My Zsh
OMZ_DIR="$HOME/.oh-my-zsh"
if [ ! -d "$OMZ_DIR" ]; then
    echo -e "${CYAN}[*] Installing Oh My Zsh...${NC}"
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
fi

# Setup Oh My Zsh plugins (Autosuggestions & Syntax Highlighting)
PLUGINS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
mkdir -p "$PLUGINS_DIR"
if [ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
    echo -e "${CYAN}[*] Installing zsh-autosuggestions...${NC}"
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"
fi
if [ ! -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]; then
    echo -e "${CYAN}[*] Installing zsh-syntax-highlighting...${NC}"
    git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGINS_DIR/zsh-syntax-highlighting"
fi

# Install custom OMZ themes from this folder
THEMES_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes"
mkdir -p "$THEMES_CUSTOM_DIR"
cp "$SCRIPT_DIR/zsh/themes/"*.zsh-theme "$THEMES_CUSTOM_DIR/"

# Deploy Kitty Config & Themes
echo -e "${CYAN}[*] Deploying Kitty terminal configuration & themes...${NC}"
mkdir -p "$HOME/.config/kitty/themes"
cp "$SCRIPT_DIR/kitty.conf" "$HOME/.config/kitty/kitty.conf"
cp -r "$SCRIPT_DIR/themes/"* "$HOME/.config/kitty/themes/"

# Deploy kitty-theme switcher script
mkdir -p "$HOME/.local/bin"
cp "$SCRIPT_DIR/scripts/kitty-theme" "$HOME/.local/bin/kitty-theme"
chmod +x "$HOME/.local/bin/kitty-theme"

# Deploy .zshrc
echo -e "${CYAN}[*] Deploying ~/.zshrc...${NC}"
if [ -f "$HOME/.zshrc" ] && [ ! -f "$HOME/.zshrc.pre-hacker.bak" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.pre-hacker.bak"
fi
cp "$SCRIPT_DIR/zsh/.zshrc" "$HOME/.zshrc"

echo -e "\n${GREEN}${BOLD}✔ Successfully imported Kitty and Zsh Hacker Configuration!${NC}"
echo -e "Run ${YELLOW}kitty-theme${NC} to switch themes anytime."
