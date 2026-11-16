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

### 2b. Tailscale, then the backup archives

The NAS is only reachable over Tailscale — it is not on the local network. So
Tailscale has to be installed and logged in before the keys archive can be
fetched at step 5.

```sh
brew install --cask tailscale-app synology-drive 1password
```

Sign in to Tailscale, confirm the NAS shows as `active` in its peer list, then
either let Synology Drive sync `mac-migration/` down, or pull the two files
straight from DSM in a browser. Expect it to be slow: the link is remote
(~300 ms RTT, ~80 KB/s), so the 55 MB work archive takes several minutes.

### 3. This repo, and the toolchain

```sh
git clone https://github.com/aborilov/dotfiles.git ~/dotfiles
cd ~/dotfiles
GOPATH="$HOME/work/go" brew bundle install --file=Brewfile
```

Set `GOPATH` on that command line. The Brewfile's 20 `go` entries run
`go install`, which honours `GOPATH` — but `.zshrc` is what normally sets it to
`~/work/go`, and `.zshrc` is not in place yet at this point. Without the
override, Go defaults to `~/go/bin` while `.zshrc` later puts `~/work/go/bin`
on `PATH`, so all 20 tools install successfully and then appear to be missing.

This step installs `gnupg` and `pinentry-mac`, which step 5 needs.

The Brewfile is a snapshot of one machine's accumulated state, not a curated
list — it installs ~70 formulae and 20 Go tools, many of which may no longer be
wanted. For a deliberately clean machine, skip `brew bundle` and install only
what you reach for:

```sh
brew install --cask ghostty 1password tailscale-app synology-drive
brew install git gnupg pinentry-mac neovim tmux ripgrep fzf jq gh \
             kubernetes-cli helm k9s go
```

The full Brewfile stays in the repo as a reference for what was once installed;
cherry-pick from it rather than replaying it wholesale.

### 4. Shell, then the configs

oh-my-zsh must exist *before* `.zshrc` lands, or every new shell errors on
startup — `.zshrc` sources `$ZSH/oh-my-zsh.sh` unconditionally.

```sh
git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
cd ~/dotfiles && ./bootstrap.sh         # rsyncs configs into ~; -f skips the prompt
```

Clone oh-my-zsh rather than running its install script. The installer replaces
`~/.zshrc` with its own template (backing yours up to `.zshrc.pre-oh-my-zsh`),
which silently undoes `bootstrap.sh` if run after it. A plain clone touches
nothing else. If you prefer the installer, pass `--keep-zshrc`.

`.zshrc` now guards both of its `source` lines, so landing it before oh-my-zsh
or `kube-ps1` exists prints a hint instead of an error on every shell.

**After this step, `git pull` in this repo needs your SSH key.** `.gitconfig`
carries `url."git@github.com:".insteadOf = https://github.com/`, so every
GitHub HTTPS URL is rewritten to SSH — including the HTTPS remote this repo was
cloned with. Until step 5 restores `~/.ssh`, git fails with
`Permission denied (publickey)`. To pull before then, bypass the global config
for one command:

