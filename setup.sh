#!/usr/bin/env bash

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

link() {
    SRC=$1
    DST=$2

     if [ -e "$DST" ]; then
         if [ -L "$DST" ]; then
              read -r -p "Target $DST is a symlink. Do you want to replace it? (y/n) "
              if [[ $REPLY =~ ^[^Yy]$ ]]; then
                  return
              fi;
          else
              read -r -p "Target $DST exists and is not a symlink. Do you want to replace it? (y/n) "
              if [[ $REPLY =~ ^[^Yy]$ ]]; then
                  return
              fi;
         fi
     fi

    ln -sf "$SRC" "$DST"
    echo "Created symlink $DST"
}

# create symlinks to the dotfiles

for DIR in editor git shell; do
    for SOURCE in "$DOTFILES/$DIR"/*; do
        TARGET="$HOME/.$(basename $SOURCE)"

        if [ -f "$SOURCE" ]; then
            link "$SOURCE" "$TARGET"

        elif [ -d "$SOURCE" ]; then
            pushd $SOURCE > /dev/null

            # recreate directory structure without the files
            find . -type d -exec mkdir -p -- $TARGET/{} \;

            for FILE in $(find . -type f); do
                link "$PWD/${FILE#./}" "$TARGET/${FILE#./}"
            done

            popd > /dev/null
        fi
    done
done

# setup scripts

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
