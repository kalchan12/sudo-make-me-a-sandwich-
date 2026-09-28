#!/bin/bash
set -e

REPO="kalchan12/sudo-make-me-a-sandwich-"
DEST="${HOME}/.sudo-make-me-a-sandwich"

if [ -d "$DEST" ]; then
    echo "Updating existing installation..."
    git -C "$DEST" pull --ff-only
else
    echo "Cloning into $DEST..."
    git clone "https://github.com/$REPO.git" "$DEST"
fi

HAS_CLI=false
for arg in "$@"; do
    case "$arg" in
        --cli|--tui|--install|--full|--minimal|-u|--update)
            HAS_CLI=true
            ;;
    esac
done

if [ -n "$DISPLAY" ] || [ -n "$WAYLAND_DISPLAY" ]; then
    if [ "$HAS_CLI" = false ]; then
        exec "$DEST/setup.sh" "$@"
    fi
fi

SUDO_CMD=""
if [[ $EUID -ne 0 ]]; then
    SUDO_CMD="sudo"
fi

if ( : </dev/tty ) 2>/dev/null; then
    exec $SUDO_CMD "$DEST/setup.sh" "$@" </dev/tty
else
    exec $SUDO_CMD "$DEST/setup.sh" "$@"
fi
