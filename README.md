# dotfiles-migration

Laptop OS swap: Omarchy 4 -> Serpentium shell, Arch or CachyOS.

## What this does

`install.sh` covers Tailscale, Claude Code, Syncthing, Obsidian, LazyVim —
then runs `claude` on the new box and hands it Chrome + VSCode setup.

## Use

```
git clone <this-repo-url> ~/dotfiles-migration
cd ~/dotfiles-migration
./install.sh
```

## Deliberately excluded (never committed here)

- `~/.claude/.credentials.json` — session token, re-auth with `claude` login.
- Syncthing `cert.pem` / `key.pem` / `config.xml` — private key + API key.
  Transfer these over Tailscale directly between machines (see install.sh
  output), never through git, even a private repo.

## Before pushing to GitHub

Double check `configs/claude/settings.local.json` and `settings.json` don't
carry anything sensitive if you ever flip this repo public — they were clean
at time of writing (no apiKey/token/secret/password fields found).
