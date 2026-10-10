# ==============================================================================
# ~/.zshrc - HACKER EDITION (KALI + OH-MY-ZSH + MODULAR THEMES)
# ==============================================================================

# --- PATH & ENVIRONMENT ---
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# --- THEME SELECTION ---
# Available custom themes in ~/.oh-my-zsh/custom/themes/:
#   "kali-hacker" (Iconic Kali two-line prompt + git + exit codes - default)
#   "cyberpunk"   (Neon cyberpunk prompt)
#   "robbyrussell", "agnoster", etc.
ZSH_THEME="kali-hacker"

# --- OH MY ZSH PLUGINS ---
# zsh-autosuggestions: predicts & suggests commands from history
# zsh-syntax-highlighting: real-time hacker syntax highlighting
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Source Oh My Zsh
source "$ZSH/oh-my-zsh.sh"

# ==============================================================================
# COMMAND PREDICTION & AUTOSUGGESTIONS (HISTORY-BASED)
# ==============================================================================
# Predicts command based on previous history as you type
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Subtle hacker gray/dim highlight for ghost suggestion text
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=244'

# Buffer size to prevent lag on giant history
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=50

# Bindings to accept suggestions:
# 1. Right-Arrow: accepts full suggestion
# 2. Ctrl+Space or Ctrl+F: accepts full suggestion
# 3. Alt+F or Ctrl+Right: accepts word by word (partial prediction)
bindkey '^ ' autosuggest-accept
bindkey '^F' autosuggest-accept
bindkey '^[f' forward-word
bindkey '^[[1;5C' forward-word

# ==============================================================================
# REAL-TIME SYNTAX HIGHLIGHTING (HACKER PALETTE)
# ==============================================================================
# Vibrant neon cyberpunk / hacker high-contrast syntax highlighting
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

# ==============================================================================
# HISTORY CONFIGURATION (FOR PREDICTION ACCURACY)
# ==============================================================================
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt EXTENDED_HISTORY       # Write timestamp to history file
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate event first when trimming history
setopt HIST_IGNORE_DUPS       # Don't record an event that was just recorded
setopt HIST_IGNORE_ALL_DUPS   # Delete old duplicate entry if new one is typed
setopt HIST_FIND_NO_DUPS      # Do not display duplicates when searching
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt HIST_SAVE_NO_DUPS      # Don't write duplicates to history file
setopt HIST_REDUCE_BLANKS     # Remove unnecessary blanks from history
setopt INC_APPEND_HISTORY     # Add immediately to history file
setopt SHARE_HISTORY          # Share history across all active terminals

# ==============================================================================
# COMPLETION & INTERACTIVE SETTINGS
# ==============================================================================
setopt autocd                 # cd into directory by typing name
setopt interactivecomments    # allow comments starting with # in shell
setopt magicequalsubst        # enable filename expansion for arguments
setopt promptsubst            # enable command substitution in prompt
WORDCHARS='_-'                # word boundaries

# Enable color support for ls and commands
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:"
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

# ==============================================================================
# ALIASES & UTILITIES
# ==============================================================================
# Terminal theme switcher
alias kitty-theme="~/.local/bin/kitty-theme"
alias kt="~/.local/bin/kitty-theme"

# Navigation & Directory listing
alias ls='ls --color=auto'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias l='ls -CF --color=auto'

# Utilities & Networking
alias grep='grep --color=auto'
alias diff='diff --color=auto'
alias ip='ip -c'
alias c='clear'
alias reload="source ~/.zshrc && echo '✔ ~/.zshrc reloaded'"

# Quick hacker tools
alias myip="curl -s -m 3 https://ifconfig.me || curl -s -m 3 https://icanhazip.com"
alias ports="ss -tulpn 2>/dev/null || netstat -tulanp 2>/dev/null"
alias meminfo="free -h"
alias cpuinfo="lscpu | grep -E 'Model name|CPU\(s\):|MHz'"

# Kali command-not-found integration (if present)
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi
