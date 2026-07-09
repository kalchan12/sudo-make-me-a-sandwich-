SHELLS_LIST=(
    "Zsh|install_zsh|zsh"
    "Fish|install_fish|fish"
    "Dash|install_dash|dash"
    "Ksh|install_ksh|ksh"
    "Tcsh|install_tcsh|tcsh"
    "Nushell|install_nushell|nushell"
    "Elvish|install_elvish|elvish"
    "Xonsh|install_xonsh|xonsh"
)

show_shells_menu() {
    while true; do
        echo -e "\n${PURPLE}── Shells ──${NC}"

        local i=1
        for info in "${SHELLS_LIST[@]}"; do
            local name="${info%%|*}"
            echo -e "${YELLOW}$i)${GREEN} Install $name${NC}"
            ((i++))
        done

        local all_idx=$i
        echo -e "${YELLOW}$all_idx)${GREEN} Install All${NC}"

        local check_idx=$((i+1))
        echo -e "${YELLOW}$check_idx)${GREEN} Check Installations${NC}"

        local back_idx=$((i+2))
        echo -e "${YELLOW}$back_idx)${GREEN} Back${NC}"
        echo -e "${PURPLE}Enter a number to install, or e<N> for details (e.g., e1)${NC}"

        echo -n -e "${PURPLE}Select option: ${NC}${YELLOW}"
        read -r s_choice
        echo -e -n "${NC}"

        if [[ "$s_choice" =~ ^e([0-9]+)$ ]]; then
            _explain_by_index SHELLS_LIST "${BASH_REMATCH[1]}"
            continue
        elif [[ "$s_choice" -eq "$all_idx" ]]; then
            install_shells
        elif [[ "$s_choice" -eq "$check_idx" ]]; then
            check_shells_installations
        elif [[ "$s_choice" -eq "$back_idx" ]]; then
            show_main_menu; return
        elif [[ "$s_choice" -ge 1 && "$s_choice" -lt "$all_idx" ]]; then
            local selected_info="${SHELLS_LIST[$((s_choice-1))]}"
            local func_name="${selected_info##*|}"
            $func_name
        else
            log_message "WARN" "Invalid option"
        fi
    done
}

install_zsh() {
    install_with_fallback "Zsh" "zsh" "zsh" "" "zsh"
}

install_fish() {
    install_with_fallback "Fish" "fish" "fish" "" "fish"
}

install_dash() {
    install_with_fallback "Dash" "dash" "dash" "" "dash"
}

install_ksh() {
    install_with_fallback "Ksh" "ksh" "ksh" "" "ksh"
}

install_tcsh() {
    install_with_fallback "Tcsh" "tcsh" "tcsh" "" "tcsh"
}

install_nushell() {
    install_with_fallback "Nushell" "nushell" "nushell-bin" "" "nu"
}

install_elvish() {
    install_with_fallback "Elvish" "elvish" "elvish" "" "elvish"
}

install_xonsh() {
    install_with_fallback "Xonsh" "xonsh" "xonsh" "" "xonsh"
}

install_shells() { _install_list "Shells" SHELLS_LIST; }

check_shells_installations() {
    log_message "INFO" "--- Checking Shell Installations ---"
    for info in "${SHELLS_LIST[@]}"; do
        local name="${info%%|*}"
        local installed=false
        case $name in
            Zsh) command -v zsh &> /dev/null && installed=true ;;
            Fish) command -v fish &> /dev/null && installed=true ;;
            Dash) command -v dash &> /dev/null && installed=true ;;
            Ksh) command -v ksh &> /dev/null && installed=true ;;
            Tcsh) command -v tcsh &> /dev/null && installed=true ;;
            Nushell) command -v nu &> /dev/null && installed=true ;;
            Elvish) command -v elvish &> /dev/null && installed=true ;;
            Xonsh) command -v xonsh &> /dev/null && installed=true ;;
        esac
        if [ "$installed" = true ]; then
            echo -e "${GREEN}[✔] $name is installed.${NC}"
        else
            echo -e "${RED}[✘] $name is NOT installed.${NC}"
        fi
    done
}
