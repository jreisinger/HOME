# Non-login, i.e. run on every instance. Place for aliases and functions.

# Creating a symlink between ~/.bashrc and ~/.bash_profile will ensure that the
# same startup scripts run for both login and non-login sessions. Debian's
# ~/.profile sources ~/.bashrc, which has a similar effect.

###########
# History #
###########

# so history gets saved on Mac
export SHELL_SESSION_HISTORY=0

export HISTSIZE=99999
export HISTFILESIZE=99999

# don't store duplicate lines or lines starting with space in the history
export HISTCONTROL=ignorespace:ignoredups:erasedups

###########
# Aliases #
###########

alias ls='ls --color=auto --group-directories-first'
alias l='ls'
alias ll='ls -l'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

alias vi='vim'

if which kubectl > /dev/null 2>&1; then
    alias k=kubectl
    complete -F __start_kubectl k # enable completion for k alias
fi

########
# PATH #
########

# when on Mac use GNU instead of BSD tools if they are installed (brew install
# coreutils)
if [[ $(uname -s) == "Darwin" ]] && [[ -e "/usr/local/opt/coreutils/libexec/gnubin" ]]; then
        PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [[ -d "$HOME/bin" ]]; then
    PATH="$PATH:$HOME/bin"
fi

# add to PATH the dir where go binary is installed
if [[ -d /usr/local/go/bin ]]; then
    PATH="$PATH:/usr/local/go/bin"
fi

# add go's bin to PATH
if [[ -d "$HOME/go/bin" ]]; then
    PATH="$PATH:$HOME/go/bin"
fi

# add aws to PATH
if [[ -d "$HOME/.local/bin" ]]; then
    PATH="$PATH:$HOME/.local/bin"
fi

# add brew python3 binary to PATH (Mac)
if [[ -d "/usr/local/opt/python@3/libexec/bin" ]]; then
    PATH="$PATH:/usr/local/opt/python@3/libexec/bin"
fi

# add user python3 library to PATH (Mac)
if [[ -d "$HOME/Library/Python/3.8/bin" ]]; then
    PATH="$PATH:$HOME/Library/Python/3.8/bin"
fi

# add Visual Studio Code (code)
if [[ -d "/Applications/Visual Studio Code.app/Contents/Resources/app/bin" ]]; then
    PATH="$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
fi

# dedup PATH
PATH="$(perl -e 'print join(":", grep { not $seen{$_}++ } split(/:/, $ENV{PATH}))')"

###############
# Completions #
###############

# SSH hostnames completion (based on ~/.ssh/config)
if [ -e ~/.ssh_bash_completion ]; then
    source ~/.ssh_bash_completion
fi

# K8s autocompletion.
if which kubectl > /dev/null 2>&1; then
    source <(kubectl completion bash)
fi
# Linux
if [[ -r '/usr/share/bash-completion/bash_completion' ]]; then
    source '/usr/share/bash-completion/bash_completion'
fi
# Mac
if [[ -r '/usr/local/etc/profile.d/bash_completion.sh' ]]; then
    source '/usr/local/etc/profile.d/bash_completion.sh'
fi

################
# PROMPT (PS1) #
################

# NOTE: \[\] around colors and other non printable bytes are needed so bash can
# count prompt (PS1) length correctly. Otherwise you get rewritten text.

# K8s context in PS1. My alternative to https://github.com/jonmosco/kube-ps1.
function __k8s_context {
    local ctx=""
    ctx=$(kubectl config view --minify --output json 2> /dev/null | jq -r '.["current-context"]')
    [[ -n "$ctx" ]] && echo "[$ctx]"
}

function _get_git_version {
    local ver
    ver=$(git version | perl -ne '/([\d\.]+)/ && print $1')
    echo "$ver"
}

