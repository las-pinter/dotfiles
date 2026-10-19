#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

if [[ -d ~/.bashrc.d ]]; then
  for f in ~/.bashrc.d/*.sh; do
    [[ -r $f ]] && . "$f"
  done
  unset f
fi

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi