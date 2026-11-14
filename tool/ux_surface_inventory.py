"""Read-only heuristic UX surface inventory; candidates are not review coverage."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import subprocess


ROOT = Path(__file__).resolve().parent.parent
CLASSES = re.compile(r"\bclass\s+([A-Z]\w*(?:Page|Screen|Dialog|Sheet))\b")
ENTRY = re.compile(r"\b(?:showDialog|showModalBottomSheet|showMenu)\s*(?:<[^>]+>)?\s*\(")


def inventory(root: Path) -> dict:
    surfaces = []
    calls = []
    scanned = 0
    for file in sorted((root / "lib").rglob("*.dart")):
        if file.name.endswith((".g.dart", ".freezed.dart")):
            continue
        source = file.read_text(encoding="utf-8-sig")
        scanned += 1
        relative = file.relative_to(root).as_posix()
        digest = hashlib.sha256(source.replace("\r\n", "\n").encode()).hexdigest()
        for match in CLASSES.finditer(source):
            surfaces.append({
                "id": f"{relative}::{match[1]}", "name": match[1], "file": relative,
                "line": source.count("\n", 0, match.start()) + 1,
                "sourceSha256": digest, "reviewStatus": "not-reviewed",
            })
        for match in ENTRY.finditer(source):
            calls.append({"file": relative, "line": source.count("\n", 0, match.start()) + 1})
    commit = subprocess.run(
        ["git", "rev-parse", "HEAD"], cwd=root, capture_output=True, text=True, check=True,
    ).stdout.strip()
    return {
        "schemaVersion": 1, "commit": commit, "method": "heuristic-regex-not-parser",
        "limitations": [
            "May include comments, strings, unused code or non-route widgets.",
            "Can miss dynamic/anonymous/conditionally reachable surfaces; verify in execution.",
            "A candidate is not evidence of inspection, reachability or completeness.",
        ],
        "scannedDartFiles": scanned, "surfaceCandidates": surfaces,
        "overlayCallCandidates": calls,
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    target = args.output.resolve()
    target.relative_to((ROOT / ".dart_tool").resolve())
    if target.exists():
        raise ValueError("Output exists; choose a new file to preserve previous evidence")
    data = inventory(ROOT)
    target.parent.mkdir(parents=True, exist_ok=True)
    with target.open("x", encoding="utf-8") as output:
        json.dump(data, output, ensure_ascii=False, indent=2)
        output.write("\n")
    print(f"Inventory generated: {len(data['surfaceCandidates'])} candidates; none marked reviewed.")


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        raise SystemExit(f"UX inventory failed: {error}")
