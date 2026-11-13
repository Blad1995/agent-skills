---
name: write-docstrings
description: Write Python docstrings that explain business purpose and what/why, not implementation. Use when adding or editing docstrings, reviewing documentation, or the user asks for docstring style guidance.
---

# Write Docstrings

Apply the `concise-english` skill to docstring prose (STE-flavored mode). Code identifiers and NumPy section names stay unchanged.

> Conflict rule: rules already in this skill override the Linus-derived rules below (rules 6-8).

Docstrings explain **what the code does for the business** and **why** — not how the code does it. The implementation is the source of truth for mechanics; the docstring is the source of truth for intent and contract.

Assume code is checked by **pydocstyle** (NumPy convention) unless the repo says otherwise. Use the formatting rules below so pre-commit passes.

## Core rules

1. **Business first** — State the domain outcome (e.g. parse an invoice, detect priority labels), not the algorithm.
2. **What / why, not how** — Mention constraints or tradeoffs that matter to callers (memory, ambiguity, fallbacks) only when they affect behavior or expectations.
3. **No code in docstrings** — Do not reference functions, constants, modules, or pseudocode that mirrors the body (`:func:`, `:data:`, `via X then Y`, loop order, library call sequences).
4. **Do not duplicate the body** — If reading the docstring feels like reading the implementation line-by-line, delete that detail.
5. **Keep Parameters / Returns / Raises** when they clarify the **contract** (types, semantics of return values, failure modes). Omit sections that only repeat the signature.
6. **Docstring must be true (Linus-derived)** — When you edit a function, re-read its existing docstring and fix it if behavior changed. A stale or misleading docstring is a bug, not a nit.
7. **No hedging (Linus-derived)** — Avoid "should usually", "might", "probably", or claims that depend on runtime/library internals. State the contract or omit the sentence.
8. **Magic values at the use site (Linus-derived)** — Explain why a literal value exists with an inline comment next to it, not in the docstring.

## Format (NumPy style)

**Do not use Google-style section headers** (`Args:`, `Returns:`, `Raises:`). They fail pydocstyle (D406, D407, D413).

Use **NumPy-style** sections with dashed underlines and **no trailing colon** on the section name:

| Section | Underline | Use when |
|---------|-----------|----------|
| `Parameters` | `----------` | Parameter meaning or constraints are not obvious from the name/type |
| `Returns` | `-------` | Return semantics matter (e.g. `True` / `False` / `None` meanings, tuple parts) |
| `Raises` | `------` | Document exceptions callers must handle or that encode business failures |

**Parameter entry** — name on its own line, description indented on the next line(s):

```python
Parameters
----------
customer_id
    Customer who owns the invoices.
file_paths
    Storage paths of supplier invoice PDFs.
```

**Returns / Raises entry** — type on its own line, description indented below:

```python
Returns
-------
set[int]
    Order IDs that received a persisted invoice.

Raises
------
ValueError
    If any path is not a PDF or a document cannot be relocated.
```

**Closing:** Leave a **blank line** after the last section before the closing `"""`.

## One-line summary

The first line is an imperative, present-tense sentence describing the **business operation**:

- Good: `"""Extract line items from invoice files in object storage."""`
- Good: `"""Return a time-limited HTTPS URL for the customer receipt image, if one exists."""`
- Bad: `"""Parse invoice from PDF bytes using pdf_oxide."""` (names a library; not the business outcome)

Prefer domain language over library names unless the library *is* the contract (rare).

## Body (optional)

Add 1–3 sentences only when they add **non-obvious business context**:

- Edge cases callers should know (e.g. files that fail decoding are omitted; unmatched lines are skipped).
- Caller obligations (e.g. bind `invoice_flow` in structlog context before calling).
- What the function deliberately does **not** do (e.g. does not persist rows; caller commits).

Do **not** narrate control flow that matches the function body. Bullet lists of high-level stages are acceptable for entry-point workflows when they describe **business stages**, not internal call order.

## Good patterns

**Entry point — role + contract:**

