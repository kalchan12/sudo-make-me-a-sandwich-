SELECTION_MODE=false

_get_item_size() {
    local pkg="$1"
    [ -z "$pkg" ] && { echo "?"; return; }
    case $DISTRO in
        debian)
            local size
            size=$(apt-cache show "$pkg" 2>/dev/null | grep "^Size:" | awk '{print $2}')
            if [ -n "$size" ]; then
                show_size "$size"
            else
                echo "?"
            fi
            ;;
        arch)
            local size
            size=$(pacman -Si "$pkg" 2>/dev/null | grep "^Download Size" | awk -F': ' '{print $2}')
            echo "${size:-?}"
            ;;
    esac
}

_parse_item() {
    local item="$1"
    _ITEM_NAME="${item%%|*}"
    local rest="${item#*|}"
    _ITEM_CALL="${rest%%|*}"
    _ITEM_PKG="${rest#*|}"
}

_show_selection_menu() {
    local mode="$1"
    local -n _items_ref="$2"
    local -a all_items=()
    local -a available=()
    local has_unknown=false

    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"
    echo -e "${YELLOW}      Select Items to Install${NC}"
    echo ""

    if [ "$mode" = "full" ] || [ "$mode" = "minimal" ]; then
        echo -e "  ${CYAN}── Browsers ──${NC}"
        for info in "${BROWSERS_LIST[@]}"; do
            local name="${info%%|*}"
            local func="${info##*|}"
            local pkg=""
            case $func in
                install_brave) pkg="brave-browser" ;;
                install_chrome) pkg="" ;;
                install_firefox) pkg="firefox" ;;
                install_vivaldi) pkg="vivaldi-stable" ;;
                install_chromium) pkg="chromium" ;;
                install_firefox_dev) pkg="" ;;
                install_ungoogled_chromium) pkg="ungoogled-chromium" ;;
                install_librewolf) pkg="librewolf" ;;
            esac
            all_items+=("$name|$func|$pkg")
        done
        echo -e "  ${CYAN}── Terminals ──${NC}"
        for info in "${TERMINALS_LIST[@]}"; do
            all_items+=("$info")
        done
    fi

    if [ "$mode" = "full" ]; then
        echo -e "  ${CYAN}── Utilities ──${NC}"
        for info in "${UTILITIES_LIST[@]}"; do
            all_items+=("$info")
        done
        echo -e "  ${CYAN}── IDEs ──${NC}"
        for info in "${IDES_LIST[@]}"; do
            all_items+=("$info")
        done
        echo -e "  ${CYAN}── Agentic IDEs ──${NC}"
        for info in "${AGENTIC_IDES_LIST[@]}"; do
            all_items+=("$info")
        done
    fi

    local total_bytes=0
    local display_num=0

    for info in "${all_items[@]}"; do
        _parse_item "$info"
        local name="$_ITEM_NAME"
        local call="$_ITEM_CALL"
        local pkg="$_ITEM_PKG"

        local already=false
        case $call in
            install_single_terminal*) pkg_is_installed "$pkg" &>/dev/null && already=true ;;
            install_brave) command -v brave-browser &>/dev/null && already=true ;;
            install_chrome) command -v google-chrome-stable &>/dev/null && already=true ;;
            install_firefox) command -v firefox &>/dev/null && already=true ;;
            install_vivaldi) command -v vivaldi-stable &>/dev/null && already=true ;;
            install_chromium) command -v chromium &>/dev/null || command -v chromium-browser &>/dev/null && already=true ;;
            install_firefox_dev) [ -f /opt/firefox-developer/firefox ] || command -v firefox-dev &>/dev/null && already=true ;;
            install_ungoogled_chromium) command -v ungoogled-chromium &>/dev/null && already=true ;;
            install_librewolf) command -v librewolf &>/dev/null && already=true ;;
            install_obsidian) command -v obsidian &>/dev/null && already=true ;;
            install_wps) command -v wps &>/dev/null && already=true ;;
            install_obs_studio) command -v obs &>/dev/null && already=true ;;
            install_ffmpeg) command -v ffmpeg &>/dev/null && already=true ;;
            install_yt_dlp) command -v yt-dlp &>/dev/null && already=true ;;
            install_vscode) command -v code &>/dev/null && already=true ;;
            install_sublime) command -v subl &>/dev/null && already=true ;;
            install_jetbrains_toolbox) [ -d /opt/jetbrains-toolbox ] || command -v jetbrains-toolbox &>/dev/null && already=true ;;
            install_opencode) command -v opencode &>/dev/null && already=true ;;
            install_zcode) command -v zcode &>/dev/null || [ -d /opt/zcode ] && already=true ;;
            install_antigravity) command -v antigravity &>/dev/null || [ -d /opt/antigravity ] && already=true ;;
            install_kiro) command -v kiro &>/dev/null || [ -d /opt/kiro ] && already=true ;;
        esac

        if [ "$already" = true ]; then
            echo -e "  ${GREEN}✓${NC} $name ${GREEN}(already installed)${NC}"
            continue
        fi

        available+=("$info")

        local size_str="$(_get_item_size "$pkg")"
        local num_val=0
        if [ "$size_str" != "?" ]; then
            num_val=$(echo "$size_str" | grep -oP '^[\d.]+')
            case "$size_str" in
                *GiB) total_bytes=$(awk "BEGIN { print $total_bytes + ($num_val * 1073741824) }") ;;
                *MiB) total_bytes=$(awk "BEGIN { print $total_bytes + ($num_val * 1048576) }") ;;
                *KiB) total_bytes=$(awk "BEGIN { print $total_bytes + ($num_val * 1024) }") ;;
            esac
        else
            has_unknown=true
        fi

        echo -e "  $((display_num + 1))) $name  ${CYAN}(${size_str})${NC}"
        ((display_num++))
    done

    if [ "$display_num" -eq 0 ]; then
        echo "  (all items already installed)"
        echo -e "${YELLOW}═══════════════════════════════════════${NC}"
        _items_ref=()
        return 1
    fi

    echo ""
    local total_size_str
    total_size_str=$(show_size "$total_bytes")
    if [ "$has_unknown" = true ]; then
        total_size_str="${total_size_str}+ (some sizes unknown)"
    fi
    echo -e "Total download size: ${CYAN}${total_size_str}${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════${NC}"

    if [ "$YES_MODE" = true ]; then
        _items_ref=("${available[@]}")
        return 0
    fi

    echo ""
    echo "Enter numbers to install (space-separated, ranges like 1-5, or 'all'): "
    echo -n "Selection: "
    read -r raw_input

    if [ "$raw_input" = "all" ]; then
        _items_ref=("${available[@]}")
        return 0
    fi

    local -a selections=()
    local chosen
    for token in $raw_input; do
        if [[ "$token" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            for ((n = ${BASH_REMATCH[1]}; n <= ${BASH_REMATCH[2]}; n++)); do
                chosen=$((n - 1))
                if [ "$chosen" -ge 0 ] && [ "$chosen" -lt "$display_num" ]; then
                    selections+=("${available[$chosen]}")
                fi
            done
        elif [[ "$token" =~ ^[0-9]+$ ]]; then
            chosen=$((token - 1))
            if [ "$chosen" -ge 0 ] && [ "$chosen" -lt "$display_num" ]; then
                selections+=("${available[$chosen]}")
            fi
        fi
    done

    _items_ref=("${selections[@]}")
    return 0
}

show_selection_and_install() {
    local mode="$1"
    local -a selected=()

    log_message "INFO" "Preparing installation selection..."
    ensure_prerequisites
    update_system

    _show_selection_menu "$mode" selected || {
        log_message "INFO" "Nothing to install."
        return
    }

    if [ ${#selected[@]} -eq 0 ]; then
        log_message "WARN" "No items selected."
        return
    fi

    log_message "INFO" "Installing ${#selected[@]} selected item(s)..."
    SELECTION_MODE=true

    for item in "${selected[@]}"; do
        _parse_item "$item"
        local call="$_ITEM_CALL"

        log_message "INFO" "Installing $_ITEM_NAME ..."
        if [[ "$call" == *" "* ]]; then
            $call
        else
            $call
        fi
    done

    SELECTION_MODE=false
    log_message "SUCCESS" "Installation tasks complete! Check $LOG_FILE for details."
}
