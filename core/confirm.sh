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
        local info_file
        info_file="$(mktemp)"
        case $DISTRO in
            debian)
                apt-cache show "$pkg_name" 2>/dev/null > "$info_file"
                if [ -s "$info_file" ]; then
                    local ver desc dl_size inst_size
                    while IFS= read -r line; do
                        case "$line" in
                            "Version: "*) ver="${line#Version: }" ;;
                            "Description-en: "*) desc="${line#Description-en: }" ;;
                            "Description: "*) desc="${line#Description: }" ;;
                            "Size: "*) dl_size="${line#Size: }" ;;
                            "Installed-Size: "*) inst_size="${line#Installed-Size: }" ;;
                        esac
                    done < "$info_file"
                    [ -n "$ver" ] && echo -e "${GREEN} Version:${NC}       $ver"
                    [ -n "$desc" ] && echo -e "${GREEN} Description:${NC}  $(echo "$desc" | head -c 100)"
                    [ -n "$dl_size" ] && echo -e "${GREEN} Download size:${NC} $(show_size "$dl_size")"
                    [ -n "$inst_size" ] && {
                        local inst_human
                        inst_human="$(show_size "$((inst_size * 1024))")"
                        echo -e "${GREEN} Install size:${NC}  $inst_human"
                    }
                fi
                ;;
            arch)
                pacman -Si "$pkg_name" 2>/dev/null > "$info_file"
                if [ -s "$info_file" ]; then
                    local ver desc dl_size inst_size
                    while IFS= read -r line; do
                        case "$line" in
                            "Version"*:*" ") ver="${line#*: }" ;;
                            "Description"*:*" ") desc="${line#*: }" ;;
                            "Download Size"*:*" ") dl_size="${line#*: }" ;;
                            "Installed Size"*:*" ") inst_size="${line#*: }" ;;
                        esac
                    done < "$info_file"
                    [ -n "$ver" ] && echo -e "${GREEN} Version:${NC}       $ver"
                    [ -n "$desc" ] && echo -e "${GREEN} Description:${NC}  $(echo "$desc" | head -c 100)"
                    [ -n "$dl_size" ] && echo -e "${GREEN} Download size:${NC} $(echo "$dl_size" | sed 's/ //g')"
                    [ -n "$inst_size" ] && echo -e "${GREEN} Install size:${NC}  $(echo "$inst_size" | sed 's/ //g')"
                fi
                ;;
            fedora)
                dnf info "$pkg_name" 2>/dev/null > "$info_file"
                if [ -s "$info_file" ]; then
                    local ver desc dl_size
                    while IFS= read -r line; do
                        case "$line" in
                            "Version"*":"*) ver="${line#*: }" ;;
                            "Summary"*":"*) desc="${line#*: }" ;;
                            "Download Size"*":"*) dl_size="${line#*: }" ;;
                        esac
                    done < "$info_file"
                    [ -n "$ver" ] && echo -e "${GREEN} Version:${NC}       $ver"
                    [ -n "$desc" ] && echo -e "${GREEN} Description:${NC}  $(echo "$desc" | head -c 100)"
                    [ -n "$dl_size" ] && echo -e "${GREEN} Download size:${NC} $dl_size"
                fi
                ;;
        esac
        rm -f "$info_file"
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
