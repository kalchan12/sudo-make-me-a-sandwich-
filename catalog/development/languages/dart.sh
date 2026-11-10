# id: dart
# name: Dart
# desc: Dart runtime.
# method: apt
# pkg: dart
# tags: lang

install_dart() {
    if command -v dart &> /dev/null; then
        log_message "WARN" "Dart is already installed."
        return
    fi
    confirm_install "Dart" "dart" || return
    if pkg_is_available dart; then
        pkg_install_native dart
    else
        _verbose_cmd "wget -qO /etc/apt/sources.list.d/dart_stable.list https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list"
        wget -qO /etc/apt/sources.list.d/dart_stable.list https://storage.googleapis.com/download.dartlang.org/linux/debian/dart_stable.list
        _verbose_cmd "apt update && apt install -y -V dart"
        apt update && apt install -y -V dart
    fi
    log_message "SUCCESS" "Dart installed."
    log_version "Dart" dart
}
