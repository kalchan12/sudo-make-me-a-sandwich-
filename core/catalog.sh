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

catalog_collect() {
    CATALOG_ORDERED=()
    CATALOG_TOOLS=()
    CATALOG_SUBS=()
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

# catalog_subgroups <category_path>  -> sets CATALOG_SUBS (array of subgroup keys)
catalog_subgroups() {
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

# catalog_tools <category_path> -> sets CATALOG_TOOLS (array of "Display|func|pkg")
catalog_tools() {
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
                if [ "$e_path" = "$cat/$sub" ] || [ "${e_path#"$cat"/}" = "$sub" ] || [ "${e_path#"$cat"/}" = "$sub/"* ]; then
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
    local node="$1"
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
