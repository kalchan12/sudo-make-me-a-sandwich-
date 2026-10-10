#!/usr/bin/env bash
# ==============================================================================
# HACKER TERMINAL INSTALLER (KITTY + ZSH + OH-MY-ZSH + MODULAR THEMES)
# ==============================================================================
# Portable cross-distro installer for:
#   - Kitty Terminal (with modular hacker themes: cyberpunk, matrix, etc.)
#   - Zsh (installs automatically on distros where it isn't default)
#   - Oh My Zsh
#   - Command Prediction / History Autosuggestions (zsh-autosuggestions)
#   - Real-time Hacker Syntax Highlighting (zsh-syntax-highlighting)
#   - Iconic Kali Hacker Prompt (works on Kali, Ubuntu, Fedora, Arch, etc.)
#   - Live theme switcher CLI ('kitty-theme')
#
# Supported Distros:
#   Debian, Ubuntu, Kali, Mint, Parrot, Arch Linux, Manjaro, Fedora, openSUSE, Alpine, Void
# ==============================================================================

set -e

# Styling
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

log_info() {
    echo -e "${CYAN}[*]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✔]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✘]${NC} $1"
}

echo -e "${CYAN}${BOLD}"
cat << "EOF"
  ███████╗██╗   ██╗██████╗  ██████╗     ███╗   ███╗ ██████╗ ██████╗ 
  ██╔════╝██║   ██║██╔══██╗██╔═══██╗    ████╗ ████║██╔═══██╗██╔══██╗
  ███████╗██║   ██║██║  ██║██║   ██║    ██╔████╔██║██║   ██║██║  ██║
  ╚════██║██║   ██║██║  ██║██║   ██║    ██║╚██╔╝██║██║   ██║██║  ██║
  ███████║╚██████╔╝██████╔╝╚██████╔╝    ██║ ╚═╝ ██║╚██████╔╝██████╔╝
  ╚══════╝ ╚═════╝ ╚═════╝  ╚═════╝     ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ 
        HACKER TERMINAL & MODULAR ENVIRONMENT BOOTSTRAPPER
EOF
echo -e "${NC}"

# Detect sudo privileges
SUDO=""
if [ "$EUID" -ne 0 ]; then
    if command -v sudo &>/dev/null; then
        SUDO="sudo"
    else
        log_warn "Running as non-root without sudo. Package installation might require root."
    fi
fi

# Detect Package Manager & Distro
detect_pkg_manager() {
    if command -v apt-get &>/dev/null; then
        PKG_MNGR="apt"
    elif command -v pacman &>/dev/null; then
        PKG_MNGR="pacman"
    elif command -v dnf &>/dev/null; then
        PKG_MNGR="dnf"
    elif command -v zypper &>/dev/null; then
        PKG_MNGR="zypper"
    elif command -v apk &>/dev/null; then
        PKG_MNGR="apk"
    elif command -v xbps-install &>/dev/null; then
        PKG_MNGR="xbps"
    else
        PKG_MNGR="unknown"
    fi
}

detect_pkg_manager
log_info "Detected Package Manager: ${BOLD}$PKG_MNGR${NC}"

# 1. Install prerequisites (Zsh, Kitty, Git, Curl, Fonts)
install_packages() {
    log_info "Checking and installing required packages (zsh, kitty, git, curl, fonts)..."

    case "$PKG_MNGR" in
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
            log_warn "Unknown package manager. Please ensure zsh, kitty, git, and curl are installed manually."
            ;;
    esac
    log_success "Packages verified."
}

install_packages

# 2. Set default shell to ZSH if needed
setup_default_shell() {
    CURRENT_SHELL=$(basename "$SHELL")
    ZSH_PATH=$(command -v zsh || echo "/bin/zsh")

    if [ "$CURRENT_SHELL" != "zsh" ]; then
        log_info "Changing default shell to zsh ($ZSH_PATH)..."
        if command -v chsh &>/dev/null; then
            chsh -s "$ZSH_PATH" "$USER" || log_warn "Could not change default shell automatically. Run: chsh -s $(which zsh)"
        fi
    else
        log_success "Zsh is already your default shell."
    fi
}

setup_default_shell

