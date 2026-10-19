# History
HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth:erasedups   # skip dupes and space-prefixed cmds
HISTTIMEFORMAT='%F %T '
HISTIGNORE='ls:ll:cd:pwd:exit:clear:history'
shopt -s histappend cmdhist
