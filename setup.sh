#!/bin/zsh

DOTFILES="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

link() {
    SRC=$1
    DST=$2

     if [ -e "$DST" ]; then
         if [ -L "$DST" ]; then
              echo -n "Target $DST is a symlink. Do you want to replace it? (y/n) "
              read REPLY
              if [[ $REPLY =~ ^[^Yy]$ ]]; then
                  return
              fi;
          else
              echo -n "Target $DST exists and is not a symlink. Do you want to replace it? (y/n) "
              read REPLY
              if [[ $REPLY =~ ^[^Yy]$ ]]; then
                  return
              fi;
         fi
     fi

    ln -sf "$SRC" "$DST"
    echo "Created symlink $DST"
}

# 1. Create symlinks to the dotfiles

echo "Creating symlinks..."

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

echo ""

# 2. Setup scripts

echo "Setting up ~/.zsh scripts..."

SCRIPTS="$HOME/.zsh"
if [ ! -d "$SCRIPTS" ]; then
    mkdir "$SCRIPTS"
fi

curl -s -o "$SCRIPTS/git-completion.zsh" https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.zsh
curl -s -o "$SCRIPTS/git-prompt.sh" https://raw.githubusercontent.com/git/git/master/contrib/completion/git-prompt.sh

echo ""

# 3. Get tmux plugin manager.

echo "Setting up the tmux plugin manager..."

TMUX_PLUGINS="$HOME/.tmux/plugins/tmp";
if [ ! -d "$TMUX_PLUGINS" ]; then
    echo "Getting tmux plugin manager...";
    git clone https://github.com/tmux-plugins/tpm "$TMUX_PLUGINS";
fi

echo ""


echo "Setup complete!"
