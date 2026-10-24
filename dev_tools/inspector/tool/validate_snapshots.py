"""Validate test exports against the adopted schema; never log instance values."""
import json
from pathlib import Path

import jsonschema

root = Path(__file__).resolve().parents[3]
schema = json.loads((root / "docs/reference/identity/p2e-ui-inspector-snapshot.schema.json").read_text(encoding="utf-8"))
snapshots = json.loads((root / "build/inspector-v1.1/snapshots.json").read_text(encoding="utf-8"))
validator = jsonschema.Draft202012Validator(schema)
for index, snapshot in enumerate(snapshots):
    errors = list(validator.iter_errors(snapshot))
    if errors:
        raise SystemExit(f"Snapshot {index}: schema violation at {list(errors[0].path)}")
print(f"{len(snapshots)} snapshots valid against adopted schema; zero errors.")
