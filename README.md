# dotfiles

Personal configuration for macOS. Public repo — **no secrets, keys, or tokens belong here.**

## Restore on a new Mac

```sh
# 1. Xcode CLI tools + Homebrew
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. This repo
git clone https://github.com/aborilov/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 3. All CLI tools and apps
brew bundle install --file=Brewfile

# 4. oh-my-zsh (must exist before .zshrc is copied, or the shell errors on startup)
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# 5. Copy the configs into ~
./bootstrap.sh          # prompts; use -f to skip the prompt
```

### Then, manually

- **Vim plugins** — `.vimrc` uses Vundle:
  `git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim && vim +PluginInstall +qall`
- **Neovim plugins** — `.config/nvim` uses packer; open `nvim` and run `:PackerSync`.
- **tmux plugins** — `.tmux.conf` uses tpm:
  `git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm`, then `prefix + I` inside tmux.
- **Fonts** — the `.fonts/` TTFs land in `~/.fonts`; on macOS also copy them to `~/Library/Fonts` so apps see them.
- **GPG signing** — `.gitconfig` sets `commit.gpgsign = true` with key `0A43C5E87075BA0B`. Import that secret key from your backup or commits will fail. (`gpg --import`, then `gpg --list-secret-keys`.)
- **SSH** — `~/.ssh/config` and keys are deliberately *not* in this repo. `.gitconfig` rewrites
  `https://github.com/ardanlabs/` to `git@github-ardan.com:`, which needs a matching `Host github-ardan.com`
  entry in your `~/.ssh/config`.

## What's in here

| Path | What |
|---|---|
| `Brewfile` | Homebrew formulae, casks, taps, Go tools, npm globals |
| `.zshrc`, `.zshenv` | zsh + oh-my-zsh (agnoster theme, kube-ps1 prompt) |
| `.vimrc` | vim (Vundle) |
| `.config/nvim/` | neovim (packer) |
| `.tmux.conf`, `.tmuxline.conf` | tmux + airline-matched statusline |
| `.gitconfig`, `.gitignore` | git config; `.gitignore` is the global `core.excludesfile` |
| `.config/git/ignore` | XDG global git excludes |
| `.config/alacritty/` | Alacritty terminal |
| `.config/k9s/` | k9s config, aliases, skin |
| `.config/helm/repositories.yaml` | helm chart repos |
| `.config/herdr/config.toml` | herdr keybindings |
| `.fonts/` | Inconsolata LGC Nerd Font (powerline) |
| `legacy/` | Old Linux desktop + mutt/offlineimap/mcabber mail setup. Kept for reference only; `bootstrap.sh` does **not** copy it. |

## Deliberately excluded

Credentials and machine state — restore these from your password manager or backups, never from git:

`~/.ssh/` · `~/.aws/` · `~/.kube/config` · `~/.netrc` · `~/.gnupg/` · `~/.config/gh/hosts.yml` ·
`~/.config/gcloud/` · `~/.claude.json` and the `~/.claude*/` profile dirs · `~/.sentryclirc` ·
shell/psql/redis history files
