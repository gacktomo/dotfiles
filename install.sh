#!/bin/bash

set -u

THIS_DIR=$(cd $(dirname $0); pwd)

cd $THIS_DIR
git submodule init
git submodule update

echo "start setup..."
for f in .??*; do
    [ "$f" = ".git" ] && continue
    [ "$f" = ".gitconfig.local.template" ] && continue
    [ "$f" = ".gitmodules" ] && continue

    ln -snfv ~/dotfiles/"$f" ~/
done

[ -e ~/.gitconfig.local ] || cp ~/dotfiles/.gitconfig.local.template ~/.gitconfig.local

# bash
echo "test -r ~/.bashrc && . ~/.bashrc" >> ~/.bash_profile
if [ "$(uname)" == 'Darwin' ]; then
  brew install bash-completion
  echo "[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion" >> ~/.bash_profile
  ln -s /Library/Developer/CommandLineTools/usr/share/git-core/git-completion.bash /usr/local/etc/bash_completion.d/git-completion.bash
  exec $SHELL -l
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
fi

# fish
ln -sf ~/dotfiles/fish ~/.config/fish
ln -sf ~/dotfiles/fisher ~/.config/fisher

cat << END

**************************************************
DOTFILES SETUP FINISHED! bye.
**************************************************

END
