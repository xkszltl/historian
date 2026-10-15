---
name: historian-train
description: >-
  Run automatic prompt tuning as a bounded, training-style job with frozen datasets, small prompt updates, multi-model evaluation, and per-epoch reporting.
  Use for unattended prompt optimization, prompt training pipelines, learning-rate tuning, regression checks, or repeated agent-instruction experiments.
  Covers preparation, dataset generation, evaluation, parallelization, checkpointing, recovery, and final selection without depending on an existing benchmark harness.
  Not model-weight fine-tuning or permission to start experiments when only a plan or assessment was requested.
---

# Historian Train

Treat the editable prompt text as the weights, frozen cases as training data, and observed failures as feedback.
Keep the task contract and evaluator separate from the training target; improving a score by weakening either is not improvement.
Use this self-contained protocol to build the smallest necessary run-local pipeline.
Do not require a previous run's scripts, datasets, notes, logs, or directory layout.
Adapt proposed defaults to the user's authorization before dispatching trials.

## 1. Establish the Run Contract

Record the goal, primary deployment condition, allowed prompt files or sections, immutable behavior, and measurable success criteria.
Define what the target must return and where its responsibility ends, including forbidden actions and tool-call limits.
Distinguish parent-visible routing descriptions, child instructions, invocation inputs, and tool descriptions; they are different surfaces.
Edit only the named training target, preserving unrelated user changes.

Publish one compact run manifest before training and resolve missing authorization or material ambiguity once.
Use existing explicit decisions instead of asking the user to reconfirm them.
The following values are a proposed starting profile, not permission to spend the corresponding budget:

```yaml
training_cases: 5
epoch_budget: 20
primary_model: Auto
regression_models: [Astra, Opus, MAI]
trials_per_slot: 1
model_parallelism: 4
case_parallelism: 1
controlled_changes_per_epoch: 1
prompt_growth_budget_chars: 0
final_unchanged_epochs: 2
early_stopping: false
```

Resolve model labels to supported selectors during preparation; do not hardcode historical model versions or silently substitute unavailable models.
Use the actual deployment model as primary when it is not Auto.
Record any phased schedule, such as primary-only baseline epochs followed by joint evaluation, before execution.
Also record the artifact location, permitted data/log access, time/cost/tool-call ceilings, pilot allowance, correction policy, and any held-out evaluation budget.
Count expected trials as the sum of cases times models times repetitions in each epoch; count pilots and input corrections separately.
Include downstream fan-out when estimating load: concurrent trials times calls per trial can greatly exceed parent concurrency.
Scope or schedule amendments take effect prospectively and never relabel completed history.

Rank objectives before seeing results:

1. Safety, scope, task-role boundaries, and required behavioral contracts.
2. Primary-model correctness, source fidelity, and usefulness across all cases.
3. Declared regression tolerances for other models and cases.
4. Latency, tool cost, output size, and prompt length at acceptable quality.

Do not let a pooled model average cancel a primary-model failure or hide a safety violation.
Specify whether guard-model defects block selection or remain disclosed limitations.
Prompt instructions are not runtime enforcement; if reliable enforcement requires code or harness changes, report that separately and request scope before implementing it.

## 2. Prepare Before Training

- Read the current target, applicable instructions, and nearby contracts; save an exact baseline and hash before any tuning edit.
- Verify the interpreter, dependencies, tool availability, supported model selectors, and existing permissions using the approved environment.
  Do not install dependencies or change settings, authentication, hooks, backends, or saved defaults without authorization.
- Confirm how a trial receives the candidate and which prompt surfaces are actually visible to it.
  Record an available loaded-prompt version/hash or equivalent delivery evidence.
  A disk checkpoint alone does not prove hot reload or delivery; disclose uncertainty rather than inspect host or extension source outside scope.
- Test the evaluator with small synthetic passing and failing fixtures before trusting scores.
  Include malformed output, incorrect call counts, wrong input/model selection, altered source text, and missing output where relevant.
- Verify complete final-output capture, invocation correlation, actual tool dispatches, model identity/effort, timestamps, and error capture.
  Truncated UI previews and a model's self-report are not authoritative execution records.
- Start each scored trial in a fresh isolated context with the intended runtime instructions and frozen case input.
  Exclude tuning discussions, prior trial outputs, and evaluator feedback from that context.
- Run a separately labeled, budgeted pilot to verify the intended execution path and model concurrency.
  Confirm real overlap from timings, not merely simultaneous UI entries.
  Do not assume a coordinator can delegate because its parent can; use direct parent orchestration when delegation tools are unavailable.
