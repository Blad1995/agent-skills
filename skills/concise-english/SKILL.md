---
name: concise-english
description: Rewrite ambiguous, dense, or jargon-heavy English into short, single-meaning, active-voice sentences based on ASD-STE100 controlled-language rules. Use when the user asks to disambiguate, simplify, shorten, or make text concise or plain-language; when writing tool descriptions, error messages, prompts, system messages, log messages, or inter-agent instructions; or when text will be consumed by another agent, a translation pipeline, or a non-native English reader.
---

# Concise English (ASD-STE100-inspired)

Rewrite English so a machine or a non-native reader cannot misread it, based on ASD-STE100 (aerospace controlled-language standard). Removes the two biggest misreading sources: words with more than one meaning, and sentences with more than one possible structure.

## When to use this skill

- Agent output (explanation, instruction, log message, tool description) reads as dense, jargon-heavy, or ambiguous.
- Text will be consumed by another agent, a translation pipeline, or a non-native English reader, and misparsing has a real cost.
- Writing a prompt, system message, or tool description that must be unambiguous.
- User mentions: disambiguate, plain-language rewrite, controlled language, concise English, rewrite so an agent cannot misread this.

Not for creative or marketing copy — STE is deliberately flat and literal.

## Two modes

Pick a mode before rewriting; infer from text type if the user does not say.

- **Strict** — procedures, error messages, tool/function descriptions, inter-agent instructions, safety text. Apply every rule, including hard length caps.
- **STE-flavored** — READMEs, PR descriptions, changelogs, explanatory prose. Apply structural rules in full; treat lexical rules as advisory. Dropping the one-word-one-meaning lockdown keeps prose readable.

## Structural rules — apply with confidence

| Rule | Do | Don't |
|---|---|---|
| Active voice | "The agent deletes the file." | "The file is deleted (by the agent)." — unless the actor is genuinely unknown |
| No phrasal verbs | "Remove the panel." / "Start the job." | "Take off the panel." / "Spin up the job." |
| One instruction per sentence | "Open the file. Read line 3." | "Open the file and read line 3, then check if it matches." |
| Sentence length | ≤20 words instructions, ≤25 words descriptions | Long compound/subordinate sentences |
| No semicolons | Split into separate sentences | Any semicolon at all |
| Noun clusters | ≤3 stacked words ("fuel pump valve") | 4+ word stacks |
| No ellipsis | Keep subject, verb, article explicit | "Files not backed up will be lost" |
| Keep modality | "may have failed" stays "may have" | Promote a hedge to a fact |
| Paragraph limits | One topic, ≤6 sentences | Multi-topic paragraphs |
| Lists for sequences | 3+ steps or conditions → numbered/bulleted list | Sequence buried in prose |

## Lexical rules — direction of travel only

| Rule | Do | Don't |
|---|---|---|
| One word, one meaning | Pick one verb per action and reuse it ("check" everywhere, never mix check/verify/confirm) | Rotate synonyms for the same idea |
| One part of speech per word | "Apply oil to the valve" (noun) | "Oil the valve" (verb) |
| Verb, not noun | "Analyze the log." | "Perform an analysis of the log." |
| Domain terms | Keep technical nouns; define once if uncommon | Undefined jargon |

Consistency within a document is checkable. Which word is the *approved* one needs the official ASD dictionary (~900 words), which this skill does not reproduce — never claim dictionary compliance. Get it from https://www.asd-ste100.org/STE_downloads.html if exact wording matters.

## Simple tenses

Permit infinitive, imperative, simple present/past/future, past participle as adjective. Exclude present perfect and other compound forms: "we received the report", not "we have received the report".

**Exception:** where the compound form carries information the simple form cannot — current relevance ("the job has completed" = output available now) or a hedge ("may have failed") — keep it and flag the departure.

## Scan checklist (before rewriting)

1. **Synonym rotation** — the same thing gets several names ("user", "customer", "client"). Pick one name, reuse it.
2. **Hedge stacking** — helper verbs pile up until the sentence asserts nothing ("may potentially help to improve"). State the claim or delete it.
3. **Nominalization** — action frozen into a noun ("perform an analysis of"). Use the verb ("analyze").
4. **Marketing adjectives** — seamless, robust, powerful, cutting-edge. Delete, or replace with the measurement.
5. **Run-on sentences** — several ideas joined by semicolons or em dashes. One idea per sentence.
6. **Soft phrasal verbs** — spin up, reach out, kick off. Use the single plain verb (start, contact, begin).

## Process

1. Pick the mode (Strict or STE-flavored).
2. Read the input once for meaning. Rewrite nothing until understood.
3. Walk sentence by sentence; flag every rule violation and checklist habit.
4. Rewrite each flagged sentence, preserving meaning exactly.
   - **Check modality before committing.** A rewrite that upgrades "may have failed" to "failed" is a different claim, not a simplification. Hedges are content.
   - Never add a fact the source did not state. A rewrite that reads better because it supplies a cause or frequency has stopped being a rewrite.
5. Output the rewritten text.

## Output format

**Default: the rewritten text, and nothing else.** No preamble, no mode announcement, no violation count, no summary.

One permitted addition: if a longer phrasing was kept on purpose, add a single line after the text, prefixed `Kept as-is:`, naming the phrase and the precision preserved. Omit when nothing to report.

**On request ("show the diff", "which rules did it break"):** output a rule table instead:

```markdown
| Rule violated | Original | Simplified |
|---|---|---|
| Present perfect tense | "We have received your request." | "We received your request." |

Mode: Strict. 7 violations found.
```

Then one line on anything deliberately not simplified, and why.

## Boundaries

- Will rewrite ambiguous/dense English into short, single-meaning, active-voice sentences; preserve every fact, condition, scope qualifier, and hedge strength.
- Will not silently drop a safety condition or scope qualifier to shorten a sentence; will not convert "may have failed" into "failed"; will not reproduce the official ASD dictionary; will not guarantee certified STE compliance; will not simplify creative or persuasive copy.
- Shorten only to the point of clarity, not to the shortest possible text. Past that point compression costs the reader more than it saves.
- STE fixes the *form*, not the substance. A hollow paragraph rewritten is still hollow — say so instead of polishing.

## Additional resources

- Source: https://github.com/danyuchn/asd-ste100-skill/blob/master/SKILL.md
- Source's `references/writing-rules.md` and `examples/before-after.md` for the full 9-section rule summary and worked examples.
