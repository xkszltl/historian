---
name: historian-ask
description: >-
  Use Historian proactively before planning, review, coding, debugging, or research decisions; do not wait for a request or known gap.
  Refresh at a new task or changed goal, target, approach, or failure, and after compaction.
  Use historian_ask for specific queries and, when available, historian-attn for broad goal-based retrieval.
  These are independent channels: when both apply, dispatch them in parallel from the same pre-action context, not one after the other.
  Direct ask works without subagents; discover deferred tools first.
  For VS Code attention calls, explicitly pass model "Auto (copilot)" when supported; omission follows configured defaults, not necessarily Auto.
  Elsewhere use the supported Auto selector, or omit unsupported model options.
  Reuse coverage for unchanged follow-through; local notes do not replace a pass.
  Retrieval does not trigger recursive passes.
  Successful no-match completes the pass; errors do not.
---

# Ask Historian

Follow the description's memory-pass protocol; leave automatic hooks unchanged.

## Memory Pass

Before choosing the next action, use direct ask for specific questions and the optional attention channel for broader goal-level context.
At a substantive task start, compose the focused queries and attention request independently from the same known context and dispatch them together when both channels apply.
Do not wait for an ask result before launching attention, or wait for attention before asking a question that is already identifiable.
Use sequential retrieval only when a later query genuinely depends on an earlier result.
Neither channel is a prerequisite for the other; without subagent support or the named agent, continue using direct ask normally.

A pass covers its declared actions, target, and failure or question; a related topic alone does not cover the planned method.
Reuse that coverage through unchanged reads, edits, and checks; do not invoke attention again merely because another tool call occurs.
Refresh broad attention when the goal-level scope changes, and use focused asks for new specific questions within that scope.
New user tasks, changed targets or approaches, new failures, and interruptions or compaction require fresh coverage before acting.
Reading local notes or host-native memory neither triggers a recursive pass nor satisfies the required Historian pass.
Those sources can still be useful, and applicable project instructions still govern the task.
Apply relevant evidence and current instructions before composing the action, then compare the concrete edit or command with verified, applicable constraints before applying or executing it.
Preserve working user expressions and structure unless the requested change requires altering them; retrieved preferences do not authorize unrelated rewrites.
A successful search with no useful matches completes the pass without supplying decision support.
If retrieval fails, use only an authorized fallback or disclose the failure rather than claim coverage.
Do not retry merely to fill a result budget or produce a useful hit.

Memory IDs provide attribution, not a fetch-by-ID capability; a later search may return different results.

## Optional Attention Channel

When the harness exposes `historian-attn` and permits delegation, send it the goal, next action, target, method/tool, observations, and constraints.
Carry retrieval-interface restrictions into delegated work; if a child lacks an authorized interface, it must report the limitation rather than substitute a forbidden interface.
Use the harness's parallel tool-call facility for independent direct asks alongside that invocation; do not send both channels the same fixed query list.
In VS Code, call `runSubagent` with `agentName: "historian-attn"` and explicitly set `model: "Auto (copilot)"` when that selector is supported.
Omitting `model` uses the harness's configured default selection or inheritance; it is not an explicit Auto request.
On other harnesses, use the supported automatic selector or omit unsupported model options; do not require changing settings or agent metadata.
Wait for the requested results and inspect each channel's coverage and errors before acting; independent searches can still return overlapping evidence.
This is caller guidance, not a requirement for executing `historian_ask`; retrieval already in progress must not start recursive memory passes or nested attention calls.

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

MCP-only restrictions exclude script and terminal HTTP substitutes even when MCP or tool discovery is unavailable.
When script retrieval is permitted, resolve [mem_ask.sh](../../../scripts/mem_ask.sh) relative to this skill, not the working directory, and send nonblank plain text on stdin, not as an argument.
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
- **Check applicability and disagreement.** Match guidance to the planned operation, environment, and scope, not just its topic.
  Distinguish broad defaults from operation-specific exceptions; apply each only within its stated conditions and scan for conflicting claims.
  Resolve user-intent conflicts by scope and later explicit decisions, and factual conflicts with current evidence, not rank or date alone.
  Surface unresolved conflicts that affect the action rather than silently choosing a convenient result.
- **Check provenance.** An unexecuted agent plan is not an established workflow.
  Echoes of your own recent narration and duplicates add no independent support, regardless of rank.
  An `updated_at` timestamp is not a creation time or proof of authorship/source session; do not infer self-echo from recency alone.
  Cancellation alone proves neither success nor a standing prohibition; interpret any stated reason.
- **Apply selectively.** Carry useful conclusions forward with source identifiers, scope, verification status, and limitations; omit unchanged or irrelevant results.
  Memories and absent restrictions do not grant permission; follow current authorization requirements and never expose credentials.
