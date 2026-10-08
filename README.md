# dotfiles

Personal configuration for macOS. Public repo — **no secrets, keys, or tokens belong here.**

## Setting up a new Mac

See **[RESTORE.md](RESTORE.md)** for the full procedure, in order.

The short version:

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# install 1Password and sign in with the Emergency Kit first

git clone https://github.com/aborilov/dotfiles.git ~/dotfiles
cd ~/dotfiles
brew bundle install --file=Brewfile
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
./bootstrap.sh
```

Then restore GPG and SSH keys from the encrypted archive, install the vim /
nvim / tmux plugin managers, and log back into the CLI tools — all covered in
[RESTORE.md](RESTORE.md).

`bootstrap.sh` rsyncs the live configs into `~`. It excludes `legacy/`,
`Brewfile`, the two markdown files and `.git/`.

## What's in here

| Path | What |
|---|---|
| `Brewfile` | Homebrew taps, formulae, casks, Go tools, npm globals |
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
| `legacy/` | Old Linux desktop + mutt/offlineimap/mcabber mail setup. Reference only; `bootstrap.sh` does **not** copy it. |

## Not in here

Private keys, OAuth tokens, and `~/.ssh` / `~/.gnupg` are kept out of this repo
by design. [RESTORE.md](RESTORE.md) lists where each one actually comes from and
which are simply re-minted by a `login` command.
