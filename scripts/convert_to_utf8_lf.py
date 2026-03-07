#!/usr/bin/env python3
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
    args = parser.parse_args()

    root = Path(args.root).resolve()
    if not root.is_dir():
        print(f"Error: '{root}' is not a directory.", file=sys.stderr)
        sys.exit(1)

    if args.dry_run:
        print(f"[DRY RUN] Scanning: {root}\n")
    else:
        print(f"Scanning: {root}\n")

    total = converted = skipped = errors = 0

    for dirpath, dirnames, filenames in os.walk(root):
        # Prune skipped directories in-place so os.walk won't descend into them
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]

        for filename in sorted(filenames):
            path = Path(dirpath) / filename
            total += 1

            if not is_text_file(path):
                skipped += 1
                if args.verbose:
                    print(f"  SKIP (binary)  {path.relative_to(root)}")
                continue

            changed, msg = convert_file(path, dry_run=args.dry_run)

            if "ERROR" in msg:
                errors += 1
                print(f"  {msg:<30} {path.relative_to(root)}")
            elif changed:
                converted += 1
                print(f"  {msg:<30} {path.relative_to(root)}")
            else:
                skipped += 1
                if args.verbose:
                    print(f"  {msg:<30} {path.relative_to(root)}")

    print(f"\n{'[DRY RUN] ' if args.dry_run else ''}Done.")
    print(f"  Total files : {total}")
    print(f"  Converted   : {converted}")
    print(f"  Skipped     : {skipped}")
    print(f"  Errors      : {errors}")


if __name__ == "__main__":
    main()
