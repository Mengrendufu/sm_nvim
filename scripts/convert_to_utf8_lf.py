#!/usr/bin/env python3
import curses
import os
import sys
from pathlib import Path

CANDIDATE_ENCODINGS = [
    "utf-8",
    "utf-8-sig",
    "gbk",
    "gb2312",
    "gb18030",
    "big5",
    "latin-1",
    "iso-8859-1",
    "cp1252",
]

TEXT_EXTENSIONS = {
    ".txt", ".md", ".rst", ".csv", ".tsv", ".log",
    ".py", ".pyw",
    ".js", ".ts", ".jsx", ".tsx", ".mjs", ".cjs",
    ".html", ".htm", ".xhtml",
    ".xml", ".svg", ".xsd", ".xsl",
    ".json", ".jsonc", ".json5",
    ".yaml", ".yml",
    ".toml", ".ini", ".cfg", ".conf", ".env",
    ".sh", ".bash", ".zsh", ".fish",
    ".bat", ".cmd", ".ps1",
    ".c", ".cc", ".cpp", ".cxx", ".h", ".hpp",
    ".cs", ".java", ".kt", ".go", ".rs", ".rb",
    ".php", ".pl", ".pm", ".lua", ".r",
    ".sql", ".graphql", ".proto",
    ".css", ".scss", ".sass", ".less",
    ".makefile", ".mk", "",
}

SKIP_DIRS = {".git", ".svn", ".hg", "__pycache__", "node_modules", ".venv", "venv"}


# ─────────────────────────── interactive picker ──────────────────────────────

