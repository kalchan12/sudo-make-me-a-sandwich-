# id: kotlin
# name: Kotlin
# desc: Kotlin runtime.
# method: apt
# pkg: kotlin
# tags: lang

install_kotlin() {
    if command -v kotlin &> /dev/null; then
        log_message "WARN" "Kotlin is already installed."
        return
    fi
    confirm_install "Kotlin" "kotlin" || return
    install_with_fallback "Kotlin" "kotlin" "kotlin" "" "kotlin"
}
