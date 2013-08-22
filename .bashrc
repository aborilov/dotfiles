#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
#PS1='[\u@\h \W]\$ '
PS1="$sq_color\342\224\214\342\224\200\$([[ \$? != 0 ]] && echo \"[\[\033[01;36m\]\342\234\227$sq_color]\342\224\200\")[\[\033[01;31m\]\t$sq_color]\342\224\200[\[\033[01;36m\]\u@\h$sq_color]\n\342\224\224\342\224\200\342\224\200> \[\033[01;35m\]\W$sq_color $ \[\033[01;32m\]>>\\[\\033[0m\\] "
export EDITOR="vim"
VBOX_USB=usbfs
alias ssh="TERM=rxvt ssh"
alias gs='git status '
alias ga='git add '
alias gb='git branch '
alias gc='git commit'
alias gd='git diff'
alias go='git checkout '
alias gk='gitg&'
