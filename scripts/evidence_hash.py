#!/usr/bin/env python3
"""
evidence_hash.py - create and verify SHA-256 manifests for evidence folders.

Usage:
  Generate manifest (JSON + text):
    ./evidence_hash.py /path/to/evidence --output manifest_folder
  Verify against existing manifest:
    ./evidence_hash.py --verify manifest.json /path/to/evidence
"""

import argparse, hashlib, json, os, sys, pathlib, getpass, socket, datetime, subprocess

BUF_SIZE = 4 * 1024 * 1024  # 4MB buffer size

def sha256_of_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(BUF_SIZE), b""):
            h.update(chunk)
    return h.hexdigest()

def gather_files(root):
    root = pathlib.Path(root).expanduser().resolve()
    ignore_names = {"hash_manifest.json", "hash_manifest.txt"}
    files = []
    for p in root.rglob("*"):
        if p.is_file() and p.name not in ignore_names:
            files.append((p, p.relative_to(root)))
    return root, sorted(files, key=lambda x: str(x[1]))

def get_git_commit(root):
    try:
        res = subprocess.run(["git", "-C", str(root), "rev-parse", "HEAD"],
                             capture_output=True, text=True, timeout=3)
        return res.stdout.strip() if res.returncode == 0 else None
    except Exception:
        return None

def make_manifest(root_path, output_dir=None):
    root, files = gather_files(root_path)
    manifest = {
        "generated_at": datetime.datetime.utcnow().isoformat() + "Z",
        "user": getpass.getuser(),
        "hostname": socket.gethostname(),
        "root": str(root),
        "file_count": len(files),
        "git_commit": get_git_commit(root),
        "files": []
    }
    if os.environ.get("SEVERFORGE_SHOW_EASTER_EGG") == "1":
        manifest["severforge_easter"] = "🐟 You found the hidden note — keep forging, Amish & Pisces!"

    for p, rel in files:
        try:
            manifest["files"].append({
                "path": str(rel),
                "sha256": sha256_of_file(p),
                "size": p.stat().st_size
            })
        except Exception as e:
            manifest.setdefault("errors", []).append({"path": str(rel), "error": str(e)})

    outdir = pathlib.Path(output_dir or root).expanduser().resolve()
    outdir.mkdir(parents=True, exist_ok=True)
    json_path = outdir / "hash_manifest.json"
    txt_path = outdir / "hash_manifest.txt"
    with open(json_path, "w") as jf:
        json.dump(manifest, jf, indent=2)
    with open(txt_path, "w") as tf:
        for f in manifest["files"]:
            tf.write(f"{f['sha256']}  {f['path']}\n")
    print(f"[+] Manifest written to {json_path}")
    print(f"[+] Text manifest written to {txt_path}")

def verify_manifest(manifest_path, folder):
    manifest_path = pathlib.Path(manifest_path).expanduser().resolve()
    folder, files = gather_files(folder)
    with open(manifest_path, "r") as f:
        ref = json.load(f)
    ref_index = {r["path"]: r["sha256"] for r in ref.get("files", [])}
    mismatches = []
    for p, rel in files:
        h = sha256_of_file(p)
        rels = str(rel)
        if rels not in ref_index:
            mismatches.append(f"NEW FILE: {rels}")
        elif ref_index[rels] != h:
            mismatches.append(f"HASH MISMATCH: {rels}")
    for rpath in ref_index:
        if not (folder / rpath).exists():
            mismatches.append(f"MISSING FILE: {rpath}")
    if mismatches:
        print("❌ Verification failed:")
        for m in mismatches:
            print("  -", m)
        sys.exit(2)
    print("✅ Verification OK")

def main():
    p = argparse.ArgumentParser(description="Generate or verify SHA-256 evidence manifests.")
    p.add_argument("path", nargs="?", help="Path to folder")
    p.add_argument("--output", "-o", help="Output directory (default: same as folder)")
    p.add_argument("--verify", "-v", help="Manifest JSON to verify against")
    args = p.parse_args()

    if args.verify:
        verify_manifest(args.verify, args.path)
    elif args.path:
        make_manifest(args.path, args.output)
    else:
        p.print_help()

if __name__ == "__main__":
    main()
