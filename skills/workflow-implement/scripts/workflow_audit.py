from __future__ import annotations

import argparse
import html
import json
import os
import subprocess
import time
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, List, Tuple


def _iso_now() -> str:
    return datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")


def _load_state(state_path: Path) -> Dict[str, Any]:
    if not state_path.exists():
        return {"next_step_id": 1}
    try:
        data = json.loads(state_path.read_text(encoding="utf-8"))
        if not isinstance(data, dict):
            return {"next_step_id": 1}
        return data
    except Exception:
        return {"next_step_id": 1}


def _save_state(state_path: Path, state: Dict[str, Any]) -> None:
    state_path.parent.mkdir(parents=True, exist_ok=True)
    state_path.write_text(json.dumps(state, ensure_ascii=False), encoding="utf-8")


def allocate_step_id(state_path: Path) -> str:
    state = _load_state(state_path)
    raw_value = state.get("next_step_id", 1)
    try:
        step_num = int(raw_value)
    except (TypeError, ValueError):
        step_num = 1

    step_id = f"{step_num:04d}"
    state["next_step_id"] = step_num + 1
    _save_state(state_path, state)
    return step_id


def _compute_diff(cwd: Path) -> Tuple[Dict[str, Any], str]:
    diff_stat = {"files": 0, "additions": 0, "deletions": 0, "file_list": []}

    numstat = subprocess.run(
        ["git", "diff", "--numstat"],
        cwd=cwd,
        text=True,
        capture_output=True,
    )

    if numstat.returncode not in (0, 1):
        return diff_stat, ""

    for line in numstat.stdout.strip().splitlines():
        if not line.strip():
            continue
        parts = line.split("\t", 2)
        if len(parts) < 3:
            continue
        additions_raw, deletions_raw, path = parts
        diff_stat["files"] += 1
        if additions_raw.isdigit():
            diff_stat["additions"] += int(additions_raw)
        if deletions_raw.isdigit():
            diff_stat["deletions"] += int(deletions_raw)
        diff_stat["file_list"].append(path)

    untracked_files: List[str] = []
    status = subprocess.run(
        ["git", "status", "--porcelain=v1"],
        cwd=cwd,
        text=True,
        capture_output=True,
    )
    if status.returncode in (0, 1):
        for line in status.stdout.splitlines():
            if line.startswith("?? "):
                untracked_files.append(line[3:])

    for path in untracked_files:
        diff_stat["files"] += 1
        diff_stat["file_list"].append(path)
        file_path = cwd / path
        try:
            additions = len(file_path.read_text(encoding="utf-8").splitlines())
        except Exception:
            additions = 0
        diff_stat["additions"] += additions

    patch_proc = subprocess.run(
        ["git", "diff"],
        cwd=cwd,
        text=True,
        capture_output=True,
    )

    patch_parts = [patch_proc.stdout]
    for path in untracked_files:
        patch_parts.append(
            subprocess.run(
                ["git", "diff", "--no-index", "/dev/null", path],
                cwd=cwd,
                text=True,
                capture_output=True,
            ).stdout
        )

    return diff_stat, "".join(patch_parts)


