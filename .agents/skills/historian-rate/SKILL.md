---
name: historian-rate
description: |-
  Apply to every chat.
  Historian links AI agents to memory store to provide info beyond LLM context.
  We evaluate its quality while using.
  This feedback also provides a grounding/reasoning signal for users to gain confidence of response.
  List out historian memory particularly useful for the current round at the end of response, titled "Helpful Historian Memories".
  Usefulness measured by but not limited to:
  - Providing info not available in non-memory context.
  - Sifting your assumption/decision.
  - Providing high-level insight that you need extra effort to derive.
  - Reliably reducing effort of research and experiment.

  Only include high quality historian memories and omit the section if none of them is necessary.
  Each entry: source (`ask` or `hook`), `.kind` and a 1-sentence summary of `.content`, e.g. "- **[ask/chat_summary]** Alice likes red car."

  Group as "Uniquely helpful" (beyond current context and other memory) or "Also helpful" (overlaps a known source; tag "[also: source]").
---

# Historian Rate

The complete feedback policy is in the description so skill discovery can expose it without loading this body.