# 3. Install Oh My Zsh
setup_oh_my_zsh() {
    OMZ_DIR="$HOME/.oh-my-zsh"
    if [ ! -d "$OMZ_DIR" ]; then
        log_info "Installing Oh My Zsh (non-interactive)..."
        git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR"
        log_success "Oh My Zsh installed."
    else
        log_success "Oh My Zsh already exists at $OMZ_DIR"
    fi
}

setup_oh_my_zsh

# 4. Install Plugins (Autosuggestions & Syntax Highlighting)
setup_zsh_plugins() {
    PLUGINS_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
    mkdir -p "$PLUGINS_DIR"

    # Autosuggestions (command prediction based on previous history)
    if [ ! -d "$PLUGINS_DIR/zsh-autosuggestions" ]; then
        log_info "Installing zsh-autosuggestions..."
        git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$PLUGINS_DIR/zsh-autosuggestions"
    else
        log_success "zsh-autosuggestions already installed."
    fi

    # Syntax Highlighting
    if [ ! -d "$PLUGINS_DIR/zsh-syntax-highlighting" ]; then
        log_info "Installing zsh-syntax-highlighting..."
        git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$PLUGINS_DIR/zsh-syntax-highlighting"
    else
        log_success "zsh-syntax-highlighting already installed."
    fi
}

setup_zsh_plugins

# 5. Deploy Custom Oh My Zsh Hacker Themes
setup_omz_themes() {
    THEMES_CUSTOM_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes"
    mkdir -p "$THEMES_CUSTOM_DIR"

    log_info "Deploying custom hacker OMZ themes (kali-hacker & cyberpunk)..."

    cat << 'EOF' > "$THEMES_CUSTOM_DIR/kali-hacker.zsh-theme"
# Theme: Kali Hacker (Oh My Zsh Custom Theme)
ZSH_THEME_GIT_PROMPT_PREFIX="%F{yellow}(%F{magenta} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{yellow})%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{red}*%f"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{green}✔%f"

prompt_symbol="㉿"
[ "$EUID" -eq 0 ] && prompt_symbol="💀"

return_code="%(?..%F{red}⨯ %?%f )"
PROMPT=$'%F{%(#.red.cyan)}┌──${debian_chroot:+($debian_chroot)─}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))─}(%B%F{%(#.red.blue)}%n'$prompt_symbol$'%m%b%F{%(#.red.cyan)})-[%B%F{%(#.yellow.white)}%~%b%F{%(#.red.cyan)}] $(git_prompt_info)\n└─%B%(#.%F{red}#.%F{cyan}$)%b%F{reset} '
RPROMPT='${return_code}'
EOF

    cat << 'EOF' > "$THEMES_CUSTOM_DIR/cyberpunk.zsh-theme"
# Theme: Cyberpunk Neon Prompt
ZSH_THEME_GIT_PROMPT_PREFIX="%F{magenta}[%F{cyan}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{magenta}]%f "
ZSH_THEME_GIT_PROMPT_DIRTY="%F{red}⚡%f"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{green}●%f"

PROMPT=$'%F{cyan}┌[%F{green}%n%F{magenta}@%F{cyan}%m%F{cyan}]-%F{magenta}[%F{yellow}%~%F{magenta}] $(git_prompt_info)\n%F{cyan}└─%F{magenta}❯%F{green}❯%F{cyan}❯%f '
RPROMPT='%(?..%F{red}✘ %?%f)'
EOF

    log_success "Custom themes deployed."
}

setup_omz_themes

