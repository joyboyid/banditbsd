if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export PATH="$PATH:$HOME/.spicetify:$HOME/.local/bin"
export EDITOR="nvim"
export VISUAL="st -e nvim"
export XDG_DATA_DIRS="$XDG_DATA_DIRS:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"
export PKG_CONFIG_PATH="/usr/local/lib64/pkgconfig:$PKG_CONFIG_PATH"
export LD_LIBRARY_PATH="/usr/local/lib64:$LD_LIBRARY_PATH"
export BAT_THEME=base16

HISTSIZE=2000
SAVEHIST=2000
HISTFILE=~/.zsh_history

if command -v eza > /dev/null; then
    alias ls="eza --icons=always --group-directories-first"
    alias la="eza -ha --icons=always --group-directories-first"
    alias ll="eza -lha --icons=always --group-directories-first"
    alias lt="eza --icons=always --tree --level=1"
fi

alias cat="bat"
alias v="nvim"
alias c="clear"
alias cd="z"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}

autoload -Uz compinit && compinit -d ~/.zcompdump
export FZF_DEFAULT_OPTS=" \
--color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7 \
--color=fg+:#c0caf5,bg+:#24283b,hl+:#7dcfff \
--color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff \
--color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a"

zstyle ':fzf-tab:complete:*' fzf-preview \
  'if [ -d $realpath ]; then
      eza --tree --level=2 --icons --color=always $realpath
   else
      bat --color=always --style=numbers --line-range :500 $realpath 2>/dev/null || command cat $realpath
   fi'

eval "$(zoxide init zsh)"

source ~/.config/zsh_plugins/zsh-fzf-tab/fzf-tab.plugin.zsh
source ~/.config/zsh_plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/zsh_plugins/zsh-history-substring-search/zsh-history-substring-search.zsh
source ~/.config/zsh_plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down
bindkey '^[[3~' delete-char

bindkey -M viins '^[[3~' delete-char
bindkey -M vicmd '^[[3~' delete-char

source ~/.config/zsh_plugins/powerlevel10k/powerlevel10k.zsh-theme

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
