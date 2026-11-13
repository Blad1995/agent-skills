---
name: manage-obsidian-notes
description: Manage, create, search, and edit Obsidian notes using the Obsidian CLI. Use when the user asks to create a note, search their knowledge base, or manage their Obsidian vault.
---

# Manage Obsidian Notes

Apply the `concise-english` skill to note content you create or edit (STE-flavored mode). Vault commands and paths stay unchanged.

Use the `obsidian` CLI to interact with the user's Obsidian vault.
The target vault name is `"Obsidian Vault"`.

> **Note:** The Obsidian app must be running with the **Command line interface** setting enabled (Settings → General) for these commands to work.

## Vault layout

Do not assume a folder map. Before creating or moving notes, list the top-level folders (resolve the vault path below, then `ls`) and reuse the existing structure. Typical roots: personal vs work areas, `Weekly/`, `Templates/`, `Attachments/`, `.obsidian/` (app config, never user notes).

When creating **new** notes, prefer the **most specific existing subfolder**. If nothing fits, use the closest parent briefly, then add a subfolder when 2+ related notes exist.

### Keeping the folder structure clean

When using this skill to **create or move** notes:

1. **Pick the right root first** — never put clearly personal content under a work folder or vice versa.
2. **Prefer depth over clutter** — New notes go into the smallest matching folder (e.g. `Projects/Api/…` not `Projects/…` when the note is API scoped).
3. **Name clearly** — Use descriptive titles; date prefixes are fine for chronological logs (follow existing examples in the vault).
4. **Attachments** — Images and binaries belong in **`Attachments/`** (or paths Obsidian already uses); link from notes rather than scattering files in note folders unless the user prefers otherwise.
5. **Do not create notes under `.obsidian`** or other dot-directories.
6. **If unsure** — Create in the best-guess folder and mention in chat that the user may want to relocate; optionally suggest a subfolder name if a new theme is emerging.

## Instructions

Always include `vault="Obsidian Vault"` as the **first** parameter on every `obsidian` command.

### Resolve vault path on disk

When you need filesystem access (large edits, bulk create, `ls`):

- **macOS:** read `~/Library/Application Support/obsidian/obsidian.json` → `vaults.<id>.path` (e.g. `/Users/<user>/Documents/Obsidian Vault`).
- Prefer this over `find` across `$HOME` (slow, often aborted).

### CLI vs filesystem editing

| Task | Prefer |
|------|--------|
| Search, read, append, prepend, tasks | `obsidian` CLI |
| Create short notes | `obsidian create` with `silent` |
| Create notes in subfolders | `obsidian create path="Projects/Api/My Note.md"` |
| Long / multi-section docs, mermaid, frontmatter | **Write** (or StrReplace) on `…/Obsidian Vault/<path>.md` |
| Fix a typo or one line in an existing note | StrReplace on vault file, or `append` for additions only |

The CLI has **no replace/search-replace** command. `obsidian help` lists `create`, `append`, `prepend` only.

### Shell pitfalls

- **Backticks in `content=` or heredocs** — zsh runs them as command substitution (e.g. `` `user_id` `` → command not found). For append/create via shell: avoid backticks, or write the file with the editor/Write tool instead.
- **Pipe to `rg`** — may be missing; use `obsidian help 2>&1 | grep` when exploring CLI.
- **Scoped search** — `search query="…" path="Projects/Api"` when the vault is large.

### Multi-note documentation sets

For non-trivial flows (e.g. cross-service):

1. **Hub note** — overview, mermaid sequence, links to children.
2. **Child notes** — one layer each (API entry, domain event, external service).
3. **Shared frontmatter tags** — e.g. `api`, `auth` for graph/search.
4. **Wikilinks** — `[[Child note]]` between hub and children; update an existing map note (e.g. project map) with a short section linking the hub.

Use the **obsidian-markdown** skill for callouts, properties, and embed syntax.

### Common Note Management Commands

**1. Search notes**

```bash
obsidian vault="Obsidian Vault" search query="your search term" path="Projects/Api" limit=10 format=json
```

**2. Read a note**

```bash
obsidian vault="Obsidian Vault" read path="Projects/Api/My Note.md"
```

`file=` resolves like a wikilink (no `.md` required). `path=` is exact under the vault root.

**3. Create a note**

```bash
# Root or name-resolved location
obsidian vault="Obsidian Vault" create name="New Note" content="# Title\n\nBody" silent

# Explicit subfolder (preferred)
obsidian vault="Obsidian Vault" create path="Projects/Api/New Note.md" content="# Title\n\nBody" silent
```

**4. Append / prepend**

```bash
obsidian vault="Obsidian Vault" append path="Projects/Api/Api project map.md" content="\n\n## Section\n\nNew paragraph."
```

**5. Tasks**

```bash
obsidian vault="Obsidian Vault" tasks todo format=json
obsidian vault="Obsidian Vault" task file="Note Name" line=8 done
```

**6. Daily notes**

```bash
obsidian vault="Obsidian Vault" daily:read
obsidian vault="Obsidian Vault" daily:append content="- [ ] New task for today"
```

**7. Discover commands**

```bash
obsidian help
```

## Best Practices

- Always quote values with spaces: `vault="Obsidian Vault"`, `path="Projects/Api/…"`.
- Use `\n` for newlines in CLI `content=` strings.
- Use `format=json` on `search` and `tasks` when parsing output in scripts.
- After creating a doc set, link it from an existing index note (project map, service map) so it is discoverable in the vault.
- Add `--copy` only when the user wants output on the clipboard.
