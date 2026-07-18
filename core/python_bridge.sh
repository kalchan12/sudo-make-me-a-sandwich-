# Python Bridge — replaces bash UI functions with Python+rich equivalents
# Sourced by setup.sh when python3 + rich are available

PYTHON_ENGINE="$(dirname "$(dirname "$0")")/src/main.py"

# Replace persona with rich version
show_persona() {
    python3 "$PYTHON_ENGINE" persona
}

# Replace main menu with rich version (Phase 2+)
# Uncomment when module migration begins:
# show_main_menu() {
#     local choice
#     choice=$(python3 "$PYTHON_ENGINE" menu main)
#     case $choice in
#         1) show_browsers_menu ;;
#         2) show_productivity_menu ;;
#         3) show_ides_menu ;;
#         4) show_terminals_menu ;;
#         5) show_shells_menu ;;
#         6) show_dev_tools_menu ;;
#         7) show_languages_menu ;;
#         8) show_pentest_menu ;;
#         9) show_frameworks_menu ;;
#         10) FULL_MODE=true; run_installation ;;
#         11) MINIMAL_MODE=true; run_installation ;;
#         12) exit 0 ;;
#     esac
# }

# gecho for backward-compat with remaining bash code
gecho() { echo -e "${GREEN}$*${NC}"; }
