alias q='clear'

if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi

if [ -d /usr/local/go/bin ]; then
  export PATH="$PATH:/usr/local/go/bin"
fi

# file system
alias ..='cd ..;ls --color=auto'
alias ...='cd ../../;ls --color=auto'

alias ll='ls -lha'

# tmux
alias tnew='tmux -2 new -s'
alias tati='tmux -2 attach -t'
alias tkll='tmux kill-ses -t'

# k8s
alias k='kubectl'
alias kg='k get'
alias ka='k apply -f'
alias kdes='k describe'
alias kx='k exec'
alias kdel='k delete'
alias kl='k logs'

if command -v kubectl > /dev/null 2>&1; then
  source <(kubectl completion bash)
  complete -o default -F __start_kubectl k
fi

# command search
if [[ $- == *i* ]]
then
  bind '"\e[A": history-search-backward'
  bind '"\e[B": history-search-forward'
  bind '"\e[C": forward-char'
  bind '"\e[D": backward-char'
fi
