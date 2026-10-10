# ==============================================================================
# Theme: Cyberpunk Neon Prompt (Oh My Zsh Custom Theme)
# ==============================================================================

ZSH_THEME_GIT_PROMPT_PREFIX="%F{magenta}[%F{cyan}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%F{magenta}]%f "
ZSH_THEME_GIT_PROMPT_DIRTY="%F{red}⚡%f"
ZSH_THEME_GIT_PROMPT_CLEAN="%F{green}●%f"

PROMPT=$'%F{cyan}┌[%F{green}%n%F{magenta}@%F{cyan}%m%F{cyan}]-%F{magenta}[%F{yellow}%~%F{magenta}] $(git_prompt_info)\n%F{cyan}└─%F{magenta}❯%F{green}❯%F{cyan}❯%f '
RPROMPT='%(?..%F{red}✘ %?%f)'
