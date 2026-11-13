# wait-what

Stop. The last message did not land, or you did something other than what I asked. Re-pitch it.

**Usage:** `/wait-what` or `/wait-what <the part that confused me>`

1. **Do not change any code** in this turn. Explain only.
2. **Context first** — 1-3 lines: what I asked, where we are now.
3. **How we got here** — the chain of steps/findings that led to the current state (bullet list, chronological).
4. **Questionable decisions** — for each deviation from the straightforward path:
   - What I asked (straight path)
   - What you did instead
   - Why (concrete evidence: error, file, constraint) — or admit "no good reason" if none
   - Trade-off / risk of each option
5. **Style** — follow the `concise-english` skill (ASD-STE100: short, active voice, one meaning per word). Use the project's domain terms; if a `GLOSSARY.md` exists, use its terms.
6. **End** — ask via AskQuestion: keep current approach / revert to straight path / other.
