#!/usr/bin/env bash
# id: ksh
# name: Ksh
# desc: Korn shell.
# method: apt
# pkg: ksh
# tags: shell

install_ksh() {
    install_with_fallback "Ksh" "ksh" "ksh" "" "ksh"
}
