#!/usr/bin/env bash
# id: elvish
# name: Elvish
# desc: Rust-based shell.
# method: apt
# pkg: elvish
# tags: shell

install_elvish() {
    install_with_fallback "Elvish" "elvish" "elvish" "" "elvish"
}
