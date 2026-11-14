"""Read-only consistency check of a declared UX review plan, not an app audit."""

from __future__ import annotations

import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re


METHODS = {
    "layout": {"screenshot", "widget-test", "integration-test", "manual-interaction"},
    "interaction": {"widget-test", "integration-test", "manual-interaction"},
    "semantics": {"widget-test", "integration-test", "semantics-dump", "assistive-test"},
    "assistive": {"assistive-test"},
    "content": {"screenshot", "widget-test", "integration-test", "manual-interaction", "static-inspection"},
    "performance": {"measurement"},
}
CONDITIONS = {
    "platform", "widthDp", "heightDp", "dpr", "textScale", "locale", "palette",
    "brightness", "font", "sdk", "os", "renderer", "fixture", "clock",
    "animation", "assets", "buildMode",
}
STATUSES = {"pass", "fail", "blocked", "not-run", "not-applicable"}


def require(condition: bool, message: str) -> None:
    if not condition:
        raise ValueError(message)


def nonempty(value: object) -> bool:
    return isinstance(value, str) and bool(value.strip())


def keyed(items: list, label: str) -> dict:
    require(isinstance(items, list), f"{label} must be a list")
    result = {}
    for item in items:
        require(isinstance(item, dict) and nonempty(item.get("id")), f"{label}: missing id")
        require(item["id"] not in result, f"{label}: duplicate id {item['id']}")
        result[item["id"]] = item
    return result


def check_conditions(values: dict) -> None:
    require(isinstance(values, dict) and set(values) == CONDITIONS, "Conditions must contain exactly the documented fields")
    for key in ("widthDp", "heightDp", "dpr", "textScale"):
        require(type(values[key]) in (int, float) and 0 < values[key] < float("inf"), f"Invalid {key}")
    for key in CONDITIONS - {"widthDp", "heightDp", "dpr", "textScale"}:
        require(nonempty(values[key]), f"Empty condition: {key}")


def validate(manifest: Path) -> dict:
    root = manifest.resolve().parent
    data = json.loads(manifest.read_text(encoding="utf-8-sig"))
    require(isinstance(data, dict) and type(data.get("schemaVersion")) is int and data["schemaVersion"] == 1, "Unsupported schemaVersion")
    require(nonempty(data.get("scope")), "Declare the scope; this is not whole-app coverage")
    baselines = data.get("baselines", {})
    require(isinstance(baselines, dict) and set(baselines) == {"before", "after"}, "Declare before/after baselines")
    for baseline in baselines.values():
        require(isinstance(baseline, dict), "Invalid baseline")
        require(bool(re.fullmatch(r"[0-9a-f]{40}|[0-9a-f]{64}", baseline.get("commit", ""))), "Invalid baseline commit")
        require(bool(re.fullmatch(r"clean|sha256:[0-9a-f]{64}", baseline.get("worktree", ""))), "Declare clean worktree or snapshot digest")
    cases = keyed(data.get("cases", []), "cases")
    require(bool(cases), "A declared plan needs at least one case")
    for case in cases.values():
        check_conditions(case.get("conditions"))
        require(nonempty(case.get("criterion")), f"Missing criterion: {case['id']}")
        checks = case.get("requiredChecks", [])
        require(isinstance(checks, list) and bool(checks) and all(isinstance(c, str) for c in checks), "Declare requiredChecks")
        require(len(set(checks)) == len(checks) and set(checks) <= METHODS.keys(), "Unknown or duplicate required check")

    evidence = keyed(data.get("evidence", []), "evidence")
    for item in evidence.values():
        require(item.get("method") in set().union(*METHODS.values()), f"Unknown evidence method: {item['id']}")
        require(nonempty(item.get("path")) and not Path(item["path"]).is_absolute(), "Evidence paths must be relative to manifest")
        path = (root / item["path"]).resolve()
        path.relative_to(root)
        require(path.is_file(), f"Missing evidence: {item['id']}")
        digest = hashlib.sha256(path.read_bytes()).hexdigest()
        require(digest == item.get("sha256"), f"Evidence content changed: {item['id']}")

    records = {}
    observations = data.get("records", [])
    require(isinstance(observations, list), "records must be a list")
    for record in observations:
        require(isinstance(record, dict), "Invalid record")
        case_id, phase = record.get("caseId"), record.get("phase")
        require(case_id in cases and phase in baselines, "Record refers to unknown case/phase")
        key = (case_id, phase)
        require(key not in records, f"Duplicate record: {key}")
        require(record.get("baseline") == baselines[phase], f"Baseline mismatch: {key}")
        require(record.get("conditions") == cases[case_id]["conditions"], f"Conditions mismatch: {key}")
        checks = record.get("checks", {})
        require(isinstance(checks, dict) and set(checks) == set(cases[case_id]["requiredChecks"]), f"Checks differ from plan: {key}")
        for aspect, result in checks.items():
            require(isinstance(result, dict) and result.get("status") in STATUSES, f"Invalid status: {key}/{aspect}")
            status = result["status"]
            refs = result.get("evidenceIds", [])
            require(isinstance(refs, list) and all(isinstance(ref, str) and ref in evidence for ref in refs), "Unknown evidence reference")
            if status in {"pass", "fail"}:
                require(bool(refs), f"Observed result without evidence: {key}/{aspect}")
                require(any(evidence[ref]["method"] in METHODS[aspect] for ref in refs), f"Evidence cannot support {aspect}: {key}")
            else:
                require(nonempty(result.get("reason")), f"Justify {status}: {key}/{aspect}")
        records[key] = record

    totals = {phase: Counter() for phase in baselines}
    for case in cases.values():
        for phase in baselines:
            record = records.get((case["id"], phase))
            for aspect in case["requiredChecks"]:
                status = record["checks"][aspect]["status"] if record else "not-run"
                totals[phase][status] += 1
    unresolved = []
    for case in cases.values():
        before = records.get((case["id"], "before"))
        after = records.get((case["id"], "after"))
        if before and after:
            for aspect in case["requiredChecks"]:
                if before["checks"][aspect]["status"] == "fail" and after["checks"][aspect]["status"] == "not-applicable":
                    unresolved.append(f"{case['id']}/{aspect}: prior failure excluded instead of revalidated")
    # A reproduced defect before the change is expected; exclusion is not a fix.
    complete = (
        not any(totals["before"][s] for s in ("blocked", "not-run"))
        and not any(totals["after"][s] for s in ("fail", "blocked", "not-run"))
        and totals["after"]["pass"] > 0
        and not unresolved
    )
    return {
        "scope": data["scope"], "declaredCases": len(cases),
        "declaredChecksPerPhase": sum(len(c["requiredChecks"]) for c in cases.values()),
        "results": {phase: {status: counts[status] for status in sorted(STATUSES)} for phase, counts in totals.items()},
        "declaredPlanRecorded": complete,
        "unresolved": unresolved,
        "limitation": "Checks metadata, file integrity and method compatibility only. Does not inspect evidence meaning, execute the app, prove plan completeness, or certify accessibility/usability.",
    }


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path)
    args = parser.parse_args()
    result = validate(args.manifest)
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 0 if result["declaredPlanRecorded"] else 2


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, TypeError, KeyError) as error:
        raise SystemExit(f"Invalid UX evidence manifest: {error}")
