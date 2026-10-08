# Restoring on a new Mac

The environment is deliberately split into three pieces. Only the first is in
this repo.

| Piece | Where it lives | Size |
|---|---|---|
| Configs + package list | this repo (public) | — |
| GPG + SSH private keys | encrypted archive on the NAS and a USB stick | ~360 KB |
| Everything else | 1Password, or re-minted by a `login` command | — |

Nothing else is backed up, on purpose: every other credential on a dev Mac is
an OAuth token that a login regenerates. See
[Deliberately not backed up](#deliberately-not-backed-up).

## Order matters

1Password comes first — it is the root of trust that every later step depends
on. The keys archive comes *after* Homebrew, because decrypting it needs
`gnupg` and `pinentry-mac`.

### 1. Base system

```sh
xcode-select --install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. 1Password

Install it and sign in using the Emergency Kit (account password + Secret
Key). The keys-archive passphrase and its location are recorded there, as is
everything in the re-login table below. Until this works, nothing else can
proceed.

### 3. This repo, and the toolchain

```sh
git clone https://github.com/aborilov/dotfiles.git ~/dotfiles
cd ~/dotfiles
brew bundle install --file=Brewfile     # installs gnupg + pinentry-mac, needed next
```

### 4. Shell, then the configs

oh-my-zsh must exist *before* `.zshrc` lands, or every new shell errors on
startup — `.zshrc` sources `$ZSH/oh-my-zsh.sh` unconditionally.

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
cd ~/dotfiles && ./bootstrap.sh         # rsyncs configs into ~; -f skips the prompt
```

`bootstrap.sh` copies only live config. It excludes `legacy/`, `Brewfile`,
`README.md`, `RESTORE.md` and `.git/`.

### 5. GPG and SSH keys

Get `keys.tar.gz.gpg` from the NAS or the USB stick, then:

```sh
gpg --decrypt /path/to/keys.tar.gz.gpg | tar -xzf - -C ~

# GPG and SSH both refuse to use a directory with loose permissions
chmod 700 ~/.gnupg ~/.ssh
find ~/.gnupg ~/.ssh -type d -exec chmod 700 {} \;
find ~/.gnupg ~/.ssh -type f -exec chmod 600 {} \;
gpgconf --kill all
```

Verify both. `.gitconfig` sets `commit.gpgsign = true`, so a broken keyring
means every `git commit` fails:

```sh
gpg --list-secret-keys --keyid-format long
echo test | gpg --clearsign -u 0A43C5E87075BA0B   # the git signing key
ssh -T git@github.com
```

### 6. Editor and tmux plugins

Plugin managers are not vendored; each bootstraps its own plugins.

```sh
# vim (Vundle)
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# neovim (packer) — then run :PackerSync inside nvim
git clone --depth 1 https://github.com/wbthomason/packer.nvim \
  ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# tmux (tpm) — then press prefix + I inside tmux
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

`.config/nvim/plugin/packer_compiled.lua` is generated, and has absolute
`/Users/aborilov/...` paths baked into it. `:PackerSync` rewrites it, so run
that before worrying about it — and note it will break outright if the new
machine uses a different username.

### 7. Fonts

`bootstrap.sh` puts the Inconsolata LGC Nerd Font into `~/.fonts`, which is a
Linux convention that macOS ignores. Copy them where macOS looks:

```sh
cp ~/.fonts/*.ttf ~/Library/Fonts/
```

### 8. Log back in

Each of these re-mints its own credentials; none are backed up.

| Tool | Command |
|---|---|
| GitHub CLI | `gh auth login` |
| AWS (44 of 45 profiles are SSO) | `aws sso login --profile <name>` |
| Google Cloud | `gcloud auth login` |
| Docker | `docker login` |
| 1Password CLI | `op signin` |
| buf.build | `buf registry login` |
| Claude Code | `claude` then follow the prompt |
| kubeconfig | re-fetch per cluster from the provider |

## Deliberately not backed up

Anything recoverable is left out, to keep the irreplaceable part small enough
to verify by eye:

- **OAuth tokens** — `~/.config/gh`, `~/.config/gcloud`, `~/.config/op`,
  `~/.akuity`, `~/.claude.json`, `~/.docker/config.json`, `~/.netrc`. All
  re-minted by the logins above.
- **AWS credentials** — `~/.aws` is almost entirely SSO profiles. The one
  long-lived access key is rotatable from the AWS console.
- **`~/.kube/config`** — regenerated per cluster. (The directory around it is
  ~5 GB of cache, which is why the whole thing is skipped.)
- **Caches** — `~/.docker` (scout/sbom, ~3 GB), `~/.kube/cache`,
  `~/.terraform.d`, `~/.pulumi`.
- **Git repositories** — everything under `~/work` is on a remote. Local
  branches that look unpushed are overwhelmingly stale review and feature
  branches already merged upstream; check `git log --branches --not --remotes`
  before assuming otherwise.
- **Secrets of any kind in this repo.** It is public.

## Re-making the keys archive

The archive is just a tarball of two directories, encrypted with a passphrase.
The pipe matters — the plaintext tarball never touches disk.

```sh
cd ~ && tar --exclude='S.*' --exclude='.#lk*' --exclude='random_seed' \
    --exclude='pubring.kbx~' --exclude='known_hosts.old' --exclude='.ssh/agent' \
    -czf - .gnupg .ssh \
  | gpg --symmetric --cipher-algo AES256 -o /path/to/keys.tar.gz.gpg
```

This is both directories in full. The excludes only drop things that cannot or
should not travel between machines:

| Excluded | Why |
|---|---|
| `S.*`, `.ssh/agent` | unix sockets — `tar` cannot archive them at all, and `gpg-agent`/`ssh-agent` recreate them on launch |
| `.#lk*` | stale lock files (37 of them, from retired machines) |
| `random_seed` | RNG state; copying it to another machine is discouraged |
| `pubring.kbx~`, `known_hosts.old` | backup copies of files that *are* included |

Everything else goes in: all secret keys and subkeys, `pubring.kbx`,
`trustdb.gpg`, the revocation certificate, `gpg.conf`, `gpg-agent.conf`,
`dirmngr.conf`, and the whole of `~/.ssh` bar the socket directory. Omitting
`--exclude='.ssh/agent'` makes `tar` emit `pax format cannot archive sockets`
errors.

Write the archive outside the sync folder and move it in afterwards. Writing
it directly into a Synology Drive folder lets the sync client read the file
while `gpg` is still streaming into it, which logs `Failed to read file …
Operation timed out` and forces a retry. It recovers on its own, but the failed
first attempt in the log is alarming and easy to misread as a lost backup.

Always confirm it opens before relying on it:

```sh
gpg --decrypt /path/to/keys.tar.gz.gpg | tar -tzf -
```

Expect `.gnupg/private-keys-v1.d/` to contain one `.key` file per secret key
and subkey, plus `.ssh/id_rsa`.

Keep two copies in different places. If a sync client holds one of them, quit
the client before erasing the machine — two-way sync will happily replicate the
deletion of your only backup.
