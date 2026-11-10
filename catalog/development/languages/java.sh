#!/usr/bin/env bash
# id: java
# name: Java (OpenJDK)
# desc: Java runtime.
# method: apt
# pkg: default-jdk
# tags: lang

install_java() {
    if command -v java &> /dev/null; then
        log_message "WARN" "Java is already installed."
        return
    fi
    confirm_install "Java (OpenJDK)" "default-jdk" || return
    install_with_fallback "Java (OpenJDK)" "default-jdk" "jdk-openjdk" "" "java"
    log_version "Java" default-jdk java
}
