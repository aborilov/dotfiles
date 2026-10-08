aborilov dotfiles — Linux server (`linux` branch)
==============================================

zsh (oh-my-zsh), vim, tmux, git, nvim, alacritty, herdr, k9s and Claude Code settings.

This branch is the Linux dev server setup. The Mac setup lives on `master`;
the two branches are kept separate on purpose.

## New machine

Prerequisites: `git zsh tmux curl` (and `gh`, `herdr`, `claude` if you use them).

```sh
git clone -b linux https://github.com/aborilov/dotfiles.git ~/dotfiles
~/dotfiles/bootstrap.sh
```

`bootstrap.sh` is idempotent. It symlinks the configs into `$HOME` (anything in
the way goes to `~/.dotfiles-backup/<timestamp>/`), copies Claude Code
settings/hooks if missing (`--force` replaces them), and installs oh-my-zsh,
tpm + tmux plugins, Neovim 0.11+ (into `~/.local` if missing or older) and
packer + nvim plugins.

Then, by hand:

- `chsh -s "$(command -v zsh)"`
- `herdr integration install claude` — refreshes the herdr state hook
- skills in `~/.agents/skills` come from `npx skills`: `herdr` (herdrdev/herdr)
  and `find-skills` (vercel-labs/skills); link them into each Claude profile's
  `skills/`
- import the GPG signing key (`70CF28EB88BDB071`) — `commit.gpgsign` is on
- `gh auth login` for each account, and
  `gh config set -h github.com git_protocol https`

## Deliberately not in this repo

It's public, so these move between machines some other way:

- `~/.claude/CLAUDE.md` (global agent instructions — account/org details)
- anything with credentials: `~/.ssh`, `~/.gnupg`, `~/.aws`, `~/.kube`,
  `~/.config/gcloud`, `~/.config/gh`, `.credentials.json`, `.npmrc`
- other Claude Code profiles besides `~/.claude` and `~/.claude-akuity`

## Legacy

`.mutt*`, `.offlineimaprc`, `.msmtprc`, `.mcabber`, `.pentadactyl*`,
`.config/{qtile,uzbl,mopidy}` are old and not installed by `bootstrap.sh`.
