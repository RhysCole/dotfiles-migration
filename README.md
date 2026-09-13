# dotfiles-migration

Laptop OS swap: Omarchy 4 -> Serpentium shell, Arch or CachyOS.

## What this does

`install.sh` covers Tailscale, Claude Code, Syncthing, Obsidian, LazyVim —
then runs `claude` on the new box and hands it Chrome + VSCode setup.

## Use

On the new machine, once base OS + git are up:

```
git clone https://github.com/RhysCole/dotfiles-migration.git ~/dotfiles-migration
cd ~/dotfiles-migration
./install.sh
```

Order of operations, and where it needs you:

1. `pacman -Syu`.
2. Tailscale install + `tailscale up` — opens an auth URL, approve it in the
   browser.
3. Claude Code install + config restore. Run `claude` once after — it'll
   prompt login since credentials aren't in this repo on purpose.
4. Syncthing install/enable — then **stop before it syncs for real**. It
   prints an `scp` command to pull `cert.pem` / `key.pem` / `config.xml`
   straight from the old laptop over Tailscale (both machines need to show
   in `tailscale status` first). Do this before starting the service, or
   Syncthing treats the new box as a stranger device.
5. Obsidian install — point it at the vault once Syncthing has caught up.
6. Neovim + LazyVim config restore. Run `nvim` once so `lazy.nvim` pulls
   plugins from the committed lock file.
7. Last step auto-runs `claude` with a prompt to install and configure
   Chrome + VSCode — answer whatever it asks.

## Deliberately excluded (never committed here)

- `~/.claude/.credentials.json` — session token, re-auth with `claude` login.
- Syncthing `cert.pem` / `key.pem` / `config.xml` — private key + API key.
  Transfer these over Tailscale directly between machines (see install.sh
  output), never through git, even a private repo.

## Before pushing to GitHub

Double check `configs/claude/settings.local.json` and `settings.json` don't
carry anything sensitive if you ever flip this repo public — they were clean
at time of writing (no apiKey/token/secret/password fields found).
