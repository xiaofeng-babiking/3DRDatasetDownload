#!/usr/bin/env python3
"""Download TartanGround (see README.md). Usually run through download_tartanground.sh.

The file list tartanground_files.txt is copied from the official toolkit
(castacks/tartanairpy, tartanair/download_ground_files.txt). Entries look like
  <Env>/Data_<omni|diff|anymal>/<Pxxxx>/<modality>[_<camera>].zip   per-trajectory files
  <Env>/<Env>_rgb_pcd.zip, <Env>/<Env>_sem_pcd.zip, <Env>/seg_labels.zip   per-environment files
This script filters it and downloads the zips itself, so it does not need the heavy `tartanair`
package (torch, kornia, cupy-cuda12x, ...), which cannot be installed on macOS.

Examples:
  python download_tartanground.py --list
  python download_tartanground.py --env AbandonedFactory Hospital --version omni \
      --modality image depth meta --camera lcam_front lcam_left lcam_right lcam_back --unzip
  python download_tartanground.py --version omni --traj P0000 --camera lcam_front --dry-run
  python download_tartanground.py --modality sem_pcd seg_labels

Empty --env / --version / --traj / --modality / --camera means "all" (the whole dataset is ~16.7 TB).
Re-running skips completed files and resumes partial ones.
"""
import argparse
import os
import sys
import urllib.request
import zipfile
from concurrent.futures import ThreadPoolExecutor, as_completed

DEFAULT_ROOT = "/Volumes/Expansion0/3DRDatasets/TartanGround"
FILE_LIST = os.path.join(os.path.dirname(os.path.abspath(__file__)), "tartanground_files.txt")
HF_REPO = "theairlabcmu/TartanGround"
AIRLAB_BASE = ("https://airlab-cloud.andrew.cmu.edu:8080/swift/v1/"
               "AUTH_ac8533a83cff4d48bc8c608ad222d330/tartanground")
VERSIONS = ["omni", "diff", "anymal"]
MODALITIES = ["image", "meta", "depth", "seg", "lidar", "imu", "rosbag", "sem_pcd", "seg_labels", "rgb_pcd"]
CAMERAS = [f"{s}cam_{d}" for s in "lr" for d in ["front", "right", "left", "back", "top", "bottom"]]
# file stem in the list -> modality name used by the official toolkit
STEM_TO_MODALITY = {"metadata": "meta", "rosbags": "rosbag"}


def load_entries():
    """-> list of dicts: path, size_gb, env, version, traj, modality, camera (None if n/a)."""
    entries = []
    with open(FILE_LIST) as f:
        for line in f:
            parts = line.split()
            if len(parts) < 2:
                continue
            path, size = parts[0], float(parts[1])
            tok = path.split("/")
            env, name = tok[0], tok[-1][:-len(".zip")]
            e = dict(path=path, size_gb=size, env=env, version=None, traj=None, camera=None)
            if len(tok) == 2:  # per-environment file
                if name == "seg_labels":
                    e["modality"] = "seg_labels"
                else:  # <Env>_rgb_pcd / <Env>_sem_pcd
                    e["modality"] = name[len(env) + 1:]
            else:
                e["version"] = tok[1].replace("Data_", "")
                e["traj"] = tok[2]
                if name in STEM_TO_MODALITY or "_" not in name:
                    e["modality"] = STEM_TO_MODALITY.get(name, name)
                else:
                    e["modality"], _, e["camera"] = name.partition("_")
            entries.append(e)
    return entries


def select(entries, envs, versions, trajs, modalities, cameras):
    out = []
    for e in entries:
        if envs and e["env"] not in envs:
            continue
        if modalities and e["modality"] not in modalities:
            continue
        # version / traj / camera filters only apply to the files that have them
        if versions and e["version"] is not None and e["version"] not in versions:
            continue
        if trajs and e["traj"] is not None and e["traj"] not in trajs:
            continue
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


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("-o", "--output-root", default=DEFAULT_ROOT, help=f"default: {DEFAULT_ROOT}")
    p.add_argument("--env", nargs="*", default=[], help="environment names (default: all 63; see --list)")
    p.add_argument("--version", nargs="*", default=[], choices=VERSIONS,
                   help="robot: omni (P00xx), diff (P10xx), anymal (P20xx); default: all")
    p.add_argument("--traj", nargs="*", default=[], help="trajectory ids, e.g. P0000 P1001 (default: all)")
    p.add_argument("--modality", nargs="*", default=[], choices=MODALITIES,
                   help="default: all (rosbag exists only for anymal)")
    p.add_argument("--camera", nargs="*", default=[], choices=CAMERAS, help="default: all")
    p.add_argument("--source", default="huggingface", choices=["huggingface", "airlab"],
                   help=f"huggingface ({HF_REPO}, default) or airlab (CMU server)")
    p.add_argument("--workers", type=int, default=4, help="parallel downloads (default: 4)")
    p.add_argument("--unzip", action="store_true", help="unzip each archive next to itself after downloading")
    p.add_argument("--delete-zip", action="store_true", help="delete zips after unzipping")
    p.add_argument("--dry-run", action="store_true", help="only print the selected files and total size")
    p.add_argument("--list", action="store_true", help="print valid environment names and exit")
    args = p.parse_args()

    entries = load_entries()
    all_envs = sorted({e["env"] for e in entries})
    if args.list:
        for v in VERSIONS:
            envs = sorted({e["env"] for e in entries if e["version"] == v})
            print(f"{v} ({len(envs)}): {' '.join(envs)}")
        print(f"modality: {' '.join(MODALITIES)}")
        print(f"camera: {' '.join(CAMERAS)}")
        return
    unknown = sorted(set(args.env) - set(all_envs))
    if unknown:
        p.error(f"unknown environment(s): {' '.join(unknown)} (see --list)")

    sel = select(entries, args.env, args.version, args.traj, args.modality, args.camera)
    total = sum(e["size_gb"] for e in sel)
    print(f"Selected {len(sel)} file(s), ~{total:.1f} GB | source: {args.source} | output: {args.output_root}")
    if not sel:
        sys.exit("Nothing matched.")
    if args.dry_run:
        for e in sel[:50]:
            print(f"  {e['path']}  {e['size_gb']:.3f} GB")
        if len(sel) > 50:
            print(f"  ... ({len(sel) - 50} more)")
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
                print(f"[{i}/{len(sel)}] {fut.result():4s} {e['path']}")
            except Exception as exc:  # keep going, report at the end
                print(f"[{i}/{len(sel)}] FAIL {e['path']}: {exc}", file=sys.stderr)
                failed.append(e["path"])

    if args.unzip:
        for e in sel:
            z = os.path.join(root, e["path"])
            marker = z + ".unzipped"
            if e["path"] in failed or os.path.exists(marker) or not os.path.exists(z):
                continue
            print(f"unzip {e['path']}")
            # archive entries are relative to the folder that holds the zip (same as the toolkit)
            with zipfile.ZipFile(z) as zf:
                zf.extractall(os.path.dirname(z))
            open(marker, "w").close()
            if args.delete_zip:
                os.remove(z)

    if failed:
        sys.exit(f"{len(failed)} download(s) failed; re-run the same command to resume.")
    print("All files downloaded.")


if __name__ == "__main__":
    main()
