# ==============================================================================
# Shared tool catalog loader for sudo-make-me-a-sandwich
#
# Walks the `catalog/` directory tree and exposes the tool catalog as data.
# Category path comes from the module file location, e.g.
#   catalog/security/web/scanners/nuclei.sh
# resolves to category node "security/web/scanners" and tool id "nuclei".
#
# Module file format:
#   # id: nuclei
#   # name: Nuclei
#   # desc: Template-based vulnerability scanner
#   # method: go          (apt | deb_url | go | github_release | script | cargo)
#   # pkg: nuclei
#   # tags: bugbounty,web
#
#   install_nuclei() { ... }
# ==============================================================================

CATALOG_ROOT="${CATALOG_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/catalog}"
CATALOG_AVAILABLE=true
CATALOG_ORDERED=()
CATALOG_TOOLS=()
CATALOG_SUBS=()
CATALOG_GROUPS=()
CATALOG_CAT_LIST=()

catalog_collect() {
    CATALOG_ORDERED=()
    CATALOG_TOOLS=()
    CATALOG_SUBS=()
    CATALOG_GROUPS=()
    CATALOG_CAT_LIST=()
    local f rel path id fn name desc method pkg tags
    while IFS= read -r -d '' f; do
        rel="${f#"$CATALOG_ROOT"/}"
        path="${rel%/*}"
        id="${rel##*/}"
        id="${id%.sh}"
        fn="install_$id"
        name=$(sed -n 's/^# name:[[:space:]]*//p' "$f" | head -n1)
        desc=$(sed -n 's/^# desc:[[:space:]]*//p' "$f" | head -n1)
        method=$(sed -n 's/^# method:[[:space:]]*//p' "$f" | head -n1)
        pkg=$(sed -n 's/^# pkg:[[:space:]]*//p' "$f" | head -n1)
        tags=$(sed -n 's/^# tags:[[:space:]]*//p' "$f" | head -n1)
        [ -z "$name" ] && name="$id"
        [ -z "$pkg" ] && pkg="$id"
        CATALOG_ORDERED+=("$path|$id|$name|$desc|$method|$tags|$fn|$pkg")
    done < <(find "$CATALOG_ROOT" -type f -name '*.sh' -print0 | sort -z)
    return 0
}

catalog_init() {
    catalog_collect
}

_catalog_ensure() {
    if [ "${CATALOG_READY:-false}" != "true" ]; then
        catalog_collect
        CATALOG_READY=true
    fi
}

catalog_subgroups() {
    _catalog_ensure
    local cat="$1"
    CATALOG_SUBS=()
    local entry e_path e_sub first s
    for entry in "${CATALOG_ORDERED[@]}"; do
        IFS='|' read -r e_path e_id e_name e_desc e_method e_tags e_fn e_pkg <<< "$entry"
        [ "$e_path" = "$cat" ] && continue
        case "$e_path" in
            "$cat/"*)
                e_sub="${e_path#"$cat"/}"
                first="${e_sub%%/*}"
                local seen=false
                for s in "${CATALOG_SUBS[@]}"; do
                    [ "$s" = "$first" ] && seen=true
                done
                if [ "$seen" = false ]; then
                    CATALOG_SUBS+=("$first")
                fi
                ;;
        esac
    done
    return 0
}

catalog_tools() {
    _catalog_ensure
    local cat="$1"
    CATALOG_TOOLS=()
    local entry e_path e_name e_fn e_pkg
    local -a subs=()
    catalog_subgroups "$cat"
    subs=("${CATALOG_SUBS[@]}")
    local sub
    for entry in "${CATALOG_ORDERED[@]}"; do
        IFS='|' read -r e_path e_id e_name e_desc e_method e_tags e_fn e_pkg <<< "$entry"
        if [ "$e_path" = "$cat" ]; then
            CATALOG_TOOLS+=("$e_name|$e_fn|$e_pkg")
        else
            local matched=0
            for sub in "${subs[@]}"; do
                if [ "${e_path#"$cat"/}" = "$sub" ] || [ "${e_path#"$cat"/}" = "$sub/"* ]; then
                    matched=1
                    break
                fi
            done
            if [ "$matched" = 1 ]; then
                CATALOG_TOOLS+=("$e_name|$e_fn|$e_pkg")
            fi
        fi
    done
    return 0
}

catalog_install_one() {
    _catalog_ensure
    local id="$1"
    local entry e_id e_fn
    for entry in "${CATALOG_ORDERED[@]}"; do
        IFS='|' read -r e_id e_name e_desc e_method e_tags e_fn e_pkg <<< "${entry#*|}"
        if [ "$e_id" = "$id" ]; then
            eval "$e_fn"
            return $?
        fi
    done
    log_message "ERROR" "Unknown tool: '$id'"
    return 1
}

