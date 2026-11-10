#!/usr/bin/env bash
# id: zsh
# name: Zsh
# desc: Z shell.
# method: apt
# pkg: zsh
# tags: shell

install_zsh() {
    install_with_fallback "Zsh" "zsh" "zsh" "" "zsh"
}
