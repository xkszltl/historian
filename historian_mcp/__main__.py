#!/usr/bin/env python3

import json
import pathlib
import signal
import sys

import anyio
import anyio.abc
import mcp.os.posix.utilities
import mcp.server.mcpserver
import mcp.server.mcpserver.exceptions
import mcp.server.mcpserver.tools
import mcp.types
import yaml


async def ask(query: str) -> dict[str, object]:
    # Prefer the embedded version when packaged and fallback to repo version.
    try:
        with anyio.CancelScope(shield=True):
            proc: anyio.abc.Process = await anyio.open_process(
                [
                    cmd
                    if (cmd := pathlib.Path(__file__).resolve().parent / "scripts" / "mem_ask.sh").is_file()
                    else pathlib.Path(__file__).resolve().parents[1] / "scripts" / "mem_ask.sh"
                ],
                stderr=None,
                start_new_session=True,
            )
        try:
            await proc.stdin.send(query.encode("utf-8"))
            await proc.stdin.aclose()
            out: bytearray = bytearray()
            async for buf in proc.stdout:
                out.extend(buf)
            if await proc.wait() != 0:
                raise RuntimeError("Search subprocess failed.")
            res: bool | dict | float | int | list | str | None = json.loads(out)
            assert isinstance(res, dict)
            assert all(isinstance(i, str) for i in res.keys())
            return res
        finally:
            with anyio.CancelScope(shield=True):
                await mcp.os.posix.utilities.terminate_posix_process_tree(proc, 30.0)
                await proc.aclose()
    except Exception as err:
        raise mcp.server.mcpserver.exceptions.ToolError(str(err)) from err


skill_text: str = (
    skill
    if (skill := pathlib.Path(__file__).resolve().parent / ".agents" / "skills" / "historian-ask" / "SKILL.md").is_file()
    else pathlib.Path(__file__).resolve().parents[1] / ".agents" / "skills" / "historian-ask" / "SKILL.md"
).read_text(encoding="utf-8")

srv: mcp.server.mcpserver.MCPServer = mcp.server.mcpserver.MCPServer(
    "historian",
    version="0.1.0",
    instructions=next(yaml.safe_load_all(skill_text))["description"],
    tools=[
        mcp.server.mcpserver.tools.Tool.from_function(
            ask,
            name="historian_ask",
            title="Ask Historian",
            description=skill_text,
            annotations=mcp.types.ToolAnnotations(read_only_hint=True, destructive_hint=False, open_world_hint=True),
        )
    ],
    log_level="WARNING",
)


async def run() -> None:
    async with anyio.create_task_group() as tasks:
        async def stop() -> None:
            with anyio.open_signal_receiver(signal.SIGINT, signal.SIGTERM) as sigs:
                async for _ in sigs:
                    tasks.cancel_scope.cancel()
                    return
        tasks.start_soon(stop)
        await srv.run_stdio_async()
        tasks.cancel_scope.cancel()


def main() -> int:
    anyio.run(run)
    return 0


if __name__ == "__main__":
    sys.exit(main())
