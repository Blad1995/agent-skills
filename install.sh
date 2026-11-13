#!/usr/bin/env bash
# Idempotently symlink commands, subagents, skills and rules from this repo into
# ~/.cursor and ~/.claude.
set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"

link_dir() { # $1 repo subdir, $2 target; backs up a real dir instead of deleting it
  mkdir -p "$(dirname "$2")"
  if [[ -L "$2" ]]; then rm "$2"; elif [[ -e "$2" ]]; then mv "$2" "$2.bak-$(date +%Y%m%d%H%M%S)"; fi
  ln -s "$REPO/$1" "$2"
}

link_skills() { # $1 target dir; per-skill links, leaves non-repo skills untouched
  mkdir -p "$1"
  find "$1" -maxdepth 1 -type l -lname "$REPO/*" -delete # drop stale repo links
  for s in "$REPO"/skills/*/; do ln -sfn "${s%/}" "$1/$(basename "$s")"; done
}

link_rules() { # $1 target dir, $2 link extension (mdc for Cursor, md for Claude)
  mkdir -p "$1"
  find "$1" -maxdepth 1 -type l -lname "$REPO/rules/*" -delete # drop stale repo rule links
  for r in "$REPO"/rules/*.mdc; do ln -sfn "$r" "$1/$(basename "$r" .mdc).$2"; done
}

# Cursor
link_dir commands "$HOME/.cursor/commands"
link_dir subagents "$HOME/.cursor/agents"
link_skills "$HOME/.cursor/skills"
link_rules "$HOME/.cursor/rules" mdc

# Claude Code
link_dir commands "$HOME/.claude/commands"
link_dir subagents "$HOME/.claude/agents"
link_skills "$HOME/.claude/skills"
link_rules "$HOME/.claude/rules" md