- Record cache, capture hooks, live data sources, and other environment conditions that can affect quality or timing.
  Do not silently disable audit or capture to make a benchmark faster.
- Choose an ignored local artifact location and verify its ignored status before storing private evidence.
  Keep public skill text and committed examples free of private workloads, identities, raw memories, credentials, and transcripts.

If the evaluator, delivery, or execution path cannot support the intended claim, narrow the claim or pause for the missing prerequisite.
Do not train against an unverified scoring pipeline and later treat its scores as proof.

## 3. Generate and Freeze the Dataset

Generate all training cases before the first scored epoch, using the user's real task distribution at an approved level of detail.
Five diverse cases are a useful small starting set, not a universal sample-size guarantee.
Vary domains and failure mechanisms rather than producing paraphrases of one successful task.
Include representative normal behavior and relevant contrasts: short/long inputs, missing evidence, conflicting evidence, negative conditions, tool failures, or strict structured output.
Use synthetic or sanitized scenarios unless private-workload replay is explicitly authorized.

Each case must contain:

| Field | Required Content |
|---|---|
| Identity | Stable case ID, purpose, and important contrast with other cases |
| Input | Exact caller goal, context, constraints, mode, and available tools |
| Controlled data | Frozen fixtures or exact supplied query strings when these are part of the test |
| Oracle | Expected observable behavior, forbidden behavior, and source of truth |
| Rubric | Mechanical checks, semantic checks, severity, and applicability |
| Evidence policy | Permitted source snapshots/log references and known nondeterminism |

Keep the oracle and tuning feedback out of the evaluated agent's input.
For open-ended tasks, specify acceptance properties rather than forcing one preferred wording.
Use the same case input across compared models; keep epoch/model labels in orchestration metadata, not as accidental prompt changes.

Distinguish two different experiments:

- A supplied fixed plan tests execution of that plan, not the model's ability to compose it.
- A frozen free-form goal tests planning as well; generated queries or plans are outputs to record and evaluate, not frozen inputs.

Hash the dataset, case inputs, fixtures, and rubric, and keep them unchanged throughout the declared run.
If a case or rubric must change, record a new version and comparison boundary; do not silently rewrite earlier results.
Do not tune cases to favor the current candidate or remove difficult cases after failures.

For retrieval tasks, assess against the exact sources delivered to that trial, not a later re-query.
Record source-set hashes and retain only the source evidence permitted by the data policy.
Live-store changes, including automatic capture of benchmark narration, are confounds; repeated retellings are not independent support.
Do not seed, delete, or rerank memories to improve scores.

Other models provide regression and overfitting checks, not held-out data.
If generalization is a goal, reserve separately authorized unseen cases before tuning and evaluate them only after candidate selection.
Do not use held-out feedback for further tuning while continuing to call that set held-out.
Otherwise label the result as fixed-training-set performance.

## 4. Build the Minimal Training Pipeline

Implement or reuse only the pieces needed for dispatch, durable records, evaluation, and reporting.
Use structured parsers for YAML/JSON and the host's supported parallel-call mechanism.
Keep implementation choices local to the run; this skill does not prescribe an old helper script or artifact filename.

Persist these logical artifacts in any simple auditable format:

| Artifact | Required Content |
|---|---|
| Run manifest | Scope, budgets, schedule, models, objectives, environment, and amendments |
| Dataset | Immutable cases, input hashes, oracle, rubric, and split membership |
| Checkpoint | Exact prompt, hash, length, epoch, hypothesis, and diff from prior candidate |
| Trial ledger | One record per attempt, including failed, invalid, interrupted, and unknown outcomes |
| Epoch report | Full-matrix metrics, error examples, semantic review, and next decision |
| Final report | Selected candidate, comparison evidence, limitations, and remaining operational changes |

Identify an intended slot by run, epoch, case, requested model, and repetition.
Record a distinct invocation/attempt ID for every dispatch.
Include requested selector, actual model and reasoning effort, prompt/input hashes, delivery evidence, start/end times, concurrency, tool names/arguments, dispatch round sizes, tool/retrieval errors, complete output or its approved reference, output hash, scores, and exclusions.
Keep raw observations separate from evaluator judgments and later amendments.
Sanitize recorded tool arguments and outputs under the evidence policy; never persist credentials in training artifacts.
Record redaction explicitly; when it prevents exact fidelity verification, mark that check unverified rather than reconstructing evidence.
Never inspect or retain hidden reasoning as evaluation evidence.

