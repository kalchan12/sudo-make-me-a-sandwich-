# ==============================================================================
# Theme: Kali Hacker (Oh My Zsh Custom Theme)
# Author: Antigravity Hacker Edition
# Description: Preserves and supercharges Kali Linux's iconic two-line prompt
#              with git status integration, return codes, and cyberpunk accents.
#              Portable across Kali, Debian, Ubuntu, Arch, Fedora, etc.
# ==============================================================================

# Git prompt settings
ZSH_THEME_GIT_PROMPT_PREFIX="%F{yellow}(%F{magenta} "
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{yellow})%f"
ZSH_THEME_GIT_PROMPT_DIRTY="%F{red}*%f"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{green}✔%f"

# Prompt symbol: Kali dragon symbol for normal user, Skull for root
prompt_symbol="㉿"
if [ "$EUID" -eq 0 ]; then
    prompt_symbol="💀"
fi

# Exit code indicator
return_code="%(?..%F{red}⨯ %?%f )"

# Construction of iconic two-line Kali hacker prompt
PROMPT=$'%F{%(#.red.cyan)}┌──${debian_chroot:+($debian_chroot)─}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))─}(%B%F{%(#.red.blue)}%n'$prompt_symbol$'%m%b%F{%(#.red.cyan)})-[%B%F{%(#.yellow.white)}%~%b%F{%(#.red.cyan)}] $(git_prompt_info)\n└─%B%(#.%F{red}#.%F{cyan}$)%b%F{reset} '

RPROMPT='${return_code}'
