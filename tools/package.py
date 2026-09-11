#!/usr/bin/env python3
"""Package the editable Godot project without generated caches or Blender backups."""
import argparse
import hashlib
import json
from pathlib import Path
import tempfile
import zipfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, help="Destination .zip; omit to inspect contents only")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    files = []
    for path in sorted(root.rglob("*")):
        relative = path.relative_to(root)
        if path.is_symlink() or not path.is_file():
            continue
        if any((part.startswith(".") and part != ".gdignore") or part == "__pycache__" for part in relative.parts):
            continue
        if path.suffix in (".blend1", ".blend2", ".pyc", ".zip"):
            continue
        if relative.as_posix() == "PACKAGE-MANIFEST.json":
            continue
        files.append(path)
    total = sum(path.stat().st_size for path in files)
    print(f"{len(files)} files, {total / 1024 / 1024:.2f} MiB before compression")
    if args.output is None:
        return
    args.output.parent.mkdir(parents=True, exist_ok=True)
    manifest = {"project": root.name, "files": []}
    with tempfile.NamedTemporaryFile(dir=args.output.parent, suffix=".zip", delete=False) as temp:
        temporary = Path(temp.name)
    try:
        with zipfile.ZipFile(temporary, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
            for path in files:
                content = path.read_bytes()
                relative = path.relative_to(root).as_posix()
                archive.writestr(root.name + "/" + relative, content)
                manifest["files"].append({"path": relative, "bytes": len(content),
                                          "sha256": hashlib.sha256(content).hexdigest()})
            archive.writestr(root.name + "/PACKAGE-MANIFEST.json", json.dumps(manifest, indent=2) + "\n")
        with zipfile.ZipFile(temporary) as archive:
            bad_file = archive.testzip()
            if bad_file is not None:
                raise RuntimeError("Archive integrity failed: " + bad_file)
        temporary.replace(args.output)
    finally:
        temporary.unlink(missing_ok=True)
    print(f"Archive verified: {args.output}")


if __name__ == "__main__":
    main()
