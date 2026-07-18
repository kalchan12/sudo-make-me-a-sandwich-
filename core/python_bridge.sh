# Python Bridge — replaces bash UI functions with Python+rich equivalents
# Sourced by setup.sh when python3 + rich are available

PYTHON_ENGINE="$(dirname "$(dirname "$0")")/src/main.py"

show_persona() {
    python3 "$PYTHON_ENGINE" persona
}

# gecho for backward-compat with remaining bash code
gecho() { echo -e "${GREEN}$*${NC}"; }
