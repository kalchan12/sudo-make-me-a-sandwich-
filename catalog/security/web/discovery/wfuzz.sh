# id: wfuzz
# name: Discovery
# desc: Web fuzzer.
# method: go
# pkg: wfuzz
# tags: security,web

install_wfuzz() {
    if command -v wfuzz &> /dev/null; then
        log_message "WARN" "wfuzz is already installed."
        return
    fi
    confirm_install "wfuzz" "wfuzz" || return
    install_with_fallback "wfuzz" "wfuzz" "wfuzz" "" "wfuzz"
    _verify_install "wfuzz" wfuzz
}
