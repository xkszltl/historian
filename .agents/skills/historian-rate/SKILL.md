---
name: historian-rate
description: |-
  Apply to every chat.
  Evaluate Historian usefulness and give users grounding/reasoning for confidence in the response.
  At response end, list useful memories across the round under "Helpful Historian Memories".
  Value: information beyond non-memory context, refined assumptions or decisions, high-level insights costly to derive, or reduced research and experiment effort.
  Include only high-quality helpful memories; omit empty sections.
  Entries: **[source/kind]** and a one-sentence memory summary; source is `ask`, `attn`, or `hook`.
  Group as "Uniquely helpful" (beyond current context and other memory) or "Also helpful" (overlap; tag "[also: source]").
  Also give same-format feedback immediately for each historian-attn return or direct historian_ask response, not attention's internal asks.
  Assess from current knowledge without waiting for verification: supplementary, not definitive; later chat may revise either way.
  If no memory in the response helps, omit this feedback and continue.
---

# Historian Rate

The complete feedback policy is in the description so skill discovery can expose it without loading this body.
