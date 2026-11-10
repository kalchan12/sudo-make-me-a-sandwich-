#!/usr/bin/env bash
# id: tcsh
# name: Tcsh
# desc: C shell.
# method: apt
# pkg: tcsh
# tags: shell

install_tcsh() {
    install_with_fallback "Tcsh" "tcsh" "tcsh" "" "tcsh"
}
