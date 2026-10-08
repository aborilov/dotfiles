#!/usr/bin/env bash
# Install these dotfiles into $HOME.
#
#   ./bootstrap.sh          link configs, install plugin managers
#   ./bootstrap.sh --force  also overwrite existing Claude Code settings/hooks
#
# Plain config files are symlinked, so edits on the machine land in the repo.
# Anything already in the way is moved to ~/.dotfiles-backup/<timestamp>/.
# Claude Code settings are copied instead of linked: Claude rewrites
# settings.json itself (e.g. /model), which would replace a symlink anyway.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
FORCE=0
[[ "${1:-}" == "--force" || "${1:-}" == "-f" ]] && FORCE=1

LINKS=(
	.zshrc
	.zshenv
	.vimrc
	.tmux.conf
	.tmuxline.conf
	.gitconfig
	.gitignore
	.Xdefaults
	.config/nvim
	.config/alacritty
	.config/herdr/config.toml
	.config/k9s/aliases.yaml
	.agents/hooks/herdr-load-skill.sh
	bin/claude-akuity
)

# Copied once (or on --force); see header.
COPIES=(
	.claude/settings.json
	.claude/hooks/herdr-agent-state.sh
	.claude-akuity/settings.json
	.claude-akuity/hooks/herdr-agent-state.sh
)

backup() {
	mkdir -p "$BACKUP/$(dirname "$1")"
	mv "$HOME/$1" "$BACKUP/$1"
	echo "  backed up ~/$1"
}

link() {
	local src="$DOTFILES/$1" dst="$HOME/$1"
	[[ "$(readlink "$dst" 2>/dev/null)" == "$src" ]] && return
	mkdir -p "$(dirname "$dst")"
	[[ -e "$dst" || -L "$dst" ]] && backup "$1"
	ln -s "$src" "$dst"
	echo "  linked  ~/$1"
}

copy() {
	local src="$DOTFILES/$1" dst="$HOME/$1"
	if [[ -e "$dst" ]]; then
		[[ $FORCE == 1 ]] || { echo "  kept    ~/$1 (exists; --force to replace)"; return; }
		cmp -s "$src" "$dst" && return
		backup "$1"
	fi
	mkdir -p "$(dirname "$dst")"
	cp -p "$src" "$dst"
	echo "  copied  ~/$1"
}

echo "==> Linking configs"
for f in "${LINKS[@]}"; do link "$f"; done

echo "==> Claude Code settings"
for f in "${COPIES[@]}"; do copy "$f"; done
chmod 700 "$HOME/.claude-akuity"

echo "==> Plugin managers"
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
	ZSH="$HOME/.oh-my-zsh" RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh -c \
		"$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
	git clone --depth 1 https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
fi
"$HOME/.tmux/plugins/tpm/bin/install_plugins" >/dev/null || true
if [[ ! -d "$HOME/.vim/bundle/Vundle.vim" ]]; then
	git clone --depth 1 https://github.com/VundleVim/Vundle.vim "$HOME/.vim/bundle/Vundle.vim"
fi
mkdir -p "$HOME/.vim/backups"
vim -E -s -u "$HOME/.vimrc" +PluginInstall +qall </dev/null || true

if ls "$DOTFILES"/.fonts/*.ttf >/dev/null 2>&1; then
	echo "==> Fonts"
	FONTDIR="$HOME/.local/share/fonts"
	[[ "$(uname)" == Darwin ]] && FONTDIR="$HOME/Library/Fonts"
	mkdir -p "$FONTDIR" && cp -n "$DOTFILES"/.fonts/*.ttf "$FONTDIR"/
	command -v fc-cache >/dev/null && fc-cache -f >/dev/null
fi

cat <<'EOF'

Done. Remaining manual steps (see README.md):
  - chsh -s "$(command -v zsh)"
  - herdr integration install claude      # refresh herdr hooks
  - reinstall ~/.agents/skills with `npx skills` (herdrdev/herdr, vercel-labs/skills find-skills)
  - import your GPG key (commits are signed with 70CF28EB88BDB071)
  - gh auth login (both accounts), gh config set -h github.com git_protocol https
  - copy ~/.claude/CLAUDE.md privately (not in this public repo)
EOF
