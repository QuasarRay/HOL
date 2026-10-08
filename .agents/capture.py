#!/usr/bin/env python3
"""Aegis exposed-event capture with a durable outbox when PostgreSQL is unavailable."""
import argparse
import json
import os
from pathlib import Path
import sys
import uuid

ROOT = Path(__file__).resolve().parent
sys.path[:0] = [str(ROOT), str(ROOT / "infra")]
from agentinfra.atomic import atomic_write_bytes
from database.codec import canonical


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--task", required=True)
    p.add_argument("--event", type=Path, required=True)
    a = p.parse_args()
    import re
    if not re.fullmatch(r"[a-z][a-z0-9-]{0,95}", a.task):
        raise ValueError("invalid task name")
    event = json.loads(a.event.read_text())
    if not isinstance(event, dict) or not isinstance(event.get("kind"), str):
        raise ValueError("event must be an object with a kind")
    if event["kind"] in {"private_reasoning", "analysis", "chain_of_thought"}:
        raise ValueError("only exposed events may be captured")
    packet = {"task": a.task, "event_id": str(uuid.uuid4()), "event_text": canonical(event)}
    path = ROOT / "data/pending" / a.task / (packet["event_id"] + ".json")
    atomic_write_bytes(path, (canonical(packet) + "\n").encode(), root=ROOT)
    status = "BLOCKED_POSTGRESQL"
    error = "AEGIS_TASK_DSN is not configured; packet retained for Store.recover()"
    if os.environ.get("AEGIS_TASK_DSN"):
        from database.store import Store
        store = Store(os.environ["AEGIS_TASK_DSN"], ROOT, a.task)
        try:
            store.recover()
            status, error = "EXPORTED", None
        finally:
            store.close()
    receipt = {"status": status, "pending_event": str(path.relative_to(ROOT)),
               "error": error, "claim": "exposed event capture only; not proof evidence"}
    print(json.dumps(receipt))
    return 0 if status == "EXPORTED" else 2


if __name__ == "__main__":
    raise SystemExit(main())
