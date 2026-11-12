#!/usr/bin/env python3
"""Download TartanAir V2 (see README.md). Usually run through download_tartanair_v2.sh.

The file list tartanair_v2_files.txt ("<Env>/Data_<easy|hard>/<modality>[_<camera>].zip <size> G")
is copied from the official toolkit (castacks/tartanairpy, tartanair/download_files.txt). This
script filters it and downloads the zips itself, so it does not need the heavy `tartanair`
package (torch, kornia, cupy-cuda12x, ...), which cannot be installed on macOS.

Examples:
  python download_tartanair_v2.py --list
  python download_tartanair_v2.py --env Prison --difficulty easy --modality image depth \
      --camera lcam_front --dry-run
  python download_tartanair_v2.py --env ArchVizTinyHouseDay Prison --modality image depth \
      --camera lcam_front --unzip

Empty --env / --difficulty / --modality / --camera means "all" (the whole dataset is ~57 TB!).
Re-running skips completed files and resumes partial ones.
"""
import argparse
import os
import sys
import urllib.request
import zipfile
from concurrent.futures import ThreadPoolExecutor, as_completed

DEFAULT_ROOT = "/Volumes/Expansion0/3DRDatasets/TartanAirV2"
FILE_LIST = os.path.join(os.path.dirname(os.path.abspath(__file__)), "tartanair_v2_files.txt")
HF_REPO = "theairlabcmu/tartanair2"
AIRLAB_BASE = ("https://airlab-cloud.andrew.cmu.edu:8080/swift/v1/"
               "AUTH_ac8533a83cff4d48bc8c608ad222d330/tartanair_v2")
DIFFICULTIES = ["easy", "hard"]
MODALITIES = ["image", "depth", "seg", "imu", "lidar", "flow", "events", "mp4"]
CAMERAS = [f"{s}cam_{d}" for s in "lr" for d in
           ["front", "left", "right", "back", "top", "bottom", "fish", "equirect"]]


def load_entries():
    """-> list of dicts: path, size_gb, env, difficulty, modality, camera (or None)."""
    entries = []
    with open(FILE_LIST) as f:
        for line in f:
            parts = line.split()
            if len(parts) < 2:
                continue
            path, size = parts[0], float(parts[1])
            env, data_dir, name = path.split("/")
            name = name[:-len(".zip")]
            modality, _, camera = name.partition("_")
            entries.append(dict(path=path, size_gb=size, env=env,
                                difficulty=data_dir.replace("Data_", ""),
                                modality=modality, camera=camera or None))
    return entries


def select(entries, envs, difficulties, modalities, cameras):
    out = []
    for e in entries:
        if envs and e["env"] not in envs:
            continue
        if difficulties and e["difficulty"] not in difficulties:
            continue
        if modalities and e["modality"] not in modalities:
            continue
        # imu / lidar have no camera; the camera filter only applies to per-camera files
        if cameras and e["camera"] is not None and e["camera"] not in cameras:
            continue
        out.append(e)
    return out


def http_download(url, dest):
    """Resumable download: data goes to <dest>.part and is renamed when complete."""
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    part = dest + ".part"
    start = os.path.getsize(part) if os.path.exists(part) else 0
    req = urllib.request.Request(url, headers={"Range": f"bytes={start}-"} if start else {})
    with urllib.request.urlopen(req, timeout=60) as r:
        if start and r.status != 206:  # server ignored the range: restart
            start = 0
        with open(part, "ab" if start else "wb") as f:
            while True:
                chunk = r.read(1 << 20)
                if not chunk:
                    break
                f.write(chunk)
    os.replace(part, dest)


def hf_download(path, root):
    from huggingface_hub import hf_hub_download
    hf_hub_download(repo_id=HF_REPO, repo_type="dataset", filename=path, local_dir=root)


def unzip(zip_path, dest_dir, delete):
    marker = zip_path + ".unzipped"
    if os.path.exists(marker):
        return
    with zipfile.ZipFile(zip_path) as z:
        z.extractall(dest_dir)
    open(marker, "w").close()
    if delete:
        os.remove(zip_path)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("-o", "--output-root", default=DEFAULT_ROOT, help=f"default: {DEFAULT_ROOT}")
    p.add_argument("--env", nargs="*", default=[], help="environment names (default: all 74; see --list)")
    p.add_argument("--difficulty", nargs="*", default=[], choices=DIFFICULTIES, help="default: both")
    p.add_argument("--modality", nargs="*", default=[], choices=MODALITIES, help="default: all")
    p.add_argument("--camera", nargs="*", default=[], choices=CAMERAS,
                   help="default: all (imu / lidar need no camera)")
    p.add_argument("--source", default="huggingface", choices=["huggingface", "airlab"],
                   help=f"huggingface ({HF_REPO}, default) or airlab (CMU server)")
    p.add_argument("--workers", type=int, default=4, help="parallel downloads (default: 4)")
    p.add_argument("--unzip", action="store_true", help="unzip into OUTPUT_ROOT after downloading")
    p.add_argument("--delete-zip", action="store_true", help="delete zips after unzipping")
    p.add_argument("--dry-run", action="store_true", help="only print the selected files and total size")
    p.add_argument("--list", action="store_true", help="print valid environment names and exit")
    args = p.parse_args()

    entries = load_entries()
    all_envs = sorted({e["env"] for e in entries})
    if args.list:
        print(f"env ({len(all_envs)}): {' '.join(all_envs)}")
        print(f"difficulty: {' '.join(DIFFICULTIES)}")
        print(f"modality: {' '.join(MODALITIES)}")
        print(f"camera: {' '.join(CAMERAS)}")
        return
    unknown = sorted(set(args.env) - set(all_envs))
    if unknown:
        p.error(f"unknown environment(s): {' '.join(unknown)} (see --list)")

    sel = select(entries, args.env, args.difficulty, args.modality, args.camera)
    total = sum(e["size_gb"] for e in sel)
    print(f"Selected {len(sel)} file(s), ~{total:.1f} GB | source: {args.source} | output: {args.output_root}")
    if not sel:
        sys.exit("Nothing matched.")
    if args.dry_run:
        for e in sel:
            print(f"  {e['path']}  {e['size_gb']:.2f} GB")
        return

    root = args.output_root
    os.makedirs(root, exist_ok=True)

    def job(e):
        dest = os.path.join(root, e["path"])
        if os.path.exists(dest) or os.path.exists(dest + ".unzipped"):
            return "skip"
        if args.source == "huggingface":
            hf_download(e["path"], root)
        else:
            http_download(f"{AIRLAB_BASE}/{e['path']}", dest)
        return "ok"

    failed = []
    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        futs = {ex.submit(job, e): e for e in sel}
        for i, fut in enumerate(as_completed(futs), 1):
            e = futs[fut]
            try:
                status = fut.result()
                print(f"[{i}/{len(sel)}] {status:4s} {e['path']}")
            except Exception as exc:  # keep going, report at the end
                print(f"[{i}/{len(sel)}] FAIL {e['path']}: {exc}", file=sys.stderr)
                failed.append(e["path"])

    if args.unzip:
        for e in sel:
            z = os.path.join(root, e["path"])
            if e["path"] in failed or not os.path.exists(z) or os.path.exists(z + ".unzipped"):
                continue
            print(f"unzip {e['path']}")
            # archives contain the full <Env>/Data_<difficulty>/Pxxx/... path
            unzip(z, root, args.delete_zip)

    if failed:
        sys.exit(f"{len(failed)} download(s) failed; re-run the same command to resume.")
    print("All files downloaded.")


if __name__ == "__main__":
    main()
