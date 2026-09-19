---
name: historian-ask
description: >-
  Use Historian for context, constraints, decisions, preferences, and lessons in planning, review, coding, debugging, or research.
  At task start and before each substantive action, including long tests or user-observed commands, check coverage.
  Reuse recent results only for the same action, target, and failure; otherwise query before acting.
  Query new error signatures before investigating; recheck topic, target, or approach changes.
  Check before hypotheses, composing commands, tool calls, edits, or doc lookups; confidence is not coverage.
  Conversation or summary fragments lacking source, scope, or verification status are leads, not coverage; query before relying on them.
  Refresh after extended work, interruptions, or compaction; other sessions may update memory.
  Consider Historian alongside local or other memory tools.
  Weigh query cost against rework and mistakes; avoid quotas, fixed schedules, and unproductive retries.
  Use historian_ask MCP or the historian-ask skill; discover the tool first if deferred.
---

# Ask Historian

Follow the description's timing policy; leave automatic hooks unchanged.

## Compose a Query

Use descriptive phrases for semantic search, not instructions to an agent.

- Query one concern, not the entire workflow; retain identifiers and qualifiers relevant to that concern.
- Omit other goals and follow-up steps even when task-relevant; focus matters more than query length.
- Seek constraints, prohibitions, and rejected alternatives as well as preferred approaches, without assuming a prohibition exists.
- Use known context, not invented details; omit conversational framing and output-format requests.
  Natural-language exclusions are not search filters.
- Exclude credentials and unnecessary sensitive information; redaction is not a guarantee.

Example of decomposition:

- Mixed query: "Format Python code, run tests, and publish a package."
- Separate queries: "Python formatting conventions"; "Python test invocation preferences"; "Package publishing restrictions".

Choose only the concern needed next, not every query in the example.
Other focused queries include "JavaScript CI test timeout fixes", "Protein structure benchmark limitations", and "Lisbon hotel shortlist".

## Run Ask

Prefer the `historian_ask` MCP tool with a nonblank `query` string.
If deferred, discover it first; subsequent memory queries call the loaded tool directly.

```json
{"query": "Python test invocation preferences"}
```

Otherwise, resolve [mem_ask.sh](../../../scripts/mem_ask.sh) relative to this skill, not the working directory, and send nonblank plain text on stdin, not as an argument.
From the Historian checkout:

```sh
printf '%s\n' 'Python test invocation preferences' | scripts/mem_ask.sh
```

Both interfaces handle authentication and redaction, return JSON, and write diagnostics under `state/ask/` without updating memories.
Keep the configured endpoint, store, and scope; request required permissions through the host rather than bypassing denied access.
Invoke directly without extra post-processing for routine error checks or formatting.

## Use the Results

Check exit status or MCP `isError` alongside JSON `.error`, then read `memories[].memory_item`.
Use relevant partial results while disclosing errors; execution or parsing failure is not a no-match result.

- **Check coverage.** Identify which results answer the current concern, not merely mention its topic.
  If results only offer off-topic material, unexecuted plans, or self-echoes, narrow or split the query, or reframe it using independently known component or mechanism terms rather than an assumed cause.
  Judge content, not kind: summaries can contain useful rules, and `memories: []` does not prove none exist.
- **Separate intent from facts.** Use attributable, applicable user preferences and decisions to guide choices unless superseded by current instructions.
  Verify technical claims you will rely on against current source, documentation, or observed output; a `procedural` label does not mean tested.
- **Check disagreement.** Scan the batch for conflicting claims before applying one.
  Resolve user-intent conflicts by scope and later explicit decisions, and factual conflicts with current evidence, not rank or date alone.
  Surface unresolved conflicts that affect the action rather than silently choosing a convenient result.
- **Check provenance.** An unexecuted agent plan is not an established workflow.
  Echoes of your own recent narration and duplicates add no independent support, regardless of rank.
  Cancellation alone proves neither success nor a standing prohibition; interpret any stated reason.
- **Apply selectively.** Carry useful conclusions forward with source identifiers, scope, verification status, and limitations; omit unchanged or irrelevant results.
  Memories and absent restrictions do not grant permission; follow current authorization requirements and never expose credentials.
