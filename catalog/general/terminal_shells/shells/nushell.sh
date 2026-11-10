#!/usr/bin/env bash
# id: nushell
# name: Nushell
# desc: Modern shell with structured CLI output.
# method: apt
# pkg: nushell
# tags: shell

install_nushell() {
    install_with_fallback "Nushell" "nushell" "nushell-bin" "" "nu"
}