function __prompt_command {
    # This needs to be first
    local EXIT="$?"

    # Terminal colors
    local blu='\[\e[0;34m\]'
    local ylw='\[\e[0;33m\]'
    local bldred='\[\e[31m\]'
    local bldgrn='\[\e[1;32m\]'
    local txtrst='\[\e[0m\]'
    # Background colors - https://askubuntu.com/questions/558280/changing-colour-of-text-and-background-of-terminal
    local bcgblu='\[\e[48;5;195m\]'

    # Download and source git prompt
    if [ ! -f ~/.git-prompt-"$(_get_git_version)".sh ]; then
        curl --silent https://raw.githubusercontent.com/git/git/v$(_get_git_version)/contrib/completion/git-prompt.sh --output ~/.git-prompt-$(_get_git_version).sh
    fi
    source ~/.git-prompt-$(_get_git_version).sh

    # git prompt (__git_ps1) configuration
    export GIT_PS1_SHOWDIRTYSTATE=1
    export GIT_PS1_SHOWUNTRACKEDFILES=1

    # how long the working dir path (\w) should be
    PROMPT_DIRTRIM=5

    PS1="${blu}\h${txtrst} ${bcgblu}\w${txtrst} \$(__git_ps1 '(%s)')"

    # Add color when in context where a bit of caution is appropriate
    local k8s_context
    k8s_context=$(__k8s_context)
    if [[ $k8s_context =~ (.*)(prod|admin)(.*) ]]; then
        PS1+=" ${BASH_REMATCH[1]}${ylw}${BASH_REMATCH[2]}${txtrst}${BASH_REMATCH[3]}"
    else
        PS1+=" $k8s_context"
    fi

    # Set terminal tab title
    echo -ne "\033]0;$(hostname):$(basename "$PWD")\007"

    # Set color based on the command's exit code
    if [[ $EXIT -eq 0 ]]; then
        PS1+="\n${bldgrn}> ${txtrst}"
    else
        PS1+="\n${bldred}> ${txtrst}"
    fi
}

# Function that runs after each command to generate the prompt. Adapted from
# https://stackoverflow.com/questions/16715103/bash-prompt-with-last-exit-code
PROMPT_COMMAND=__prompt_command

######################
# Productivity tools #
######################

# cd to one of my commonly used directories.
function c {
    local proj
    proj=$(find -L \
        ~/git/hub ~/git/lab ~/OneDrive/data ~/OneDrive/temp \
        -maxdepth 1 -type d | peco)
    cd "$proj" || return
}

# Search history with peco. Don't run cmmand from h just store it into history.
function h {
    local tac
    if which tac > /dev/null; then
        tac="tac"
    else
        tac="tail -r"
    fi

    # awk removes duplicate lines (even not adjacent) and keeps the original order
    local cmd
    cmd=$(history | $tac | cut -c 8- | awk '!seen[$0]++' | peco)

    history -s "$cmd" # add $cmd to history

    #echo $cmd
    #$cmd
}

#######
# K8s #
#######

# No k8s cluster configuration selected by default.
unset KUBECONFIG

# Allow me to select from multiple k8s clusters configurations.
function kc {
    local k8s_config
    k8s_config=$(find "$HOME"/.kube -type f \( -iname '*.yaml' -o -iname '*.yml' -o -iname '*.conf' \) | peco)
    export KUBECONFIG="$k8s_config"
}

###########
# MacBook #
###########

if [[ $(uname -s) == "Darwin" ]]; then
    # Stop saying that zsh is the new default.
    export BASH_SILENCE_DEPRECATION_WARNING=1

    # So Python can find CA certificates.
    ALL_CA_CERTIFICATES="/usr/local/share/ca-certificates/cacert.pem"
    if [[ -f "$ALL_CA_CERTIFICATES" ]]; then
        export REQUESTS_CA_BUNDLE=$ALL_CA_CERTIFICATES
    fi

    # So gpg is working.
    GPG_TTY=$(tty)
    export GPG_TTY
fi

#########
# Other #
#########

# fix locale issue when scp-ing to a server
export LC_ALL=en_US.UTF-8

# to get "new mail" notification in terminal
export MAIL="/var/mail/$USER"

# print one of my favorite quotes 1 out of 10 times
[ "$RANDOM" -lt 3277 ] && myquote
