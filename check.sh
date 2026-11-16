#!/usr/bin/env bash
ok(){ printf '  \033[32mOK\033[0m   %s\n' "$1"; }
no(){ printf '  \033[31m--\033[0m   %s\n' "$1"; }
t(){ if eval "$2" >/dev/null 2>&1; then ok "$1"; else no "$1"; fi; }

echo "— core —"
t "oh-my-zsh installed"        '[ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]'
t ".zshrc guarded (no hard error)" 'grep -q "if \[ -f \"\$ZSH/oh-my-zsh.sh\" \]" "$HOME/.zshrc"'
t "ghostty config in place"    '[ -f "$HOME/.config/ghostty/config" ]'
t "fonts registered"           'ls "$HOME/Library/Fonts/"*.ttf'
t "kube-ps1 installed"         '[ -f /opt/homebrew/opt/kube-ps1/share/kube-ps1.sh ]'
t "zsh-autosuggestions"        '[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]'
t "zsh-syntax-highlighting"    '[ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]'

echo "— keys —"
t "3 GPG secret keys"          '[ "$(gpg --list-secret-keys --with-colons 2>/dev/null | grep -c ^sec)" = 3 ]'
t "git signing key present"    'gpg --list-secret-keys 0A43C5E87075BA0B'
t "keyboxd not hijacking"      '[ ! -f "$HOME/.gnupg/common.conf" ]'
t "ssh key present"            '[ -f "$HOME/.ssh/id_rsa" ]'
t "ssh config has github-ardan" 'grep -qi "github-ardan" "$HOME/.ssh/config"'
t "GitHub SSH auth"            'ssh -o StrictHostKeyChecking=no -T git@github.com 2>&1 | grep -q "successfully authenticated"'

echo "— repo —"
t "dotfiles clone"             '[ -d "$HOME/dotfiles/.git" ]'
t "dotfiles up to date"        'cd "$HOME/dotfiles" && git fetch -q 2>/dev/null; [ -z "$(cd "$HOME/dotfiles" && git log HEAD..@{u} --oneline 2>/dev/null)" ]'
t "uncommitted work restored"  '[ -e "$HOME/work/tradingview/optimal_strategy_v1.18.pine" ]'

echo "— tools —"
for c in nvim tmux rg fzf jq gh kubectl helm k9s go; do t "$c" "command -v $c"; done

echo "— logins —"
t "gh authenticated"           'gh auth status'
t "aws configured"             '[ -f "$HOME/.aws/config" ]'
t "docker logged in"           'grep -q auths "$HOME/.docker/config.json"'
