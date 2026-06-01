# Historian

Historian is a **context window multiplier** that adds memory capability into agentic workflow.

<a href="img/logo.jpg">
    <img src="img/logo.jpg" width="256">
</a>

Transformer-based LLM agents enables productive workloads by attending across a large context window, extracting info and generating responses.
While it is powerful at the beginning, LLM agents still suffer from catastrophic forgetting over time, especially when working with large code repos and knowledge bases.
Top-tier models today, e.g. Opus 4.8/GPT-5.5, support ~1M tokens, good for a few hours of coding tasks before overflow/compaction, while cheaper/faster models allows only 100k-400k.

Historian connects coding agents with memory solution, allowing chat sessions to accumulate and retrieve useful info while working.
This effectively extends the context window of LLM, enables sharing over time, between sessions, and even among your team.
Memories can now flow both within/beyond max context window and across chat compaction, to enhance AI quality of long-running agents beyond what Attention can see.

Currently Historian supports Azure Foundry Memory and uses [hooks](https://code.visualstudio.com/docs/copilot/customization/hooks) for vscode GHCP.

## Setup

1. `az login` to allow auth for `https://ai.azure.com/`.
2. Clone and add this repo to VSCode workspace.
3. Hooks are auto-discovered from paths in `chat.hookFilesLocations`.
    - If not, add to search paths in user `settings.json`, or the `"settings"` block of a `*.code-workspace` file:
      ```json
      "chat.hookFilesLocations": {
          "/abs/path/to/historian/.github/hooks": true
      }
      ```
    - Highly recommend to use **absolute path**, because rel glob like `".github/hooks"` auto-trusts hooks from all dir in ws and can be dangerous.
    - Hook may be blocked by certain enterprise/orgnization policy.
4. Open a chat session and watch *View -> Output -> [channel] GitHub Copilot Chat Hooks* to confirm its enablement from log.
    - If nothing appears on `SessionStart`/`UserPromptSubmit`, hooks are not correctly picked up or blocked.
    - Expect memory retrieval result as additional context in hook output.
    - Per-session state lives under `state/sessions/<sessionId>/`.
5. Memory store will be auto-created with preset configs when missing.
    - Existing memory store will not be reconfigured.
6. Check from Foundry Memory UX to confirm successful ingestion of memories.

# Configuration

- `HISTORIAN_FOUNDRY`: Foundry account/project name in the form of `my-foundry/proj-default`.
- `HISTORIAN_STORE`: Memory store name.
- `HISTORIAN_CHAT`: Chat model deployment.
- `HISTORIAN_EMB`: Embedding model deployment.
- `HISTORIAN_API_VER`: Foundry memory API version.
- `HISTORIAN_URL`: Override the derived endpoint (e.g. `http://127.0.0.1:50050` for local).
- `HISTORIAN_SCOPE`: Memory isolation key.

See `scripts/conf_def.sh` for current defaults.

## Privacy

Hooks see raw prompts and tool I/O, so we always take precautions:
- `scope` defaults to `{{$userId}}` so memories are isolated by identity.
- Every conversation transcript is passed through `scripts/redact.sh` to mask out known patterns of sensitive info before reaching memory store.