def _append_jsonl(path: Path, entry: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("a", encoding="utf-8") as handle:
        handle.write(json.dumps(entry, ensure_ascii=False) + "\n")


def run_step(
    ledger_path: Path,
    artifacts_dir: Path,
    step_id: str,
    kind: str,
    cmd: List[str],
    cwd: Path,
) -> Dict[str, Any]:
    if not cmd:
        raise ValueError("cmd is required")

    artifacts_dir.mkdir(parents=True, exist_ok=True)
    ledger_path.parent.mkdir(parents=True, exist_ok=True)

    started_at = _iso_now()
    started_ts = time.time()
    proc = subprocess.run(cmd, cwd=cwd, text=True, capture_output=True)
    ended_at = _iso_now()
    duration_ms = int((time.time() - started_ts) * 1000)

    output_path = artifacts_dir / f"{step_id}.output"
    output_path.write_text(proc.stdout + proc.stderr, encoding="utf-8")

    diff_stat, patch = _compute_diff(cwd)
    patch_path = artifacts_dir / f"{step_id}.patch"
    patch_path.write_text(patch, encoding="utf-8")

    rel_patch = os.path.relpath(patch_path, ledger_path.parent)
    rel_output = os.path.relpath(output_path, ledger_path.parent)

    entry = {
        "step_id": step_id,
        "kind": kind,
        "cmd": cmd,
        "cwd": str(cwd),
        "started_at": started_at,
        "ended_at": ended_at,
        "duration_ms": duration_ms,
        "exit_code": proc.returncode,
        "diff_stat": diff_stat,
        "artifacts": {"patch": rel_patch, "output": rel_output},
    }

    _append_jsonl(ledger_path, entry)
    return entry


def run_step_auto(
    ledger_path: Path,
    artifacts_dir: Path,
    state_path: Path,
    kind: str,
    cmd: List[str],
    cwd: Path,
) -> Dict[str, Any]:
    step_id = allocate_step_id(state_path)
    return run_step(
        ledger_path=ledger_path,
        artifacts_dir=artifacts_dir,
        step_id=step_id,
        kind=kind,
        cmd=cmd,
        cwd=cwd,
    )


def render_html(ledger_path: Path, output_path: Path, title: str = "Workflow Audit") -> None:
    entries: List[Dict[str, Any]] = []
    if ledger_path.exists():
        for line in ledger_path.read_text(encoding="utf-8").splitlines():
            if not line.strip():
                continue
            entries.append(json.loads(line))

    base_dir = ledger_path.parent

    def read_artifact(rel_path: str) -> str:
        artifact_path = base_dir / rel_path
        if not artifact_path.exists():
            return "<missing>"
        return artifact_path.read_text(encoding="utf-8")

    rows = []
    for entry in entries:
        patch = read_artifact(entry.get("artifacts", {}).get("patch", ""))
        output = read_artifact(entry.get("artifacts", {}).get("output", ""))
        cmd = " ".join(entry.get("cmd", []))
        rows.append(
            f"""
            <section class=\"step\">
              <header>
                <h3>Step {html.escape(entry.get("step_id", ""))} · {html.escape(entry.get("kind", ""))}</h3>
                <div class=\"meta\">
                  <span>Exit: {entry.get("exit_code", "")}</span>
                  <span>Files: {entry.get("diff_stat", {}).get("files", 0)}</span>
                  <span>+{entry.get("diff_stat", {}).get("additions", 0)} / -{entry.get("diff_stat", {}).get("deletions", 0)}</span>
                </div>
                <div class=\"cmd\">{html.escape(cmd)}</div>
              </header>
              <details>
                <summary>Patch</summary>
                <pre>{html.escape(patch)}</pre>
              </details>
              <details>
                <summary>Output</summary>
                <pre>{html.escape(output)}</pre>
              </details>
            </section>
            """
        )

    html_doc = f"""<!doctype html>
<html lang=\"en\">
<head>
  <meta charset=\"utf-8\" />
  <title>{html.escape(title)}</title>
  <style>
    body {{ font-family: -apple-system, system-ui, sans-serif; margin: 24px; color: #111; background: #f8fafc; }}
    h1 {{ margin-bottom: 16px; }}
    .step {{ background: #fff; border-radius: 12px; padding: 16px; margin-bottom: 16px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); }}
    .meta {{ display: flex; gap: 12px; font-size: 12px; color: #475569; margin-top: 4px; }}
    .cmd {{ margin-top: 8px; font-family: ui-monospace, SFMono-Regular, Menlo, monospace; font-size: 12px; color: #0f172a; }}
    pre {{ background: #0f172a; color: #e2e8f0; padding: 12px; border-radius: 8px; overflow-x: auto; }}
    details {{ margin-top: 12px; }}
    summary {{ cursor: pointer; font-weight: 600; }}
  </style>
</head>
<body>
  <h1>{html.escape(title)}</h1>
  {"".join(rows) if rows else "<p>No ledger entries found.</p>"}
</body>
</html>"""

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(html_doc, encoding="utf-8")


def _parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Workflow audit utilities")
    sub = parser.add_subparsers(dest="command", required=True)

    run_parser = sub.add_parser("run", help="Run a command and append a ledger entry")
    run_parser.add_argument("--ledger", required=True)
    run_parser.add_argument("--artifacts", required=True)
    run_parser.add_argument("--step-id")
    run_parser.add_argument("--state")
    run_parser.add_argument("--kind", default="run")
    run_parser.add_argument("--cwd", default=".")
    run_parser.add_argument("cmd", nargs=argparse.REMAINDER)

    render_parser = sub.add_parser("render", help="Render ledger to HTML")
    render_parser.add_argument("--ledger", required=True)
    render_parser.add_argument("--output", required=True)
    render_parser.add_argument("--title", default="Workflow Audit")

    return parser.parse_args()


def main() -> int:
    args = _parse_args()
    if args.command == "run":
        cmd = list(args.cmd)
        if cmd and cmd[0] == "--":
            cmd = cmd[1:]
        if not cmd:
            raise SystemExit("command is required after --")
        if args.step_id and args.state:
            raise SystemExit("use either --step-id or --state, not both")
        if not args.step_id and not args.state:
            raise SystemExit("either --step-id or --state is required")

        if args.state:
            entry = run_step_auto(
                ledger_path=Path(args.ledger),
                artifacts_dir=Path(args.artifacts),
                state_path=Path(args.state),
                kind=args.kind,
                cmd=cmd,
                cwd=Path(args.cwd),
            )
        else:
            entry = run_step(
                ledger_path=Path(args.ledger),
                artifacts_dir=Path(args.artifacts),
                step_id=args.step_id,
                kind=args.kind,
                cmd=cmd,
                cwd=Path(args.cwd),
            )

        return int(entry.get("exit_code", 0))

    if args.command == "render":
        render_html(
            ledger_path=Path(args.ledger),
            output_path=Path(args.output),
            title=args.title,
        )
        return 0

    raise SystemExit("unknown command")


if __name__ == "__main__":
    raise SystemExit(main())
