# Shell options
shopt -s autocd cdspell dirspell globstar checkwinsize nocaseglob
bind 'set completion-ignore-case on'
bind 'set show-all-if-ambiguous on'
bind 'set colored-stats on'
bind '"\e[A": history-search-backward'   # Up arrow: prefix search
bind '"\e[B": history-search-forward'

# Completion
[[ -r /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion
