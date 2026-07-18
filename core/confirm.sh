show_size() {
    local raw="$1"
    if [[ "$raw" =~ ^[0-9]+(\.[0-9]+)?\ (MiB|KiB|GiB) ]]; then
        echo "$raw"
        return
    fi
    if [[ "$raw" =~ ^[0-9]+$ ]]; then
        if [ "$raw" -ge 1073741824 ]; then
            awk "BEGIN { printf \"%.1f GiB\n\", $raw/1073741824 }"
        elif [ "$raw" -ge 1048576 ]; then
            awk "BEGIN { printf \"%.1f MiB\n\", $raw/1048576 }"
        elif [ "$raw" -ge 1024 ]; then
            awk "BEGIN { printf \"%.1f KiB\n\", $raw/1024 }"
        else
            echo "${raw} B"
        fi
    else
        echo "Unknown"
    fi
}

confirm_install() {
    local display_name="$1"
    local pkg_name="${2:-}"
    local extra_info="${3:-}"

    echo ""
    echo -e "${GREEN}═══════════════════════════════════════${NC}"
    echo -e "${PURPLE} Package:${NC}       $display_name"

    if [ -n "$pkg_name" ]; then
        case $DISTRO in
            debian)
                while IFS= read -r line; do
                    case "$line" in
                        "Version: "*) echo -e "${GREEN} Version:${NC}       ${line#Version: }" ;;
                        "Description-en: "*) echo -e "${GREEN} Description:${NC}  $(echo "${line#Description-en: }" | head -c 100)" ;;
                        "Description: "*) echo -e "${GREEN} Description:${NC}  $(echo "${line#Description: }" | head -c 100)" ;;
                        "Size: "*) echo -e "${GREEN} Download size:${NC} $(show_size "${line#Size: }")" ;;
                        "Installed-Size: "*) echo -e "${GREEN} Install size:${NC}  $(show_size "$(( ${line#Installed-Size: } * 1024 ))")" ;;
                    esac
                done < <(apt-cache show "$pkg_name" 2>/dev/null)
                ;;
            arch)
                while IFS= read -r line; do
                    case "$line" in
                        "Version"*:*" ") echo -e "${GREEN} Version:${NC}       ${line#*: }" ;;
                        "Description"*:*" ") echo -e "${GREEN} Description:${NC}  $(echo "${line#*: }" | head -c 100)" ;;
                        "Download Size"*:*" ") echo -e "${GREEN} Download size:${NC} $(echo "${line#*: }" | sed 's/ //g')" ;;
                        "Installed Size"*:*" ") echo -e "${GREEN} Install size:${NC}  $(echo "${line#*: }" | sed 's/ //g')" ;;
                    esac
                done < <(pacman -Si "$pkg_name" 2>/dev/null)
                ;;
            fedora)
                while IFS= read -r line; do
                    case "$line" in
                        "Version"*":"*) echo -e "${GREEN} Version:${NC}       ${line#*: }" ;;
                        "Summary"*":"*) echo -e "${GREEN} Description:${NC}  $(echo "${line#*: }" | head -c 100)" ;;
                        "Download Size"*":"*) echo -e "${GREEN} Download size:${NC} ${line#*: }" ;;
                    esac
                done < <(dnf info "$pkg_name" 2>/dev/null)
                ;;
        esac
    fi

    if [ -n "$extra_info" ]; then
        echo -e "${GREEN} Info:${NC}         $extra_info"
    fi

    echo -e "${GREEN}═══════════════════════════════════════${NC}"

    if [ "$YES_MODE" = true ] || [ "$SELECTION_MODE" = true ] || [ "$DRY_RUN" = true ]; then
        return 0
    fi

    echo -ne "${GREEN}Install ${display_name}? [y/N] ${NC}"
    read -r confirm
    if [[ ! "$confirm" =~ ^[yY]([eE][sS])?$ ]]; then
        log_message "INFO" "Skipped: $display_name"
        return 1
    fi
    return 0
}
