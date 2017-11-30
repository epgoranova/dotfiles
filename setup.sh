#!/usr/bin/env bash

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create symlinks to the dotfiles.

for DIR in editor git shell; do
    for TEMPLATE in "$DOTFILES/$DIR"/*; do
        TARGET="$HOME/.$(basename $TEMPLATE)"

        if [ -e "$TARGET" ]; then
            if [ -L "$TARGET" ]; then
                read -r -p "Target $TARGET is a symlink. Do you want to replace it? (y/n) "
                if [[ $REPLY =~ ^[^Yy]$ ]]; then
                    continue
                fi;
            else
                read -r -p "Target $TARGET exists and is not a symlink. Do you want to replace it? (y/n) "
                if [[ $REPLY =~ ^[^Yy]$ ]]; then
                    continue
                fi;
            fi
        fi

        ln -sf "$TEMPLATE" "$TARGET"
        echo "Created $TARGET symlink"
    done
done

# Setup scripts.

BASH_SCRIPTS="$HOME/.bash"
if [ ! -d "$BASH_SCRIPTS" ]; then
    mkdir "$BASH_SCRIPTS"
fi

if [ ! -f "$BASH_SCRIPTS/git-prompt.sh" ]; then
    cp "$DOTFILES/scripts/git-prompt.sh" "$BASH_SCRIPTS/git-prompt.sh"
    echo "Set up git prompt"
fi

if [ ! -f "$BASH_SCRIPTS/git-completion.sh" ]; then
    cp "$DOTFILES/scripts/git-completion.sh" "$BASH_SCRIPTS/git-completion.sh"
    echo "Set up git completion"
fi

# Get tmux plugin manager.

TMUX_PLUGINS="$HOME/.tmux/plugins/tmp";
if [ ! -d "$TMUX_PLUGINS" ]; then
    echo "Getting tmux plugin manager...";
    git clone https://github.com/tmux-plugins/tpm "$TMUX_PLUGINS";
fi