```python
"""Extract line items from invoice files in object storage.

Files that fail decoding are omitted from the result.

Parameters
----------
gcs_paths
    Object paths of invoice files in the invoices bucket.

Returns
-------
list[ParsedInvoice]
    Successfully parsed invoices, one per input file where parsing succeeded.

Raises
------
ValueError
    If the parser reports success for a file but returns no decoded data.

"""
```

**Workflow entry — stages + caller contract:**

```python
"""Accept customer or support invoice uploads and prepare invoices for persistence.

Stages:
- Store raw uploads in GCS under a source-specific prefix.
- Parse, match, and build domain invoices via the shared processing pipeline.
- Drop invoices blocked by order status or an existing invoice on the order.
- Promote surviving documents to validated storage.

Does not write invoices to the database; the calling event commits them.

Parameters
----------
order
    Order receiving the upload.
uploaded_files
    Raw file payloads from the client.
uploaded_by
    Whether the upload came from the customer app or support tooling.

Returns
-------
InvoiceUploadResult
    Upload metrics and invoices the caller should persist.

"""
```

**Short business doc + return semantics only:**

```python
"""Return a time-limited HTTPS URL for the customer receipt image, if one exists.

URLs are cached in Redis to avoid repeated storage signing for the same filepath.

Returns
-------
str | None
    Presigned image URL, or None when the invoice has no receipt image.

"""
```

**Why, not how — tradeoff without pseudocode:**

```python
"""Resize image for OCR while preserving aspect ratio and ensuring a minimum size.

Downscales the image to reduce memory usage and improve performance, but ensures
neither dimension goes below a minimal size (256px) while preserving the original
aspect ratio.
"""
```

**Business edge case, no contract sections needed:**

```python
"""Link parsed invoices to orders of the customer.

Each invoice is matched by order number, then by line item SKU and amount.
Unmatched files or lines are skipped and logged; the result may be smaller than the input.
"""
```

## Bad patterns (avoid)

**Google-style headers (fails pydocstyle NumPy convention):**

```python
# BAD
"""...

Args:
    gcs_paths: Object paths in the invoices bucket.

Returns:
    Successfully parsed invoices.

Raises:
    ValueError: If the parser reports success without data.
"""
```

**Implementation walkthrough with code references:**

```python
# BAD — mirrors body; cites :func: and :data:; describes algorithm steps
"""Parse invoice from PDF bytes using pdf_oxide.

For each page: embedded text is tried first via
:func:`parse_invoice_from_text`; if none yields line items, the full
page is rasterized to PNG at :data:`PDF_RENDER_DPI` and parsed the same way.
"""
```

**Replace with business-focused text, e.g.:**

```python
"""Parse invoice from a PDF file.

Reads line items from text embedded in the document, or from rendered page
images when the embedded text does not contain a valid invoice.
"""
```

**Other anti-patterns:**

- Naming internal helpers or constants (`_resize_image_for_ocr`, `PDF_RENDER_DPI`)
- Step-by-step “first X, then Y, finally Z” that matches the source order
- Restating obvious parameters (`order: The order` with no extra meaning)
- Library names in the summary when domain wording exists (“using pdf_oxide”, “via zxing”)
- Missing blank line before closing `"""` after the last section

## Workflow when writing or editing

1. Write the **one-line** business summary.
2. Ask: “Would a caller care about this detail without reading the code?” — if no, stop.
3. Add **why** only for non-obvious constraints (performance, ambiguity, fallbacks).
4. Add **Parameters / Returns / Raises** in NumPy format only for contract clarity.
5. Re-read: remove any sentence that could be deleted by reading the function body.
6. Run `pre-commit run pydocstyle --files <path>` (or `/fix-pre-commit`) if unsure.

## Checklist before finishing

- [ ] First line describes business outcome, not libraries or steps
- [ ] NumPy sections (`Parameters`, `Returns`, `Raises`) with dashed underlines — no `Args:` / `Returns:` colons
- [ ] Blank line after the last section before closing `"""`
- [ ] No `:func:`, `:data:`, backticked identifiers, or pseudocode
- [ ] No line-by-line duplication of the implementation
- [ ] Returns / Raises explain meaning to callers, not internal flow
- [ ] Shorter is better; extra paragraphs must earn their place
- [ ] Docstring still matches the code after the change
- [ ] No hedging words; contract stated or sentence removed
