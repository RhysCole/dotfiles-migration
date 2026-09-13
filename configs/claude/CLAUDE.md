# CLAUDE.md — global

Applies to every session. Keep this file lean: it loads into context on every
single session, so anything here is a permanent per-session token cost. Detail
that isn't needed *every* time belongs in the vault (`Memory/`), not here.

---

## Response style

- Terse. Answer first, no preamble, no closing summary, no restating the question.
- Explain reasoning only when the call is non-obvious — a tradeoff, a surprising
  cause, a choice between two viable approaches. Not for routine steps.
- No praise, no filler transitions, no "great question".
- Code and commands over prose descriptions of code and commands.
- Say "I don't know" or "this needs verifying" rather than producing a
  plausible guess. Flag uncertainty inline, don't bury it in caveats.
- Push back on bad approaches directly. Don't soften it into a suggestion.

---

## Environment

**Laptop** — Omarchy / Arch Linux. Tailscale `100.75.40.13`.
**Pi** — `rcpi`, user `rhys`, Pi OS Lite (Debian, aarch64). Tailscale
`100.100.173.4`, MagicDNS `rcpi.tailc6ce43.ts.net`. Always on.

All inter-device networking goes over Tailscale. Never suggest port forwarding,
public exposure, or ngrok-style tunnels.

**Languages**: Python, JavaScript/React. Learning Go — assume intermediate
elsewhere, beginner in Go, and explain Go idioms rather than assuming them.

### Services on the Pi

| Unit | What it does |
|---|---|
| `mcp-obsidian` | MCP server, `~/mcp-obsidian-server/server.py`, binds `0.0.0.0:8001` |
| `tailscale-serve` | HTTPS proxy → `https://rcpi.tailc6ce43.ts.net/` → `127.0.0.1:8001` |
| `syncthing@rhys` | Syncs vault + `~/claude-shared` to laptop |

Vault: `/home/rhys/obsidian-vault` (override via `OBSIDIAN_VAULT_PATH`).
Server venv: `~/mcp-obsidian-server/.venv`. Restart: `sudo systemctl restart mcp-obsidian`.

---

## Obsidian vault

MCP server `obsidian-vault` exposes: `test`, `search_notes`, `read_note`,
`list_notes_by_topic`, `note_exists`, `check_duplicate`, `find_related_notes`,
`write_note`.

**Write to the vault automatically. Do not ask for permission first.** Report
what was written afterwards, in one line per file.

### Conventions

- One topic per folder (`Go/`, `React/`), one concept per file. Never one giant note.
- Every note gets frontmatter: `tags: [topic, subtopic]`, `status:`, and `date:`
  where relevant. Dataview queries depend on this being consistent — a note
  without frontmatter is invisible to the vault's index pages.
- Bullet-dense reference style, not essay prose. This vault is for lookup.
- Cross-link related notes with `[[wikilinks]]`. One `find_related_notes` pass at
  the end covering all new files — not one call per file.

### Before writing

`search_notes` first. If the topic exists, update the existing note rather than
creating a near-duplicate. `check_duplicate` only when creating a genuinely new
topic note — skip it for dated files, which are unique by construction, and skip
it entirely when the target folder doesn't exist yet.

---

## Memory (`Memory/` in the vault)

```
Memory/_index.md      manifest, one line per topic — ALWAYS read this first
Memory/Lessons.md     durable gotchas + decisions, promoted from sessions
Memory/Sessions/      dated per-session logs
```

**Retrieval**: read `Memory/_index.md` → no matching line means nothing is
stored, so stop and proceed without memory. Do not fall back to searching. If a
line matches, read `Memory/Lessons.md`; open a session file only when the index
points at one specifically. Never `list_notes_by_topic` on `Memory/Sessions/` —
it grows unbounded and returns a preview for every entry, which is exactly what
the index exists to avoid.

**Writing**: save only what can't be cheaply re-derived — decisions plus their
reasoning, root causes and fixes, environment specifics, rejected approaches,
open threads. Not concept explanations, not code that exists in a file, not
conversation recaps. If a session produced nothing meeting that bar, write
nothing and say so. Update the matching `_index.md` line in place rather than
appending a second line for the same topic.

---

## Token discipline

Usage is shared across chat, Claude Code, and Desktop, on a 5-hour rolling
window — so a wasteful generation run costs interactive headroom later that day.

- Delegate bulk generation to the `learn-writer` subagent (Haiku). Isolated
  context means the generated content never enters the main session.
- Use `/model haiku` for writing and boilerplate; reserve stronger models for
  debugging and design.
- `ENABLE_TOOL_SEARCH=1` — defers MCP tool schema loading. Matters more with each
  server added.
- Read what's needed, not what's nearby. `read_note` a known path instead of
  searching for it.
- Don't explain a concept at length in chat *and* write the same thing to a note.
  Write the note, summarise in two lines.

---

## Known gotchas — do not re-derive these

- **Server must bind `0.0.0.0`, not `127.0.0.1`.** Binding localhost makes
  `tailscale serve` proxying fail with `Invalid Host header`.
- **Port 8001, not 8000** — 8000 was already taken on the Pi.
- **Claude Desktop's custom-connector dialog cannot add this server.** It forces
  an OAuth registration handshake against a server that has no auth, and fails
  with "Couldn't register with obsidian-vault's sign-in service". Known upstream
  bug. Use `claude mcp add --transport http obsidian-vault <url> --scope user`.
  On the Pi itself use `http://127.0.0.1:8001/mcp` and skip the proxy entirely.
- **`tailscale serve` needs `sudo`**, does not survive Ctrl+C, and returns
  `listener already exists for port 443` if a stale config lingers — fix with
  `sudo tailscale serve reset`. It runs as the `tailscale-serve` unit now.
- **Pi-hole was removed** because it held port 443 and blocked the proxy. Don't
  suggest reinstalling it on this host.
- **Claude Code never saves trust for a home directory.** `claude` and
  `claude remote-control` must be run from a real project dir, never `~`.
- **`~/.claude/` does not sync between machines.** MCP registrations, plugins and
  settings are per-machine. Agents and skills are shared via Syncthing symlinks
  into `~/claude-shared`; anything else must be set up on each machine separately.
