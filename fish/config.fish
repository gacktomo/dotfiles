set -U FZF_LEGACY_KEYBINDINGS 0
fish_vi_key_bindings
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
alias gpull='git pull origin master'
alias gpush='git push origin master'
alias gcopr='~/dotfiles/gcopr.sh'
alias c='clear'