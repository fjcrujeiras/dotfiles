# vi: ft=zsh
##
# author: fjcrujeiras
##


export XDG_CONFIG_HOME="${HOME}/.config"
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_DOWNLOAD_DIR="${HOME}/cloud/downloads"
export XDG_DESKTOP_DIR="${HOME}/desktop"
export XDG_TEMPLATES_DIR="${HOME}/"
export XDG_PUBLICSHARE_DIR="${HOME}/shared/public"
export XDG_DOCUMENTS_DIR="${HOME}/cloud/documents"
export XDG_MUSIC_DIR="${HOME}/cloud/music"
export XDG_PICTURES_DIR="${HOME}/cloud/pictures"
export XDG_VIDEOS_DIR="${HOME}/cloud/videos"
export XDG_DATA_DIRS="/usr/local/share/:/usr/share/:/var/lib/snapd/desktop:/var/lib/flatpak/exports/share:${HOME}/.local/share/flatpak/exports/share"

## load ZSH module for function profiling
zmodload zsh/zprof


## ---------------------- Powerlvel10K instant Promt config ---------------#
# Keep these lines here
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi


# History file configuration, including fuzzy finding with FZF
HISTFILE=~/.histfile
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory # Save history between zsh sessions

setopt autocd extendedglob notify
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '~/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall


## ---------------------- Zinit ------------------------------#
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"
# As we are installing zinit after initializing compinit
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit


## --------------------- CUSTOM PLUGINS ----------------------#
ZSH="${HOME}/.zsh"
[ ! -d $ZSH ] && mkdir -p "$(dirname $ZSH)"
[ ! -d ${ZSH}/plugins ] && mkdir -p "$(dirname $ZSH/plugins)"
[ ! -d ${ZSH}/themes ] && mkdir -p "$(dirname $ZSH/themes)"

## Powerlevel10K ---------------------------------------------
[ ! -d $ZSH/themes/powerlevel10k/.git ] && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH"/themes/powerlevel10k
source "${ZSH}/themes/powerlevel10k/powerlevel10k.zsh-theme"
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

## OMZ Git Plugin --------------------------------------------
[ ! -d $ZSH/plugins/git ] && mkdir $ZSH/plugins/git && curl https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/git/git.plugin.zsh -o $ZSH/plugins/git/git.plugin.zsh
source "${ZSH}/plugins/git/git.plugin.zsh"

## Fast Syntax Highligthing ----------------------------------
[ ! -d $ZSH/plugins/fast-syntax-highlighting/.git ] && git clone https://github.com/zdharma-zmirror/fast-syntax-highlighting.git "$ZSH"/plugins/fast-syntax-highlighting
source "${ZSH}/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"

## ZSH Auto Suggestions --------------------------------------
[ ! -d $ZSH/plugins/zsh-autosuggestions/.git ] && git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH"/plugins/zsh-autosuggestions
source "${ZSH}/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"

## ZSH Completions -------------------------------------------
[ ! -d $ZSH/plugins/zsh-completions/.git ] && git clone https://github.com/zsh-users/zsh-completions.git "$ZSH"/plugins/zsh-completions
#source "${ZSH}/plugins/zsh-completions/zsh-completions.plugin.zsh"
fpath=($ZSH/plugins/zsh-completions/src $fpath)

## ZSH History Substring search ------------------------------
[ ! -d $ZSH/plugins/zsh-history-substring-search/.git ] && git clone https://github.com/zsh-users/zsh-history-substring-search.git "$ZSH"/plugins/zsh-history-substring-search
source "${ZSH}/plugins/zsh-history-substring-search/zsh-history-substring-search.plugin.zsh"
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

## FZF History -----------------------------------------------
[ ! -d $ZSH/plugins/zsh-fzf-history-search/.git ] && git clone https://github.com/joshskidmore/zsh-fzf-history-search.git "$ZSH"/plugins/zsh-fzf-history-search
source "${ZSH}/plugins/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh"


# ---------------------- USER SETTINGS ---------------------- #
# FZF
source <(fzf --zsh)
export FZF_DEFAULT_COMMAND='fd --hidden --color=always --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type=d --hidden --color=always --strip-cwd-prefix --exclude .git'
export FZF_DEFAULT_OPTS="--ansi"

# Environment variables
export EDITOR=nvim
export KUBE_EDITOR=nvim
export GPG_TTY=$TTY
gpgconf --launch gpg-agent
# export GPG_TTY=$(tty) # Needed for singing commits

# Kubectl completion
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
alias k="kubectl"
compdef __start_kubectl k

# GOROOT/GOPATH

export GOROOT=/opt/go
export GOPATH=${HOME}/.go

export PATH=$GOROOT/bin:$GOPATH/bin:$PATH

# Gcloud completion
source $HOME/.local/google-cloud-sdk/completion.zsh.inc

# ASDF
. $HOME/.asdf/asdf.sh
#. $HOME/.asdf/completions/asdf.bash

# kubectx and kubens
export PATH=$HOME/.kubectx:$HOME/.local/bin:$PATH:

export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
alias kubectx=kubectl-ctx
alias kubens=kubectl-ns


# Direnv
eval "$(direnv hook zsh)"

# Zoxide
if ! type "zoxide" > /dev/null ; then
  curl -sSfL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | sh
fi
eval "$(zoxide init --cmd cd zsh)"

# ---------------------- ALIASES ---------------------- #
alias l="ll"
alias ll="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias gen-toc='docker run -v $(pwd)":/app" -w /app --rm -it sebdah/markdown-toc'
alias dockc='docker ps -a | grep -v "IMAGE" | fzf --preview "docker inspect {1} | bat --color=always --language=json"'

# ---------------------- CUSTOM FUNCTIONS ------------- #
# cd into dir and list
cx() { cd "$@" && l; }

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C $HOME/.local/bin/terragrunt terragrunt


# Thanks to Raynix
# source: https://raynix.info/archives/4592
# kds = kubernetes decode secret
function kds() {
  # list all secret names in current namespace and select 1 using fzf
  secret=$(kubectl get secrets -o name| fzf)
  secret_cache=/tmp/kds_cache
  # cache the selected secret's content
  kubectl get $secret -o yaml > $secret_cache
  # list all keys in the secret and select 1 using fzf
  secret_key=$(cat $secret_cache | yq '.data|keys' |sed 's|^- ||g'|fzf)
  # print out the selected key and decode its value
  cat $secret_cache |yq ".data.\"$secret_key\"" |base64 -d
  rm $secret_cache
}

function encStr() {
  echo "$@" | base64 -w 0
}


# Recieves the ID of a Podcast in Apple podcast and returns the RSS feed
function getPodcastFeed() {
  curl -s "https://itunes.apple.com/lookup?media=podcast&id=$1" | jq '.results|.[]|.feedUrl' | tr '"' ' '
}