Validate slot coverage, uniqueness, model/input identity, and complete-output capture before aggregating.
Record caller mistakes as input-invalid, not target-model failures, while preserving the attempt in accounting.
Only replace an invalid input under the declared correction policy, using an explicit corrected label and unchanged candidate.
Do not rerun a trial because its output was poor or a tool failed.
If a subagent retries or makes extra calls, count those actual calls and score the protocol violation.
Predeclared repetitions are measurements, not permission for success-seeking retries.

If the evaluator has a defect, version the fix and rescore all affected saved outputs consistently.
Preserve the previous assessment and explain the correction; do not selectively repair a candidate's score or replay its trials.

## 5. Control the Learning Rate

Use a semantic learning rate: change one controlling concept or coherent block per update, not a numerical gradient.
Before editing, state the observed defect, local hypothesis, predicted difference, protected behavior, and cheap check that could disconfirm it.
Prefer replacing, consolidating, deleting, or moving instructions over accumulating warnings and examples.
Default to no net prompt growth; amend the growth budget explicitly when necessary.
Record changed lines/characters and total size, but do not mistake edit size for semantic distance.

Keep tool restrictions, output schema, role boundaries, exact-copy requirements, public interfaces, and explicit hyperparameters fixed unless they are the authorized target.
Use domain-neutral examples that preserve qualifications; do not paste a failed case's answer into the prompt.
Keep runtime/model settings and evaluation machinery outside the prompt update.

After a noisy result, an unchanged-prompt epoch is a valid next step.
Reduce the step size or restore an earlier tested candidate when a change worsens the primary objective without a demonstrated benefit.
Preserve the rejected checkpoint and all its results.
Use a larger deliberate refactor only when repeated evidence supports it and the authorized scope permits it; isolate it as one declared intervention.
Do not combine an instruction refactor with capture, concurrency, model, and dataset changes and call the result a prompt effect.

## 6. Execute Complete Epochs

1. Start the first scored epoch with the unchanged baseline.
2. For each later candidate, finish the prior epoch's audit and report before choosing its update.
3. Apply the single declared update or explicitly hold the prompt unchanged.
4. Immediately run focused static validation: frontmatter, schema, required fields, budgets, links, synchronized sections, and relevant examples.
   Fix local validation failures before dispatch; passing static checks does not prove behavioral compliance.
5. Save the immutable checkpoint, conditions, and hashes.
6. Evaluate every scheduled case/model/repetition slot with that checkpoint.
   Do not edit the prompt midway through an epoch or feed one model another model's answer.
7. Audit all attempts and compute the full case/model matrix, including failures and missing outcomes.
8. Report target progress, regressions, and overall direction, then choose the next update, rollback, or no-change epoch.
9. Reserve the declared final epochs for unchanged-candidate confirmation; never make an untested final edit after the budget is exhausted.

Honor the epoch budget even when early results look good or a plateau appears; progress analysis is informational unless early stopping was authorized.
User cancellation, exhausted safety/cost ceilings, unavailable prerequisites, or required approval can still pause the run.
If a schedule is extended, preserve the existing epochs and record the extension before further trials.

## 7. Parallelize Within Limits

Default to model parallelism on one case at a time: dispatch all scheduled models for that case together, then advance to the next case.
Keep tuning decisions sequential across epochs.
Scale to case parallelism only after a healthy pilot and explicit authorization for the extra shared-service load.
For a full case/model wave, order cases outermost and models innermost so partial scheduling still compares models on the same case.

Record requested concurrency and observed overlap separately.
Measure hook wait, model phases, tool time, wall time, and residual overhead where available; overlapping durations are not simply additive.
Keep tool errors, backend error payloads, rate limits, and long waits distinct from output-quality failures.
Do not infer a specific throttling mechanism from latency or a generic search error alone.

When congestion appears, retain the failed attempts and reduce subsequent concurrency within the approved fallback policy.
Record any within-epoch scheduling change as a mixed condition and do not pool its latency as a clean comparison.
Re-expand only under the declared gate or renewed authorization, not because a single retry succeeded.
If capture changes are authorized, preserve required audit/startup safeguards, record before/after behavior, and agree on restoration before applying them.
Disabling one hook registration does not prove that all ingestion stopped or that an already-running client reloaded it.

## 8. Evaluate and Report Every Epoch

Separate dimensions instead of reducing everything to one success count:

