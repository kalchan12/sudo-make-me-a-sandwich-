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

SUDO_CMD=""
if [[ $EUID -ne 0 ]]; then
    SUDO_CMD="sudo"
fi

if ( : </dev/tty ) 2>/dev/null; then
    exec $SUDO_CMD "$DEST/setup.sh" "$@" </dev/tty
else
    exec $SUDO_CMD "$DEST/setup.sh" "$@"
fi