def _pick_dirs_curses(stdscr, dirs: list[str]) -> list[str]:
    curses.curs_set(0)
    curses.use_default_colors()
    curses.init_pair(1, curses.COLOR_BLACK, curses.COLOR_CYAN)   # highlighted row
    curses.init_pair(2, curses.COLOR_GREEN, -1)                  # checked mark
    curses.init_pair(3, curses.COLOR_YELLOW, -1)                 # title

    checked = [False] * len(dirs)
    cursor = 0
    offset = 0  # scroll offset

    HEADER_LINES = 3
    FOOTER_LINES = 2

    while True:
        stdscr.erase()
        h, w = stdscr.getmaxyx()
        visible = h - HEADER_LINES - FOOTER_LINES

        # ── header ──
        title = " Select subdirectories to process "
        stdscr.addstr(0, max(0, (w - len(title)) // 2), title, curses.color_pair(3) | curses.A_BOLD)
        stdscr.addstr(1, 0, "─" * (w - 1))
        stdscr.addstr(2, 2, f"{'[x] = selected  [ ] = unselected':40}  {sum(checked)}/{len(dirs)} selected")

        # ── list ──
        for i in range(visible):
            idx = offset + i
            if idx >= len(dirs):
                break
            row = HEADER_LINES + i
            mark = "[x]" if checked[idx] else "[ ]"
            label = f"  {mark}  {dirs[idx]}"
            label = label[: w - 1]
            if idx == cursor:
                stdscr.addstr(row, 0, label.ljust(w - 1), curses.color_pair(1))
            else:
                attr = curses.color_pair(2) if checked[idx] else curses.A_NORMAL
                stdscr.addstr(row, 0, label, attr)

        # ── footer ──
        footer_row = h - FOOTER_LINES
        stdscr.addstr(footer_row, 0, "─" * (w - 1))
        hints = " ↑/↓ move   SPACE toggle   A all   N none   ENTER confirm   q quit "
        stdscr.addstr(footer_row + 1, max(0, (w - len(hints)) // 2), hints)

        stdscr.refresh()

        key = stdscr.getch()

        if key in (curses.KEY_UP, ord("k")):
            if cursor > 0:
                cursor -= 1
                if cursor < offset:
                    offset = cursor
        elif key in (curses.KEY_DOWN, ord("j")):
            if cursor < len(dirs) - 1:
                cursor += 1
                if cursor >= offset + visible:
                    offset = cursor - visible + 1
        elif key == ord(" "):
            checked[cursor] = not checked[cursor]
        elif key in (ord("a"), ord("A")):
            checked = [True] * len(dirs)
        elif key in (ord("n"), ord("N")):
            checked = [False] * len(dirs)
        elif key in (curses.KEY_ENTER, ord("\n"), ord("\r")):
            break
        elif key in (ord("q"), ord("Q"), 27):
            return []

    return [dirs[i] for i, v in enumerate(checked) if v]


def pick_subdirs(root: Path) -> list[str] | None:
    """
    List immediate subdirectories of *root* (excluding SKIP_DIRS),
    let the user pick interactively.

    Returns:
        list of selected dir names — may be empty if user selected none.
        None if the user cancelled (q / Esc) or there are no subdirs.
    """
    subdirs = sorted(
        d.name
        for d in root.iterdir()
        if d.is_dir() and d.name not in SKIP_DIRS
    )
    if not subdirs:
        return None

    try:
        selected = curses.wrapper(_pick_dirs_curses, subdirs)
    except KeyboardInterrupt:
        return None

    return selected


# ──────────────────────────── core conversion ────────────────────────────────

def is_text_file(path: Path) -> bool:
    if path.suffix.lower() in TEXT_EXTENSIONS:
        return True
    try:
        chunk = path.read_bytes()[:8192]
        return b"\x00" not in chunk
    except OSError:
        return False


def detect_encoding(raw: bytes) -> str | None:
    for enc in CANDIDATE_ENCODINGS:
        try:
            raw.decode(enc)
            return enc
        except (UnicodeDecodeError, LookupError):
            continue
    return None


def convert_file(path: Path, dry_run: bool = False) -> tuple[bool, str]:
    try:
        raw = path.read_bytes()
    except OSError as e:
        return False, f"ERROR reading: {e}"

    encoding = detect_encoding(raw)
    if encoding is None:
        return False, "SKIP (undetectable encoding / binary)"

    try:
        text = raw.decode(encoding)
    except (UnicodeDecodeError, LookupError) as e:
        return False, f"ERROR decoding ({encoding}): {e}"

    text = text.lstrip("\ufeff") if encoding == "utf-8-sig" else text

    new_text = text.replace("\r\n", "\n").replace("\r", "\n")
    new_raw = new_text.encode("utf-8")

    changed = new_raw != raw
    if not changed:
        return False, "OK (already UTF-8 LF)"

    if not dry_run:
        try:
            path.write_bytes(new_raw)
        except OSError as e:
            return False, f"ERROR writing: {e}"

    detail_parts = []
    if encoding not in ("utf-8", "utf-8-sig"):
        detail_parts.append(f"{encoding}→UTF-8")
    if b"\r" in raw:
        detail_parts.append("CRLF→LF")
    detail = ", ".join(detail_parts) if detail_parts else "changed"
    return True, f"CONVERTED ({detail})"


def scan_and_convert(
    root: Path,
    scan_roots: list[Path],
    dry_run: bool,
    verbose: bool,
) -> None:
    if dry_run:
        print(f"[DRY RUN] Scanning: {root}\n")
    else:
        print(f"Scanning: {root}\n")

    total = converted = skipped = errors = 0

    for scan_root in scan_roots:
        for dirpath, dirnames, filenames in os.walk(scan_root):
            dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
            for filename in sorted(filenames):
                path = Path(dirpath) / filename
                total += 1

                if not is_text_file(path):
                    skipped += 1
                    if verbose:
                        print(f"  SKIP (binary)  {path.relative_to(root)}")
                    continue

                changed, msg = convert_file(path, dry_run=dry_run)

                if "ERROR" in msg:
                    errors += 1
                    print(f"  {msg:<30} {path.relative_to(root)}")
                elif changed:
                    converted += 1
                    print(f"  {msg:<30} {path.relative_to(root)}")
                else:
                    skipped += 1
                    if verbose:
                        print(f"  {msg:<30} {path.relative_to(root)}")

    print(f"\n{'[DRY RUN] ' if dry_run else ''}Done.")
    print(f"  Total files : {total}")
    print(f"  Converted   : {converted}")
    print(f"  Skipped     : {skipped}")
    print(f"  Errors      : {errors}")


# ────────────────────────────────── main ─────────────────────────────────────

def main() -> None:
    import argparse

    parser = argparse.ArgumentParser(
        description="Recursively convert text files to UTF-8 + LF line endings."
    )
    parser.add_argument(
        "root",
        nargs="?",
        default=".",
        help="Root directory to process (default: current directory)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Preview changes without writing files",
    )
    parser.add_argument(
        "--verbose",
        "-v",
        action="store_true",
        help="Print every file, not just changed ones",
    )
    parser.add_argument(
        "--no-pick",
        action="store_true",
        help="Skip subdirectory picker and process the entire root directly",
    )
    args = parser.parse_args()

    root = Path(args.root).resolve()
    if not root.is_dir():
        print(f"Error: '{root}' is not a directory.", file=sys.stderr)
        sys.exit(1)

    # ── subdirectory picker ──────────────────────────────────────────────────
    if args.no_pick:
        scan_roots = [root]
    else:
        selected = pick_subdirs(root)

        if selected is None:
            print("No subdirectories found (or cancelled). Processing entire root.")
            scan_roots = [root]
        elif len(selected) == 0:
            print("No directories selected. Nothing to do.")
            sys.exit(0)
        else:
            print(f"Selected: {', '.join(selected)}\n")
            scan_roots = [root / d for d in selected]

    # ── convert ─────────────────────────────────────────────────────────────
    scan_and_convert(root, scan_roots, dry_run=args.dry_run, verbose=args.verbose)


if __name__ == "__main__":
    main()