catalog_install_path() {
    _catalog_ensure
    # Install every tool under a category node (including subgroups).
    local node="$1"
    catalog_subgroups "$node"
    local has_subs=false
    [ ${#CATALOG_SUBS[@]} -gt 0 ] && has_subs=true
    if [ "$has_subs" = true ]; then
        local s
        for s in "${CATALOG_SUBS[@]}"; do
            catalog_install_path "$node/$s"
        done
        return 0
    fi
    local entry e_path e_name e_fn e_pkg ec
    for entry in "${CATALOG_ORDERED[@]}"; do
        IFS='|' read -r e_path e_id e_name e_desc e_method e_tags e_fn e_pkg <<< "$entry"
        if [ "$e_path" = "$node" ]; then
            eval "$e_fn"
            ec=$?
            if [ "$ec" -ne 0 ]; then
                log_message "ERROR" "$e_fn failed for $e_name (exit code $ec)."
                return "$ec"
            fi
        fi
    done
    return 0
}

catalog_install_all() {
    _catalog_ensure
    local g
    catalog_group_list
    local gpath
    for g in "${CATALOG_GROUPS[@]}"; do
        gpath="$(catalog_group_path "$g")"
        catalog_categories "$gpath"
        local c
        for c in "${CATALOG_CAT_LIST[@]}"; do
            catalog_install_path "$c"
        done
    done
    return 0
}

catalog_check_path() {
    _catalog_ensure
    local node="$1"
    local entry e_path e_id e_name e_desc e_method e_tags e_fn e_pkg
    catalog_subgroups "$node"
    local has_subs=false
    [ ${#CATALOG_SUBS[@]} -gt 0 ] && has_subs=true
    if [ "$has_subs" = true ]; then
        local s
        for s in "${CATALOG_SUBS[@]}"; do
            catalog_check_path "$node/$s"
        done
        return 0
    fi
    for entry in "${CATALOG_ORDERED[@]}"; do
        IFS='|' read -r e_path e_id e_name e_desc e_method e_tags e_fn e_pkg <<< "$entry"
        if [ "$e_path" = "$node" ]; then
            local check_bin="$e_pkg"
            [ -n "$check_bin" ] || check_bin="${e_id//_/-}"
            if bin_check "$check_bin"; then
                gecho "[✔] $e_name is installed."
            else
                echo -e "${RED:-}[✘] $e_name is NOT installed.${NC:-}"
            fi
        fi
    done
    return 0
}

catalog_tool_count_for() {
    _catalog_ensure
    local node="$1"
    local count=0
    local entry e_path
    for entry in "${CATALOG_ORDERED[@]}"; do
        IFS='|' read -r e_path e_id e_name e_desc e_method e_tags e_fn e_pkg <<< "$entry"
        if [ "$e_path" = "$node" ]; then
            count=$((count + 1))
        fi
    done
    echo "$count"
}

catalog_group_list() {
    _catalog_ensure
    CATALOG_GROUPS=("General" "Development" "Security")
    return 0
}

catalog_group_path() {
    _catalog_ensure
    case "$1" in
        General) echo "general" ;;
        Development) echo "development" ;;
        Security) echo "security" ;;
        *) echo "" ;;
    esac
}

catalog_categories() {
    _catalog_ensure
    local group="$1"
    CATALOG_CAT_LIST=()
    local entry e_path e_first s
    for entry in "${CATALOG_ORDERED[@]}"; do
        IFS='|' read -r e_path e_id e_name e_desc e_method e_tags e_fn e_pkg <<< "$entry"
        if [ "${e_path%%/*}" != "$group" ]; then
            continue
        fi
        e_first="${e_path#"$group"/}"
        e_first="${e_first%%/*}"
        local key="$group/$e_first"
        local seen=false
        for s in "${CATALOG_CAT_LIST[@]}"; do
            [ "$s" = "$key" ] && seen=true
        done
        if [ "$seen" = false ]; then
            CATALOG_CAT_LIST+=("$key")
        fi
    done
    return 0
}

