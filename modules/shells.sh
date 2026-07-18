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
    _render_menu SHELLS_LIST "Shells" \
        install_shells check_shells_installations show_main_menu
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
    _check_installations SHELLS_LIST \
        "Zsh:zsh" "Fish:fish" "Dash:dash" "Ksh:ksh" "Tcsh:tcsh" \
        "Nushell:nu" "Elvish:elvish" "Xonsh:xonsh"
}
