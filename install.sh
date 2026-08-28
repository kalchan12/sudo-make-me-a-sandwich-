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

if ( : </dev/tty ) 2>/dev/null; then
    exec "$DEST/setup.sh" "$@" </dev/tty
else
    exec "$DEST/setup.sh" "$@"
fi
