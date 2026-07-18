# Python Bridge — replaces bash UI functions with Python+rich equivalents
# Sourced by setup.sh when python3 + rich are available

PYTHON_ENGINE="$(dirname "$(dirname "$0")")/src/main.py"

# Replace persona with rich version
show_persona() {
    python3 "$PYTHON_ENGINE" persona
}

# Replace main menu with rich interactive TUI
# show_splash=false because bash already showed banner + persona
show_main_menu() {
    python3 "$PYTHON_ENGINE" interactive
}

# Category menus all route to the Python interactive TUI
show_browsers_menu() { python3 "$PYTHON_ENGINE" interactive; }
show_productivity_menu() { python3 "$PYTHON_ENGINE" interactive; }
show_ides_menu() { python3 "$PYTHON_ENGINE" interactive; }
show_terminals_menu() { python3 "$PYTHON_ENGINE" interactive; }
show_shells_menu() { python3 "$PYTHON_ENGINE" interactive; }
show_dev_tools_menu() { python3 "$PYTHON_ENGINE" interactive; }
show_languages_menu() { python3 "$PYTHON_ENGINE" interactive; }
show_pentest_menu() { python3 "$PYTHON_ENGINE" interactive; }
show_frameworks_menu() { python3 "$PYTHON_ENGINE" interactive; }
show_agentic_ides_menu() { python3 "$PYTHON_ENGINE" interactive; }

# gecho for backward-compat with remaining bash code
gecho() { echo -e "${GREEN}$*${NC}"; }
