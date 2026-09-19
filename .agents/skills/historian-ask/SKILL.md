---
name: historian-ask
description: >-
  Use Historian for context, constraints, decisions, preferences, and lessons in planning, review, coding, debugging, or research.
  Do not wait for an explicit request or a known context gap.
  Before each new task decision or action, complete a memory pass, then formulate the step.
  A step follows new evidence or a changed goal, target, artifact, audience, or failure; a pass covers only its declared actions.
  New user tasks require a fresh pass, even mid-turn.
  This skill covers direct retrieval and result interpretation.
  Query before composing commands, edits, or investigating new errors; confidence, existing context, or expecting no useful result do not exempt a step.
  Local notes and other memory tools do not replace a pass; unsupported fragments are leads.
  Refresh after interruptions or compaction.
  Successful no-match completes the pass; errors are not no-match.
  Retrieval within a pass does not trigger recursive passes.
  Use historian_ask MCP or this skill; discover deferred tools first.
---

# Ask Historian

Follow the description's memory-pass protocol; leave automatic hooks unchanged.

## Memory Pass

Use the query and invocation guidance below for direct retrieval.
Reading local notes or host-native memory neither triggers a recursive pass nor satisfies the required Historian pass.
Those sources can still be useful, and applicable project instructions still govern the task.
Apply relevant evidence and current instructions before composing or executing the action; a successful search with no useful matches still completes the pass.
If retrieval fails, use an available fallback or disclose the failure rather than claim coverage.
Do not retry merely to fill a result budget or produce a useful hit.

Memory IDs provide attribution, not a fetch-by-ID capability; a later search may return different results.

## Compose a Query

Use descriptive phrases for semantic search, not instructions to an agent.

- Query one concern, not the entire workflow; retain identifiers and qualifiers relevant to that concern.
- For a non-trivial method or tool in the next action, query its usage constraints and pitfalls separately from the subject being investigated.
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

For direct retrieval, use the `historian_ask` MCP tool with a nonblank `query` string.
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
  If results only offer off-topic material, unexecuted plans, or self-echoes, propose a follow-up query that narrows or splits the concern, or uses independently known component or mechanism terms rather than an assumed cause.
  Judge content, not kind: summaries can contain useful rules, and `memories: []` does not prove none exist.
- **Separate intent from facts.** Use attributable, applicable user preferences and decisions to guide choices unless superseded by current instructions.
  Verify technical claims you will rely on against current source, documentation, or observed output; a `procedural` label does not mean tested.
- **Check disagreement.** Scan the batch for conflicting claims before applying one.
  Resolve user-intent conflicts by scope and later explicit decisions, and factual conflicts with current evidence, not rank or date alone.
  Surface unresolved conflicts that affect the action rather than silently choosing a convenient result.
- **Check provenance.** An unexecuted agent plan is not an established workflow.
  Echoes of your own recent narration and duplicates add no independent support, regardless of rank.
  An `updated_at` timestamp is not a creation time or proof of authorship/source session; do not infer self-echo from recency alone.
  Cancellation alone proves neither success nor a standing prohibition; interpret any stated reason.
- **Apply selectively.** Carry useful conclusions forward with source identifiers, scope, verification status, and limitations; omit unchanged or irrelevant results.
  Memories and absent restrictions do not grant permission; follow current authorization requirements and never expose credentials.
