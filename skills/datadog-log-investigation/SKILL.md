---
name: datadog-log-investigation
description: Investigate Datadog logs and APM traces/spans using the Datadog plugin/MCP. Use when the user asks to search logs, investigate an issue in Datadog, count or aggregate log events, or analyze a trace or span.
---

# Datadog Log Investigation

Apply the `concise-english` skill to all prose output (STE-flavored mode). Queries, fields, and identifiers stay unchanged.

This file holds generic rules only. If the repo has domain-specific query notes (e.g. in `AGENTS.md` or a repo skill), read them first.

## 1. MCP usage

- Server: the Datadog plugin/MCP (identifier varies by client, e.g. `datadog`, `user-datadog`). Check the available tool list before the first call.
- Pass `telemetry.intent` on every call (one English sentence, no PII).
- Tool choice:

| Need | Tool |
|---|---|
| Raw log lines | `search_datadog_logs` |
| Cluster similar lines | `search_datadog_logs` + `use_log_patterns: true` |
| Discover attribute names | `search_datadog_logs` + `extra_fields: ["*"]`, `limit: 1` |
| Counts, group-by, timeseries | `analyze_datadog_logs` (load `datadog/ddsql` skill first) |
| One trace by id | `get_datadog_trace` |
| Span search / span aggregation | `execute_code` with `v2.SpansApi` (see section 6) |

- Always pass explicit `indexes`. Never rely on the default `*`.
- Always set `limit` and `max_tokens`. Raise them only when needed.
- `analyze_datadog_logs`: the time window comes from `from`/`to`. Do not add `WHERE timestamp` in SQL.
- Key translation from `extra_fields` output to query syntax: `custom.X` -> `@X`, `error.X` -> `@error.X`, tags stay bare (`kube_namespace:x`). Load the `datadog/logs` skill when unsure.
- Old events: retry with `storage_tier: flex_and_indexes` or `online_archives_and_indexes` before you conclude that logs do not exist.

## 2. Querying

1. Anchor the time window on a known timestamp (DB row, user report, alert). Do not anchor on "now" for past incidents.
2. Start narrow (minutes to a few hours). Widen only after 0 hits.
3. Add filters in this order: index -> service or namespace -> task or event name -> entity id.
4. Do not guess attribute names. Run one discovery call (`extra_fields: ["*"]`, `limit: 1`) on a matching log first.
5. Entity id fallback chain: `@<id_attr>:<id>` -> the id as plain text -> `trace_id:<id>` or another stable id.
6. Errors: `status:error` + `use_log_patterns: true` + `clustering_pattern_field: "@error.message"`.
7. Stop rule: after 2-3 targeted attempts with 0 rows, stop and report what you tried.

## 3. Gotchas

- **Time range may not apply.** Compare `from_ts`/`to_ts` in the returned `logs_explorer_url` with the window you asked for. If they differ, report it and give the URL.
- **Connectivity vs empty.** Run a narrow recent query on the same index (`from: now-1h`). If it returns data, the MCP works and the 0 rows are real for that query.
- **0 rows does not mean no logs.** The cause can be the index, the attribute name, the window, or the storage tier.
- **Org call quota.** The MCP can return a quota warning. Keep the number of calls low: combine queries in one `execute_code` script when possible.

## 4. What to focus on

- The timeline per entity: what happened, in which order, on which service.
- The first error and its cause, not the last retry.
- Ids that link sources: `trace_id`, task id, request id, reference id.
- Retries, duplicates, and gaps between expected steps.
- Root-cause lines versus symptom lines. Report the root cause. Mention symptoms only as evidence.

## 5. Presenting results

- Start with a 1-3 sentence summary.
- Then a table: time, service, event or task, status, key fields.
- Do not dump raw JSON. Quote only the lines that decide the conclusion.
- Always give the exact query, index, time window, and `logs_explorer_url` (or `trace_deep_link_url`).
- Keep "no MCP hits" separate from "confirmed no logs in UI".
- Cohort data (many rows, many entities, cohorts, shareable output): render it with the `html-diagrams` skill (standalone offline HTML). Put aggregates in charts and labeled tables with source and time range. In chat, give the summary and the artifact path.

## 6. APM traces

- Load the `datadog/traces` skill first. For deep error or latency work, also load its `references/trace-analysis.md`.
- Workflow:
  1. Get a `trace_id` from a log line (top-level `trace_id` field) or from a span search.
  2. Call `get_datadog_trace` with `only_service_entry_spans: true`.
  3. If the response is truncated, add `include_path: ["service:<svc>"]` or `["span.kind:server"]`.
  4. For spans with `hidden_child_spans_count > 0`, call again with `expand_span_id`.
- Span search: `search_datadog_spans` is not in this MCP. Use `execute_code`:
  - `v2.SpansApi.aggregateSpans` for counts, top-N, and percentiles (`pc95` over `@duration`).
  - `v2.SpansApi.listSpans` for small samples and trace ids.
  - Run `search_datadog_sdk` first if you do not know the request shape.

```javascript
import { client, v2 } from "@datadog/datadog-api-client";
const spans = new v2.SpansApi(client.createConfiguration());
const r = await spans.listSpans({ body: { data: { type: "search_request", attributes: {
  filter: { query: "service:<svc> status:error", from: "now-1h", to: "now" },
  page: { limit: 5 }, sort: "-timestamp" }}}});
return r.data.map(s => ({ traceId: s.attributes.traceId, resource: s.attributes.resourceName }));
```

- Span query rules:
  - Reserved fields have no `@`: `service`, `resource_name`, `operation_name`, `status`, `type`, `trace_id`.
  - Other fields use `@`: `@http.status_code`, `@error.type`, `@span.kind`.
  - `@duration` is in nanoseconds. 100ms = `100000000`.
  - Error spans: `status:error`. HTTP errors: `@http.status_code:[500 TO 599]`.
- Traces can be dropped by sampling. A `trace_id` from a log can return "No trace found". This does not mean the request failed. Use logs, or search spans for a retained trace of the same resource.
- Focus order: error spans (`@error.type`, `@error.message`, `http.status_code`) -> slowest span on the critical path -> downstream calls (`peer.service`, `http.url`, `peer.db.*`). Cite span durations for every latency claim.
- Present a short tree: service -> resource -> duration -> status. Show only the decisive spans. Always include `trace_deep_link_url`.
