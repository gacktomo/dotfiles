#!/bin/bash
set -u

THIS_DIR=$(cd $(dirname $0); pwd)
cd $THIS_DIR

echo "start setup..."
# Copy dotfiles
for f in dist/dotfiles/.??*; do
    ln -snfv ~/dotfiles/"$f" ~/
done

[ -e ~/.gitconfig.local ] || cp ~/dotfiles/.gitconfig.local.template ~/.gitconfig.local

# Copy fish files
mkdir -p ~/.config/fish
ln -sf ~/dotfiles/dist/fish/config.fish ~/.config/fish
ln -sf ~/dotfiles/dist/fish/fish_plugins ~/.config/fish
ln -sf ~/dotfiles/dist/fish/fish_variables ~/.config/fish

# Install vim plug
mkdir -p ~/.vim/autoload
mkdir -p ~/.vim/colors
curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

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

cat << END

**************************************************
DOTFILES SETUP FINISHED! bye.
**************************************************

END
