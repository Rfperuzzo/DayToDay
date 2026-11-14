"""Verify the pinned UX skill installation; never download or modify skills."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import sys


ROOT = Path(__file__).resolve().parent.parent
LOCK = ROOT / "docs/UX_SKILLS_LOCK.json"


def fingerprint(directory: Path, normalize_text: bool = False) -> tuple[str, int]:
    digest = hashlib.sha256()
    files = sorted(
        (p for p in directory.rglob("*") if p.is_file()
         and "__pycache__" not in p.parts and p.suffix != ".pyc"),
        key=lambda p: p.relative_to(directory).as_posix(),
    )
    for file in files:
        if file.is_symlink():
            raise ValueError(f"Unexpected symlink: {file}")
        relative = file.relative_to(directory).as_posix()
        content = file.read_bytes()
        if normalize_text and file.suffix in {".md", ".json", ".py", ".yaml", ".yml"}:
            content = file.read_text(encoding="utf-8-sig").encode("utf-8")
        file_hash = hashlib.sha256(content).hexdigest()
        digest.update(f"{relative}\0{file_hash}\n".encode("utf-8"))
    return digest.hexdigest(), len(files)


def run_smoke(skills_dir: Path) -> None:
    search = skills_dir / "ui-ux-pro-max/scripts/search.py"
    for query, option, value, expected_domain in [
        ("text scaling overflow", "--stack", "flutter", "stack"),
        ("error summary validation", "--domain", "ux", "ux"),
    ]:
        result = subprocess.run(
            [sys.executable, "-B", str(search), query, option, value, "--json"],
            capture_output=True, encoding="utf-8", check=True, timeout=30,
        )
        data = json.loads(result.stdout)
        if data.get("domain") != expected_domain or data.get("count", 0) < 1:
            raise ValueError(f"Search returned no relevant domain: {query}")
        if option == "--stack" and data.get("stack") != "flutter":
            raise ValueError("Search did not use Flutter")
    subprocess.run(
        [sys.executable, "-B", str(skills_dir / "webapp-testing/scripts/with_server.py"), "--help"],
        capture_output=True, check=True, timeout=30,
    )
    print("PASS: local Flutter/UX searches and web server helper --help")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--skills-dir", type=Path, default=ROOT / ".cursor/skills")
    parser.add_argument("--smoke", action="store_true", help="Run reviewed local searches and helper --help")
    parser.add_argument("--browser-smoke", action="store_true", help="Check an isolated browser with a synthetic page, not the app")
    parser.add_argument("--python-runtime", type=Path, help="Python with Playwright installed")
    parser.add_argument("--browser", type=Path, help="Installed Chromium executable")
    args = parser.parse_args()
    lock = json.loads(LOCK.read_text(encoding="utf-8"))
    failures = []
    for entry in lock["skills"]:
        name = entry["name"]
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", name):
            raise ValueError("Invalid name in lock")
        directory = args.skills_dir / name
        skill = directory / "SKILL.md"
        if not skill.is_file():
            failures.append(f"Missing skill: {name}")
            continue
        actual, count = fingerprint(directory)
        if actual != entry["treeSha256"] or count != entry["fileCount"]:
            failures.append(f"Skill differs from reviewed version: {name}")
        text = skill.read_text(encoding="utf-8")
        if not re.search(rf"^name: {re.escape(name)}\s*$", text, re.MULTILINE):
            failures.append(f"Metadata name differs: {name}")
    for entry in lock.get("projectSkills", []):
        if not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", entry["name"]):
            raise ValueError("Invalid project skill name in lock")
        source = (ROOT / entry["path"]).resolve()
        source.relative_to((ROOT / ".cursor/skills").resolve())
        installed = args.skills_dir / entry["name"]
        if not (installed / "SKILL.md").is_file():
            failures.append(f"Missing project skill installation: {entry['name']}")
        elif fingerprint(source, True) != fingerprint(installed, True):
            failures.append(f"Project skill differs from repository: {entry['name']}")
    if failures:
        print("\n".join(failures), file=sys.stderr)
        return 1
    print(f"PASS: {len(lock['skills'])} pinned skills and {len(lock.get('projectSkills', []))} project skills verified")
    if args.smoke:
        run_smoke(args.skills_dir)
    if args.browser_smoke:
        runtime = args.python_runtime or Path.home() / ".codex/ux-runtime/Scripts/python.exe"
        browser = args.browser or next((p for p in [
            Path("C:/Program Files/Google/Chrome/Application/chrome.exe"),
            Path("C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"),
            Path(shutil.which("google-chrome") or "/nonexistent-chrome"),
        ] if p.is_file()), None)
        if not runtime.is_file() or browser is None or not browser.is_file():
            raise ValueError("Provide --python-runtime and --browser for this host")
        # Synthetic blank-page interaction: no account, production URL, or user profile.
        script = """
import importlib.metadata,sys
from playwright.sync_api import sync_playwright
assert importlib.metadata.version('playwright') == sys.argv[2], 'Runtime version drift'
with sync_playwright() as p:
    browser=p.chromium.launch(headless=True,executable_path=sys.argv[1])
    try:
        for width,height in [(320,640),(360,740),(1280,800)]:
            page=browser.new_page(viewport={'width':width,'height':height})
            page.set_content('<button>Testar</button>')
            button=page.get_by_role('button',name='Testar')
            button.evaluate("element => element.onclick = () => { element.textContent = 'Confirmado'; }")
            button.focus()
            page.keyboard.press('Enter')
            assert page.get_by_role('button',name='Confirmado').is_visible()
            page.close()
    finally:
        browser.close()
"""
        subprocess.run(
            [str(runtime), "-c", script, str(browser), lock["runtime"]["playwright"]],
            capture_output=True, encoding="utf-8", check=True, timeout=45,
        )
        print("PASS: isolated Chromium/Playwright keyboard smoke at 3 viewport sizes (not an app audit)")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except subprocess.CalledProcessError as error:
        detail = error.stderr or str(error)
        if isinstance(detail, bytes):
            detail = detail.decode("utf-8", errors="replace")
        print(f"UX skill subprocess failed: {detail.strip()}", file=sys.stderr)
        raise SystemExit(1)
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        print(f"UX skill validation failed: {error}", file=sys.stderr)
        raise SystemExit(1)
