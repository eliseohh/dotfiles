export ZSH="/home/eliseo/.oh-my-zsh"

ZSH_THEME="jovial"

plugins=(
    git
    urltools
    bgnotify
    zsh-autosuggestions
    jovial
    tmux
)

source $ZSH/oh-my-zsh.sh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  

export JAVA_HOME="/opt/jdk8u242-b08"
export PATH=$JAVA_HOME/bin:$PATH

export GOROOT="/opt/go"
export GOPATH="$HOME/go"
export PATH=$PATH:$GOROOT/bin:$GOPATH/bin

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

POWERLEVEL9K_MODE="hack 10"

