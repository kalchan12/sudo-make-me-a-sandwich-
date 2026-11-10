#!/usr/bin/env bash
# id: xonsh
# name: Xonsh
# desc: Python-powered shell.
# method: apt
# pkg: xonsh
# tags: shell

install_xonsh() {
    install_with_fallback "Xonsh" "xonsh" "xonsh" "" "xonsh"
}
