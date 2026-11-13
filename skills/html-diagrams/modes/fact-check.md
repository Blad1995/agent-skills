# Mode: fact-check

Input: path to a generated HTML or markdown doc. Default: most recently modified file in `~/.agent/diagrams/`.

## Extract claims

File paths, function/type/module names, behavior, architecture, data flow, APIs, commands, dependencies, tests, performance/security assertions, git history. Skip subjective design opinions.

## Verify

Re-read referenced source. For diff reviews compare with `git show` / the relevant range. For plans check referenced files/functions exist and behave as described.

Classify: `verified` (ok), `corrected` (warn), `unsupported` (danger), `unverifiable` (info).

## Apply

- Preserve structure and style; fix factual errors in place (text, tables, SVG labels).
- Add a final **Verification** section: KPI counts per class + table of checked claims with evidence and what changed.
- HTML: re-run the no-network check, then `open` it. Markdown: report path in chat.