| Dimension | Evidence |
|---|---|
| Input and delivery | Correct case/model/prompt, complete output, known delivery limitations |
| Operational health | Tool/backend errors, timeouts, hook delays, concurrency and routing changes |
| Protocol | Actual calls and rounds, exact supplied plans, forbidden actions, terminal role behavior |
| Structure | Parseability, schema, required fields, output/item budgets |
| Fidelity | Correct source, exact text/metadata, IDs, query/response associations, omission boundaries |
| Semantics | Useful distinct evidence, correct conclusions where allowed, retained conditions and negations |
| Efficiency | Length, tokens/cost where measurable, latency distribution and component timings |

For source-preserving briefs, distinguish identifier typos from wrong-source content, attribution, and material fabrication.
Check ordered exact substrings and required leading/interior/trailing omission markers against each item's own source.
Then review whether omissions change meaning and whether context summaries describe only omitted source material.
Valid JSON or substring matching alone proves neither usefulness nor semantic safety.
If the target's role is retrieval, a polished answer to the caller's task is still a role failure.

Use observed fractions with denominators, broken down by model and case, plus declared severity and primary-model aggregates.
Keep zero-selection, non-JSON, missing-output, and operational failures visible in trial-level counts even when an item-level denominator is smaller.
Include comparison to the previous epoch, baseline, and best candidate; show actual Auto routing and effort rather than assuming its label is stable.
Report timing distributions or raw samples where useful, but do not infer prompt causality from wall time, small samples, or changing conditions.
Retain counterexamples under an identical prompt even when a later epoch passes.

After each complete epoch and before the next change, emit a brief report:

```text
Epoch / prompt hash / conditions:
Primary model: protocol numerator/denominator; quality counts; material defects.
Regression models: improvements and failures separately.
Target: Did the previous change address the observed problem? Give evidence.
Regressions: What became worse, including semantic or operational changes?
Overall: Are results improving? Distinguish observation from attribution.
Next: Hold, one specified edit, or restore a named checkpoint; explain why.
```

For the baseline, mark the target comparison as not applicable.
For unchanged epochs, report stability rather than crediting a nonexistent edit.
Do not use guard-model success to outvote primary-model defects.
Backfill the same concise assessment for earlier epochs if reporting was introduced mid-run and evidence is available.

## 9. Run Unattended and Resume Safely

After setup authorization, carry out routine epochs, audits, and allowed prompt updates without asking for approval at every step.
Continue providing short progress and epoch reports; non-interactive does not mean silent or unaudited.
Use the host's supported completion notifications rather than polling or launching uncontrolled background work.

Unattended scope does not authorize approval bypass, secrets access, deletion, dependency installation, settings changes, broader logs, host-source investigation, private replay, or backend changes.
Never answer a new permission prompt automatically or route a secret through the model.
Pause at a genuine boundary, save status, explain the blocker, and request only the missing decision.
Do not expand into unrelated debugging to keep the training loop running.

Persist progress after each completed trial and epoch so recovery does not depend on chat context.
After interruption or compaction, recover the manifest, current checkpoint, ledger, pending invocations, and latest user instructions before acting.
Use invocation IDs and authoritative execution records to distinguish not-dispatched, running, completed, and outcome-unknown attempts.
Absence from one search or UI view is not proof that nothing ran.
Reconcile before dispatching missing slots; never silently duplicate, backfill, relabel, or discard earlier attempts.
Keep routine memory passes, pilots, and operational checks separate from scored training trials.

## 10. Select and Close Out

Select a tested candidate using the declared priorities and repeated evidence, not simply the latest or highest single-epoch score.
Verify its exact saved content/hash and preserve user edits when restoring only the authorized target.
Report the unchanged confirmation results and separately budgeted held-out results, if any.
Do not claim an optimum, generalization, or reliable runtime enforcement from fixed-case success.

Finalize a self-contained report with intended slots, actual attempts, invalid inputs, failures, pilots, schedule amendments, prompt changes, model/effort labels, metrics, semantic caveats, and the selection rationale.
State unresolved behavior and distinguish static validation, measured behavior, and unsupported claims.
Verify artifact links, accounting, hashes, privacy/ignored status, and focused checks for any implementation changes.
Restore temporary operational changes only under the agreed plan; otherwise disclose exactly what remains changed.
Do not delete artifacts, commit, publish, alter saved defaults, or start extra experiments as implicit cleanup.
Keep reusable guidance independent of the local run artifacts so a fresh checkout can follow this protocol from the beginning.
