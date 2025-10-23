alias rm='rm -i'
alias ls='ls -FG'
alias ll='ls -alFG'
alias ..='cd ..'
alias mv='mv -i'
alias cp='cp -i'
alias g='cd (ghq root)/(ghq list | peco)'
alias gs='git status'
alias ga='git add -A'
alias gl="git log --graph --oneline --decorate=full -20 --date=short --format='%C(yellow)%h%C(reset) %C(magenta)[%ad]%C(reset)%C(auto)%d%C(reset) %s %C(cyan)@%an%C(reset)'"
alias gca='git add -A && git commit -m'
alias gpull='git pull origin (brname)'
alias gpush='git push origin HEAD'
alias gco='git checkout'
alias gcopr='~/dotfiles/gcopr.sh'
alias brname='git symbolic-ref --short HEAD'
alias c='clear'

export TZ=UTC
set -g theme_date_timezone Asia/Tokyo
set -g theme_date_format  "+%Y-%m-%d %H:%M:%S"

set -x GOPATH $HOME/go
set -x ANDROID_HOME $HOME/Library/Android/sdk

# pnpm
set -x PNPM_HOME "$HOME/Library/pnpm"

# brew
eval (/opt/homebrew/bin/brew shellenv)

# Set default editor
set -x EDITOR /usr/bin/vim

# Google Cloud SDK
if [ -f '/usr/local/bin/google-cloud-sdk/path.fish.inc' ]; . '/usr/local/bin/google-cloud-sdk/path.fish.inc'; end

# Flutter
export FLUTTER_ROOT="$(asdf where flutter)"

# asdf
# source (brew --prefix asdf)/libexec/asdf.fish
# rm -rf ~/.asdf/shims && asdf reshim
. ~/.asdf/plugins/java/set-java-home.fish

# Add to PATH
fish_add_path ~/.rbenv/bin
fish_add_path $HOME/.cargo/bin
fish_add_path ~/.sdkman/candidates/sbt/current/bin
fish_add_path /usr/local/bin/flutter/bin
fish_add_path /usr/local/bin/gatling/bin
fish_add_path /usr/local/opt/mysql-client/bin
fish_add_path $GOPATH/bin
fish_add_path /usr/local/bin
fish_add_path /usr/local/bin/flutter/.pub-cache/bin
fish_add_path $HOME/.local/bin
fish_add_path $HOME/.pub-cache/bin
fish_add_path $PNPM_HOME
fish_add_path $HOME/.asdf/shims
