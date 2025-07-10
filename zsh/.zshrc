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
ZINIT_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/zinit/zinit.git"
if [[ ! -d "$ZINIT_HOME/.git" ]]; then
    mkdir -p "$(dirname "$ZINIT_HOME")"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi
source "${ZINIT_HOME}/zinit.zsh"
# As we are installing zinit after initializing compinit
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit


### Zinit plugins ###
# By using zinit, we avoid running git/curl/mkdir on every shell startup.
# zinit handles installation and updates cleanly.

# Theme (must be loaded before the p10k config file)
zinit light romkatv/powerlevel10k
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Core Functionality
zinit light zdharma-zmirror/fast-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Tools & Integrations
zinit light junegunn/fzf # Manages fzf's keybindings and completions
zinit light joshskidmore/zsh-fzf-history-search
zinit light ajeetdsouza/zoxide # Manages zoxide, replaces manual install and eval

# Completions
zinit light zsh-users/zsh-completions # Adds many more completions
zinit ice lucid wait'0' blockf
zinit snippet OMZ::plugins/kubectl/kubectl.plugin.zsh

# Git aliases from Oh My Zsh
zinit snippet OMZ::plugins/git/git.plugin.zsh

# ---------------------- USER SETTINGS ---------------------- #
# FZF
export FZF_DEFAULT_COMMAND='fd --hidden --color=always --strip-cwd-prefix --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type=d --hidden --color=always --strip-cwd-prefix --exclude .git'
export FZF_DEFAULT_OPTS="--ansi"

# Environment variables
export EDITOR=nvim
export KUBE_EDITOR=nvim
export GPG_TTY=$TTY
# Launch gpg-agent if not running. `gpgconf` is idempotent.
gpgconf --launch gpg-agent >/dev/null 2>&1

# GOROOT/GOPATH
export GOROOT=/opt/go
export GOPATH=${HOME}/.go

# Gcloud completion
source $HOME/.local/google-cloud-sdk/completion.zsh.inc

# ASDF
. $HOME/.asdf/asdf.sh
#. $HOME/.asdf/completions/asdf.bash
export USE_GKE_GCLOUD_AUTH_PLUGIN=True

# Krew uses KREW_ROOT, so we export it. Its path is handled below.
export KREW_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/krew"

# bun
export BUN_INSTALL="$HOME/.bun"

# Centralized PATH management
# `typeset -U path` creates a unique array, preventing duplicate entries.
typeset -U path
path=(
    # User binaries take precedence
    "$BUN_INSTALL/bin"
    "$KREW_ROOT/bin"
    "$HOME/.kubectx"
    "$HOME/.local/bin"
    "$HOME/zig"
    "$GOPATH/bin"
    "$GOROOT/bin"
    # Original system path
    $path
    # Appended paths
    "$HOME/.spicetify"
)

# Kubectl Aliases
# The 'k' alias and its completion are handled by the OMZ kubectl plugin loaded via zinit above.
alias kubectx=kubectl-ctx
alias kubens=kubectl-ns

# Direnv
eval "$(direnv hook zsh)"

# Zoxide
eval "$(zoxide init zsh)"

# ---------------------- ALIASES ---------------------- #
alias l="ll"
alias ll="eza -l --icons --git -a --hyperlink"
alias lt="eza --tree --level=2 --long --icons --git --hyperlink"
alias gen-toc='docker run -v $(pwd)":/app" -w /app --rm -it sebdah/markdown-toc'
alias dockc='docker ps -a | grep -v "IMAGE" | fzf --preview "docker inspect {1} | bat --color=always --language=json"'

# ---------------------- CUSTOM FUNCTIONS ------------- #
# cd into dir and list
cx() { cd "$@" && l; }

# Terragrunt bash completion
autoload -U bashcompinit && bashcompinit
if (( $+commands[terragrunt] )); then
  complete -o nospace -C "$(command -v terragrunt)" terragrunt
fi

# Thanks to Raynix
# source: https://raynix.info/archives/4592
# kds = kubernetes decode secret
function kds() {
  local secret
  # list all secret names in current namespace and select 1 using fzf
  secret=$(kubectl get secrets -o name | fzf)
  [[ -z "$secret" ]] && return 1 # Exit if no secret was selected

  local secret_cache
  secret_cache=$(mktemp)
  # Ensure the temp file is removed when the function returns
  trap "rm -f $secret_cache" RETURN

  # cache the selected secret's content
  kubectl get "$secret" -o yaml > "$secret_cache"
  # list all keys in the secret and select 1 using fzf
  local secret_key
  secret_key=$(yq '.data | keys | .[]' "$secret_cache" | fzf)
  # print out the selected key and decode its value
  if [[ -n "$secret_key" ]]; then
    yq ".data.\"$secret_key\"" "$secret_cache" | base64 -d
  fi
}

function encStr() {
  echo "$@" | base64 -w 0
}


# Recieves the ID of a Podcast in Apple podcast and returns the RSS feed
function getPodcastFeed() {
  curl -s "https://itunes.apple.com/lookup?media=podcast&id=$1" | jq '.results|.[]|.feedUrl' | tr '"' ' '
}

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