catalog_title() {
    local node="$1"
    local rest="${node#*/}"
    local seg out=""
    local -a segs=()
    local s
    IFS='/' read -ra segs <<< "$rest"
    for s in "${segs[@]}"; do
        if [ -n "$out" ]; then out="$out & "; fi
        case "$s" in
            browsers) out="${out}Browsers" ;;
            terminal_shells) out="${out}Terminal & Shell" ;;
            cli_utilities) out="${out}CLI Utilities" ;;
            apps) out="${out}Apps" ;;
            privacy) out="${out}Privacy" ;;
            editors_ides) out="${out}Editors & IDEs" ;;
            languages) out="${out}Languages" ;;
            app_frameworks) out="${out}App Frameworks" ;;
            containers) out="${out}Containers" ;;
            recon_osint) out="${out}Recon & OSINT" ;;
            network) out="${out}Network" ;;
            web) out="${out}Web" ;;
            credentials) out="${out}Credentials" ;;
            wireless) out="${out}Wireless" ;;
            reverse_forensics) out="${out}Reverse Engineering & Forensics" ;;
            terminals) out="${out}Terminals" ;;
            multiplexers) out="${out}Multiplexers" ;;
            shells) out="${out}Shells" ;;
            editors) out="${out}Editors" ;;
            ides) out="${out}IDEs" ;;
            ai_coding) out="${out}AI Coding" ;;
            subdomains) out="${out}Subdomains" ;;
            osint) out="${out}OSINT" ;;
            fingerprinting) out="${out}Fingerprinting" ;;
            exploit_lookup) out="${out}Exploit Lookup" ;;
            scanning) out="${out}Scanning" ;;
            sniffing) out="${out}Sniffing & MITM" ;;
            utilities) out="${out}Utilities" ;;
            proxies) out="${out}Proxies" ;;
            discovery) out="${out}Discovery & Fuzzing" ;;
            scanners) out="${out}Scanners" ;;
            exploitation) out="${out}Exploitation" ;;
            online) out="${out}Online Attacks" ;;
            offline) out="${out}Offline Cracking" ;;
            reverse) out="${out}Reverse Engineering" ;;
            forensics) out="${out}Forensics" ;;
            *) out="${out}$(echo "$s" | sed -e 's/_/ /g' -e 's/\b\(.\)/\U\1/g')" ;;
        esac
    done
    echo "$out"
}

show_catalog_menu() {
    local node="$1"
    local on_back="$2"
    local title
    title="$(catalog_title "$node")"
    catalog_subgroups "$node"
    local -a subs=("${CATALOG_SUBS[@]}")
    local has_subs=false
    [ ${#subs[@]} -gt 0 ] && has_subs=true
    if [ "$has_subs" = true ]; then
        echo ""
        echo -e "${PURPLE}── $title ──${NC}"
        local i=1
        local s cnt
        for s in "${subs[@]}"; do
            cnt="$(catalog_tool_count_for "$node/$s")"
            echo -e "${YELLOW}${i})${GREEN} ${catalog_title "$node/$s"} (${cnt})${NC}"
            i=$((i+1))
        done
        echo -e "${YELLOW}${i})${GREEN} Back${NC}"
        echo -n -e "${PURPLE}Select option: ${NC}${YELLOW}"
        local choice
        read -r choice
        echo -e -n "${NC}"
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -lt "$i" ]; then
            local sel="$((choice - 1))"
            show_catalog_menu "$node/${subs[$sel]}" "$on_back"
            return 0
        fi
        eval "$on_back"
        return 0
    fi
    catalog_tools "$node"
    local n=${#CATALOG_TOOLS[@]}
    if [ "$n" -eq 0 ]; then
        eval "$on_back"
        return 0
    fi
    echo ""
    echo -e "${PURPLE}── $title ──${NC}"
    local idx=1
    local t
    for t in "${CATALOG_TOOLS[@]}"; do
        local name="${t%%|*}"
        echo -e "${YELLOW}${idx})${GREEN} Install ${name}${NC}"
        idx=$((idx+1))
    done
    local all_idx=$idx
    echo -e "${YELLOW}${all_idx})${GREEN} Install All${NC}"
    local check_idx=$((all_idx+1))
    echo -e "${YELLOW}${check_idx})${GREEN} Check Installations${NC}"
    local back_idx=$((all_idx+2))
    echo -e "${YELLOW}${back_idx})${GREEN} Back${NC}"
    echo -e "${PURPLE}Enter a number to install, or e<N> for details (e.g., e1)${NC}"
    echo -n -e "${PURPLE}Select option: ${NC}${YELLOW}"
    local choice
    read -r choice
    echo -e -n "${NC}"
    if [[ "$choice" = "all" ]] || [[ "$choice" = "$all_idx" ]]; then
        catalog_install_path "$node"
        return 0
    elif [[ "$choice" = "$check_idx" ]]; then
        catalog_check_path "$node"
        return 0
    elif [[ "$choice" = "$back_idx" ]]; then
        eval "$on_back"
        return 0
    elif [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -lt "$all_idx" ]; then
        local sel="$((choice - 1))"
        local t2="${CATALOG_TOOLS[$sel]}"
        local fn2="${t2#*|}"
        fn2="${fn2%%|*}"
        eval "$fn2"
        return 0
    fi
    return 0
}
