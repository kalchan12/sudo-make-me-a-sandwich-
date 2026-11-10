#!/usr/bin/env bash
# id: nextjs
# name: Next.js
# desc: Next.js framework.
# method: apt
# pkg: next
# tags: dev,framework

install_nextjs() {
    if command -v npx &> /dev/null && npx create-next-app --version &> /dev/null; then
        log_message "WARN" "Next.js is already available via npx."
        return
    fi

    confirm_install "Next.js" "" "Requires Node.js and npm" || return

    if ! command -v node &> /dev/null || ! command -v npm &> /dev/null; then
        log_message "ERROR" "Node.js and npm are required. Install Node.js first."
        return 1
    fi

    log_message "INFO" "Next.js is available via npx. No global install needed."
    log_message "INFO" "Run 'npx create-next-app@latest my-app' to create a new project."
    log_message "SUCCESS" "Next.js ready to use via npx."
}