```sh
GIT_CONFIG_GLOBAL=/dev/null git pull
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

#### If GPG says "No secret key" — disable keyboxd

The one part of a GnuPG migration that copying `~/.gnupg` does not survive.
Whether `keyboxd` is active is decided by the *new* install, not by what you
copied, so this happens even when both machines run the same GnuPG version.

Symptoms — the private keys are plainly there, yet GPG cannot see any of them:

```
gpg: skipped "0A43C5E87075BA0B": No secret key
gpg: [stdin]: clear-sign failed: No secret key
```

with `gpg --list-secret-keys` and `gpg --list-keys` both printing *nothing*,
while `ls ~/.gnupg/private-keys-v1.d` shows all six `.key` files.

The tell is files in `~/.gnupg` dated today rather than coming from the backup:

| Appeared | Meaning |
|---|---|
| `common.conf` (12 bytes = `use-keyboxd\n`) | keyboxd switched on |
| `public-keys.d/` | its SQLite store — empty |
| `S.keyboxd` | its socket |

`keyboxd` keeps public keys in `public-keys.d/pubring.db` and ignores
`pubring.kbx` altogether. The restored private keys are found, the matching
public keys are not, and GPG reports the whole key as missing.

Turn it off so GPG reads the restored `pubring.kbx`:

```sh
cat ~/.gnupg/common.conf                  # confirm it says use-keyboxd
gpgconf --kill all
mv ~/.gnupg/common.conf ~/.gnupg/common.conf.disabled
rm -rf ~/.gnupg/public-keys.d             # created fresh, holds nothing
gpgconf --kill all
gpg --list-secret-keys --keyid-format long
```

Deleting `public-keys.d` is safe: the real public keyring is the ~351 KB
`pubring.kbx` from the backup. If `common.conf` contains anything other than
`use-keyboxd`, edit out just that line instead of moving the file.

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

### 6b. zsh completion plugins

`.zshrc` enables these when present and silently skips them when not, so the
clones are optional — but they are the bulk of what makes the shell feel smart.

```sh
ZC="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$ZC/plugins/zsh-autosuggestions"
git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$ZC/plugins/zsh-syntax-highlighting"
exec zsh
```

- **zsh-autosuggestions** — greys in the rest of a command from history as you
  type; `ctrl-space` accepts it (bound in `.zshrc`), right-arrow accepts too.
- **zsh-syntax-highlighting** — colours the command line live, so a typo'd
  command shows red before you run it. Must load last; `.zshrc` appends it last.

Also active, from oh-my-zsh and fzf itself: `kubectl` and `helm` completions,
and fzf's `ctrl-R` fuzzy history / `ctrl-T` file picker / `alt-C` cd (wired via
`fzf --zsh` rather than the oh-my-zsh fzf plugin).

Note these clones use HTTPS, which `.gitconfig` rewrites to SSH — so they need
step 5 done first, or `GIT_CONFIG_GLOBAL=/dev/null` in front.

### 7. Fonts

`bootstrap.sh` puts the Inconsolata LGC Nerd Font into `~/.fonts`, which is a
Linux convention that macOS ignores. Copy them where macOS looks:

```sh
mkdir -p ~/Library/Fonts        # absent on a fresh account; cp fails without it
cp ~/.fonts/*.ttf ~/Library/Fonts/
```

Or `open ~/.fonts/*.ttf` to install them through Font Book, which creates the
folder itself.

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

## Backups: what lives on the NAS

A Synology NAS, reachable **only over Tailscale** — it is not on the local
network, so Tailscale must be connected before any of this works. Synology
Drive Client syncs the `home` share (remote `/`) two-way to `~/SynologyDrive/`.

`~/SynologyDrive/mac-migration/` holds the machine backups:

| File | What |
|---|---|
| `keys.tar.gz.gpg` | `~/.gnupg` + `~/.ssh`, AES256 under a passphrase kept in 1Password |
| `aws-config` | `~/.aws/config` — SSO profile definitions, no credentials |
| `uncommitted-work.tar.gz` | untracked files from `~/work` that exist on no remote |

### Refreshing them

```sh
cd ~/dotfiles && ./backup.sh          # or --keys-only
```

`backup.sh` encrypts the keys, copies the AWS profiles (refusing to if they
contain credentials), verifies the archive decrypts, then waits for Synology
Drive to confirm the upload rather than assuming a local write means an
uploaded file.

It stages into `~/.backup-staging` and moves the finished file in, because
writing straight into the sync folder lets the client read it mid-write —
that logs `Failed to read file … Operation timed out` and forces a retry.

### Setting sync up on a new machine

Connect Tailscale first and confirm the NAS is reachable, then in Synology
Drive Client add a sync task: remote `home` at `/`, local `~/SynologyDrive`,
two-way. The link is slow (~300 ms RTT, ~80 KB/s), so a 55 MB archive takes
several minutes and the full share takes hours — use selective sync if you
only want `mac-migration/`.

Check status without opening the app:

```sh
DB="$HOME/Library/Application Support/SynologyDrive/data/db"
sqlite3 "file:$DB/file-status.sqlite?mode=ro" "SELECT count(*) FROM fstatinfo;"   # 0 = idle
sqlite3 "file:$DB/history.sqlite?mode=ro" \
  "SELECT name, is_not_synced FROM history_table WHERE path LIKE '%mac-migration%';"
```

`is_not_synced = 0` means it reached the NAS. Local presence alone only proves
the file was queued.

**Before erasing a machine, quit Synology Drive Client.** The sync is two-way,
so wiping the disk with the client running replicates the deletion and takes
the backups with it.

## Verifying the restore

`./check.sh` audits everything this document sets up — oh-my-zsh, the Ghostty
config, fonts, all three GPG keys, keyboxd, SSH auth to GitHub, whether the
uncommitted-work archive was extracted, each CLI tool, and the logins. Run it
when you think you are finished; anything marked `--` is still outstanding.

```sh
cd ~/dotfiles && ./check.sh
```

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
