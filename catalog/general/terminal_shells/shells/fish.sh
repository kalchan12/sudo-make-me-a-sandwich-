#!/usr/bin/env bash
# id: fish
# name: Fish
# desc: Friendly interactive shell.
# method: apt
# pkg: fish
# tags: shell

install_fish() {
    install_with_fallback "Fish" "fish" "fish" "" "fish"
}
