alias dotfiles='git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# Aliases
alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --git --group-directories-first'
alias lt='eza --tree --level=2 --icons'
alias cat='bat --paging=never'
alias grep='grep --color=auto'
alias df='df -hT'
alias free='free -h'
alias ip='ip -c'
alias diff='diff --color=auto'

# Arch
alias pacs='pacman -Ss'
alias pacu='sudo pacman -Syu'
alias pacr='sudo pacman -Rns'
alias pacorphans='pacman -Qdtq'
alias yayu='yay -Sua'
alias jerr='journalctl -p 3 -xb'
alias cleanpkg='sudo paccache -rk2'

# Git
alias gistat='git status'
alias gipure='git pull --rebase'
alias gilonast='git log --name-status'
alias gicoam='git commit --amend'
alias gibra='git branch -a'
alias gichema='git checkout main'