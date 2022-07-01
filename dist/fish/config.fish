alias rm='rm -i'
alias ls='ls -FG'
alias ll='ls -alFG'
alias ..='cd ..'
alias mv='mv -i'
alias cp='cp -i'
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

function clearpath
  if test (count $argv) = 1
    if set -l ind (contains -i -- $argv[1] $PATH)
      set -e PATH[$ind]
    end
  else
    for a in $argv
      clearpath $a
    end
  end
end

function nvm
  bass source ~/.nvm/nvm.sh --no-use ';' nvm $argv
end

clearpath /usr/local/bin

export PATH="$GOPATH/bin:$PATH"
set -x GOPATH $HOME/go
set -x PATH ~/.rbenv/bin $HOME/.cargo/bin ~/.sdkman/candidates/sbt/current/bin /usr/local/bin/flutter/bin /usr/local/bin/gatling/bin ~/.nodebrew/current/bin /usr/local/opt/mysql-client/bin $GOPATH/bin $HOME/.nvm /usr/local/bin /usr/local/bin/flutter/.pub-cache/bin $fish_user_paths $PATH

bass source something.bash

# Created by `pipx` on 2021-11-14 07:34:33
set PATH $PATH /Users/tomo/.local/bin
set PATH $PATH $HOME/.pub-cache/bin

set -x EDITOR /usr/bin/vim
eval (direnv hook fish)