# 6. Deploy Modular Kitty Configuration & Themes
setup_kitty_modular() {
    log_info "Deploying modular Kitty configuration..."
    KITTY_DIR="$HOME/.config/kitty"
    KITTY_THEMES_DIR="$KITTY_DIR/themes"
    mkdir -p "$KITTY_THEMES_DIR"

    # Cyberpunk Neon
    cat << 'EOF' > "$KITTY_THEMES_DIR/cyberpunk-neon.conf"
foreground            #e2f1f8
background            #0a0b10
selection_foreground  #00f0ff
selection_background  #241b45
cursor                #00ff9f
cursor_text_color     #05070d
url_color             #ff007f
active_border_color   #00f0ff
inactive_border_color #1a1e30
bell_border_color     #ff0055
active_tab_foreground   #05070d
active_tab_background   #00f0ff
inactive_tab_foreground #7982a9
inactive_tab_background #141724
tab_bar_background      #0a0b10
color0 #141724
color8 #454b68
color1 #ff0055
color9 #ff3377
color2  #00ff9f
color10 #33ffb3
color3  #ffe600
color11 #ffea4d
color4  #00b4d8
color12 #38bdf8
color5  #bd00ff
color13 #ff007f
color6  #00f0ff
color14 #70e000
color7  #d1d5db
color15 #ffffff
EOF

    # Matrix Green
    cat << 'EOF' > "$KITTY_THEMES_DIR/matrix-green.conf"
foreground            #00ff66
background            #050805
selection_foreground  #050805
selection_background  #00ff66
cursor                #20c20e
cursor_text_color     #050805
url_color             #52ff94
active_border_color   #00ff66
inactive_border_color #0d2611
bell_border_color     #ff3860
active_tab_foreground   #050805
active_tab_background   #00ff66
inactive_tab_foreground #2e7d32
inactive_tab_background #0a170c
tab_bar_background      #050805
color0 #0a170c
color8 #1c4423
color1 #ff3860
color9 #ff6b8b
color2  #00ff66
color10 #52ff94
color3  #a6e22e
color11 #c6ff00
color4  #00c9a7
color12 #48e5c2
color5  #00b894
color13 #55efc4
color6  #00ffcc
color14 #80ffdb
color7  #bbf7d0
color15 #f0fff4
EOF

    # Cyber Blood
    cat << 'EOF' > "$KITTY_THEMES_DIR/cyber-blood.conf"
foreground            #f1f5f9
background            #0a0608
selection_foreground  #ffffff
selection_background  #591321
cursor                #ff1e42
cursor_text_color     #0a0608
url_color             #ff0055
active_border_color   #ff1e42
inactive_border_color #2b1218
bell_border_color     #ff0033
active_tab_foreground   #ffffff
active_tab_background   #ff1e42
inactive_tab_foreground #8a5763
inactive_tab_background #1a0b10
tab_bar_background      #0a0608
color0 #140d10
color8 #40232b
color1 #ff1e42
color9 #ff4d6d
color2  #00f59b
color10 #57fbc1
color3  #ff9e00
color11 #ffb703
color4  #0077b6
color12 #0096c7
color5  #b5179e
color13 #f72585
color6  #06d6a0
color14 #48cae4
color7  #e2e8f0
color15 #ffffff
EOF

    # Synthwave Retro
    cat << 'EOF' > "$KITTY_THEMES_DIR/synthwave-retro.conf"
foreground            #f8f8f2
background            #141124
selection_foreground  #ffffff
selection_background  #442a68
cursor                #ff79c6
cursor_text_color     #141124
url_color             #00f0ff
active_border_color   #bd93f9
inactive_border_color #282142
bell_border_color     #ff5555
active_tab_foreground   #141124
active_tab_background   #ff79c6
inactive_tab_foreground #786e9e
inactive_tab_background #1c1833
tab_bar_background      #141124
color0 #1f1a3a
color8 #4d4475
color1 #ff5555
color9 #ff6e6e
color2  #50fa7b
color10 #69ff94
color3  #f1fa8c
color11 #ffffa5
color4  #bd93f9
color12 #d6acff
color5  #ff79c6
color13 #ff92df
color6  #8be9fd
color14 #a4ffff
color7  #f8f8f2
color15 #ffffff
EOF

    # Link active theme default to cyberpunk-neon if not set
    if [ ! -f "$KITTY_THEMES_DIR/active-theme.conf" ]; then
        ln -sfn cyberpunk-neon.conf "$KITTY_THEMES_DIR/active-theme.conf"
    fi

    # Main modular kitty.conf
    cat << 'EOF' > "$KITTY_DIR/kitty.conf"
# --- MODULAR THEME IMPORT ---
include themes/active-theme.conf

# --- FONTS ---
font_family      Fira Code
bold_font        auto
italic_font      auto
bold_italic_font auto
font_size        11.5
disable_ligatures never

# --- CURSOR ---
cursor_shape          beam
cursor_beam_thickness 1.8
cursor_blink_interval 0.5
cursor_stop_blinking_after 15.0

# --- WINDOW & PADDING ---
window_padding_width  10 14
placement_strategy    center
hide_window_decorations no
remember_window_size  yes
initial_window_width  1000
initial_window_height 650

# --- BACKGROUND OPACITY & BLUR ---
background_opacity         0.93
background_blur            1
dynamic_background_opacity yes

# --- SCROLLBACK & PERFORMANCE ---
scrollback_lines 10000
wheel_scroll_multiplier 3.0
repaint_delay    10
input_delay      3
sync_to_monitor  yes

# --- BELL ---
enable_audio_bell no
visual_bell_duration 0.0
window_alert_on_bell yes
bell_on_tab "🔔 "

# --- MOUSE & URLS ---
mouse_hide_wait 3.0
detect_urls yes
url_style curly
open_url_with default
copy_on_select yes
strip_trailing_spaces smart

# --- TAB BAR ---
tab_bar_edge top
tab_bar_style powerline
tab_powerline_style slanted
tab_title_template "{index}: {title}"
active_tab_font_style bold

# --- SHELL INTEGRATION ---
shell /bin/zsh
close_on_child_death no
allow_remote_control yes

# --- KEYBINDINGS ---
map ctrl+shift+f5 load_config_file
map ctrl+shift+f6 debug_config
map ctrl+equal change_font_size all +1.0
map ctrl+plus change_font_size all +1.0
map ctrl+minus change_font_size all -1.0
map ctrl+0 change_font_size all 0
map ctrl+shift+a>m set_background_opacity +0.05
map ctrl+shift+a>l set_background_opacity -0.05
map ctrl+shift+a>1 set_background_opacity 1
map ctrl+shift+a>d set_background_opacity default
map ctrl+shift+c copy_to_clipboard
map ctrl+shift+v paste_from_clipboard
map ctrl+shift+t new_tab
map ctrl+shift+q close_tab
map ctrl+shift+right next_tab
map ctrl+shift+left previous_tab
EOF

    # Install kitty-theme switcher script
    mkdir -p "$HOME/.local/bin"
    cat << 'EOF' > "$HOME/.local/bin/kitty-theme"
#!/usr/bin/env bash
THEMES_DIR="$HOME/.config/kitty/themes"
ACTIVE_CONF="$THEMES_DIR/active-theme.conf"
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

list_themes() {
    echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}${BOLD}║           KITTY HACKER THEME SELECTOR         ║${NC}"
    echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════╝${NC}"
    echo -e "${BOLD}Available Themes:${NC}\n"
    CURRENT_TARGET=""
    [ -L "$ACTIVE_CONF" ] && CURRENT_TARGET=$(readlink "$ACTIVE_CONF")
    for file in "$THEMES_DIR"/*.conf; do
        theme_file=$(basename "$file")
        [ "$theme_file" = "active-theme.conf" ] && continue
        theme_name="${theme_file%.conf}"
        if [ "$theme_file" = "$CURRENT_TARGET" ]; then
            echo -e "  ${GREEN}● ${BOLD}$theme_name${NC} ${GREEN}[ACTIVE]${NC}"
        else
            echo -e "    $theme_name"
        fi
    done
    echo ""
    echo -e "Usage: ${YELLOW}kitty-theme <name>${NC}  (e.g., kitty-theme matrix-green)"
}

reload_kitty() {
    if pgrep -x kitty > /dev/null 2>&1; then
        killall -SIGUSR1 kitty 2>/dev/null || pkill -USR1 kitty 2>/dev/null
        echo -e "${GREEN}✔ Live reloaded all running Kitty terminal instances!${NC}"
    else
        echo -e "${YELLOW}ℹ Kitty is not currently running. Changes will apply on next launch.${NC}"
    fi
}

set_theme() {
    target_input="$1"
    matched_file=""
    if [ -f "$THEMES_DIR/$target_input.conf" ]; then
        matched_file="$target_input.conf"
    elif [ -f "$THEMES_DIR/$target_input" ]; then
        matched_file="$target_input"
    else
        for f in "$THEMES_DIR"/*.conf; do
            tname=$(basename "$f" .conf)
            [ "$tname" = "active-theme" ] && continue
            if [[ "$tname" == *"$target_input"* ]]; then
                matched_file=$(basename "$f")
                break
            fi
        done
    fi

    if [ -z "$matched_file" ] || [ ! -f "$THEMES_DIR/$matched_file" ]; then
        echo -e "${RED}✘ Theme '$target_input' not found!${NC}"
        echo -e "Run ${YELLOW}kitty-theme${NC} to see available themes."
        exit 1
    fi

    ln -sfn "$matched_file" "$ACTIVE_CONF"
    theme_clean_name="${matched_file%.conf}"
    echo -e "${GREEN}✔ Activated theme:${NC} ${BOLD}$theme_clean_name${NC}"
    reload_kitty
}

if [ -z "$1" ] || [ "$1" = "list" ] || [ "$1" = "-l" ] || [ "$1" = "--list" ]; then
    list_themes
else
    set_theme "$1"
fi
EOF
    chmod +x "$HOME/.local/bin/kitty-theme"
    log_success "Modular Kitty themes and 'kitty-theme' switcher installed."
}

setup_kitty_modular

# 7. Configure ~/.zshrc
setup_zshrc() {
    log_info "Configuring ~/.zshrc with autosuggestions and hacker syntax highlighting..."
    ZSHRC="$HOME/.zshrc"

    if [ -f "$ZSHRC" ] && [ ! -f "$ZSHRC.pre-hacker.bak" ]; then
        cp "$ZSHRC" "$ZSHRC.pre-hacker.bak"
        log_info "Backed up existing ~/.zshrc to ~/.zshrc.pre-hacker.bak"
    fi

    cat << 'EOF' > "$ZSHRC"
# ~/.zshrc - HACKER EDITION (KALI + OH-MY-ZSH + MODULAR THEMES)
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="kali-hacker"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# Prediction & Autosuggestions (from previous commands)
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50
bindkey '^ ' autosuggest-accept
bindkey '^F' autosuggest-accept
bindkey '^[f' forward-word
bindkey '^[[1;5C' forward-word

# Syntax Highlighting
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=yellow,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan,underline'
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[arg0]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=cyan'
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]='standout'

# History
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_SAVE_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Options & Color
setopt autocd
setopt interactivecomments
setopt magicequalsubst
setopt promptsubst
WORDCHARS='_-'

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:"
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

# Aliases
alias kitty-theme="~/.local/bin/kitty-theme"
alias kt="~/.local/bin/kitty-theme"
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -c'
alias c='clear'
alias reload="source ~/.zshrc && echo '✔ ~/.zshrc reloaded'"
alias myip="curl -s -m 3 https://ifconfig.me || curl -s -m 3 https://icanhazip.com"
alias ports="ss -tulpn 2>/dev/null || netstat -tulanp 2>/dev/null"

if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi
EOF
    log_success "~/.zshrc updated."
}

setup_zshrc

echo -e "\n${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}    HACKER TERMINAL SUITE INSTALLED SUCCESSFULLY! 🚀           ${NC}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${NC}"
echo -e "  • ${CYAN}Kitty Themes:${NC} Run ${YELLOW}kitty-theme${NC} to switch between themes:"
echo -e "      - ${GREEN}cyberpunk-neon${NC} (Active default)"
echo -e "      - ${GREEN}matrix-green${NC}   (Phosphor green)"
echo -e "      - ${GREEN}cyber-blood${NC}    (Offensive red team)"
echo -e "      - ${GREEN}synthwave-retro${NC}(80s outrun neon)"
echo -e "  • ${CYAN}Command Prediction:${NC} Autosuggestions based on previous commands enabled!"
echo -e "      - Press ${YELLOW}Right-Arrow${NC} or ${YELLOW}Ctrl+Space${NC} to accept ghost prediction"
echo -e "      - Press ${YELLOW}Alt+F${NC} or ${YELLOW}Ctrl+Right${NC} to accept word-by-word"
echo -e "  • ${CYAN}Syntax Highlighting:${NC} Commands highlight in real-time"
echo -e "  • ${CYAN}Prompt:${NC} Kali two-line prompt preserved with Git & exit status"
echo -e "  • ${CYAN}Hot Reload Kitty:${NC} Press ${YELLOW}Ctrl+Shift+F5${NC} in Kitty anytime"
echo ""
