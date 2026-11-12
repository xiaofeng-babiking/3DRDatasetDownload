#!/usr/bin/env python3
"""Download BEHAVIOR-1K data (see README.md). Usually run through download_behavior_1k.sh.

Parts:
  demos       2025 BEHAVIOR Challenge teleoperated demos, LeRobot v2.1 format
              (HF: behavior-1k/2025-challenge-demos): 10,000 episodes, 50 tasks, R1Pro robot,
              RGB / depth / instance-seg videos of 3 cameras + states/actions/annotations, ~1.57 TB
  rawdata     raw HDF5 episodes of the same demos (HF: behavior-1k/2025-challenge-rawdata), ~793 GB
  assets      scenes + 3D object assets for the OmniGibson simulator, installed with the official
              OmniGibson functions (shows the BEHAVIOR data license and asks you to accept it,
              downloads the decryption key). Needs OmniGibson installed, see README.md.
  assets_zip  only fetch the (encrypted) asset archives from HF behavior-1k/zipped-datasets;
              they are usable only after `assets` has installed the key.

Hugging Face downloads skip files that are already complete, so re-running resumes.

Examples:
  python download_behavior_1k.py --tasks 0 1 2 --modalities rgb depth --cameras head demos
  python download_behavior_1k.py --dry-run demos
  python download_behavior_1k.py --tasks 0 rawdata
  python download_behavior_1k.py assets
"""
import argparse
import fnmatch
import os
import sys

DEFAULT_ROOT = "/Volumes/Expansion0/3DRDatasets/BEHAVIOR-1K"
MODALITIES = ["rgb", "depth", "seg_instance_id"]
CAMERAS = ["head", "left_wrist", "right_wrist"]
PARTS = ["demos", "rawdata", "assets", "assets_zip"]

DEMOS_REPO = "behavior-1k/2025-challenge-demos"
RAWDATA_REPO = "behavior-1k/2025-challenge-rawdata"
ZIPPED_REPO = "behavior-1k/zipped-datasets"
ASSET_ZIPS = [
    "behavior-1k-assets-3.9.0.zip",
    "omnigibson-robot-assets-3.8.2.zip",
    "2025-challenge-task-instances.zip",
    "2026-challenge-task-instances.zip",
]


def task_globs(tasks):
    return [f"task-{t:04d}" for t in tasks] if tasks else ["task-*"]


def demos_patterns(tasks, modalities, cameras):
    pats = ["README.md", "meta/info.json", "meta/tasks.jsonl",
            "meta/episodes.jsonl", "meta/episodes_stats.jsonl"]
    for tg in task_globs(tasks):
        pats += [f"data/{tg}/*", f"annotations/{tg}/*", f"meta/episodes/{tg}/*"]
        pats += [f"videos/{tg}/observation.images.{m}.{c}/*" for m in modalities for c in cameras]
    return pats


def rawdata_patterns(tasks):
    return ["README.md"] + [f"{tg}/*" for tg in task_globs(tasks)]


def hf_download(repo_id, local_dir, patterns, workers, dry_run):
    from huggingface_hub import HfApi, snapshot_download

    if dry_run:
        files = HfApi().list_repo_files(repo_id, repo_type="dataset")
        sel = [f for f in files if any(fnmatch.fnmatch(f, p) for p in patterns)]
        print(f"[dry-run] {repo_id}: {len(sel)} file(s) selected")
        for f in sel[:20]:
            print("  " + f)
        if len(sel) > 20:
            print(f"  ... ({len(sel) - 20} more)")
        return
    print(f"Downloading {repo_id} -> {local_dir}")
    snapshot_download(repo_id=repo_id, repo_type="dataset", local_dir=local_dir,
                      allow_patterns=patterns, max_workers=workers)


def install_assets(output_root):
    # OmniGibson reads its data path from the environment at import time, so set it first.
    os.environ.setdefault("OMNIGIBSON_DATA_PATH", os.path.join(output_root, "omnigibson-data"))
    os.environ.setdefault("OMNI_KIT_ACCEPT_EULA", "YES")
    print(f"OMNIGIBSON_DATA_PATH={os.environ['OMNIGIBSON_DATA_PATH']}")
    try:
        from omnigibson.utils.asset_utils import (
            download_2026_challenge_task_instances,
            download_behavior_1k_assets,
            download_omnigibson_robot_assets,
        )
    except ImportError:
        sys.exit("OmniGibson is not importable. Install it first (see README.md):\n"
                 "  git clone https://github.com/StanfordVL/BEHAVIOR-1K && cd BEHAVIOR-1K && "
                 "./setup.sh --new-env --omnigibson --bddl")
    download_omnigibson_robot_assets()
    download_behavior_1k_assets()  # prints the license and asks for acceptance
    download_2026_challenge_task_instances()


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("parts", nargs="+", choices=PARTS, metavar="PART", help=" | ".join(PARTS))
    p.add_argument("-o", "--output-root", default=DEFAULT_ROOT, help=f"default: {DEFAULT_ROOT}")
    p.add_argument("--tasks", nargs="*", type=int, default=[],
                   help="(demos/rawdata) task ids 0-49 (default: all 50)")
    p.add_argument("--modalities", nargs="*", default=MODALITIES, choices=MODALITIES,
                   help="(demos) default: all")
    p.add_argument("--cameras", nargs="*", default=CAMERAS, choices=CAMERAS, help="(demos) default: all")
    p.add_argument("--workers", type=int, default=8, help="parallel HF download workers (default: 8)")
    p.add_argument("--dry-run", action="store_true", help="(HF parts) only list the selected files")
    args = p.parse_args()

    bad = [t for t in args.tasks if not 0 <= t <= 49]
    if bad:
        p.error(f"invalid task id(s) {bad}: expected 0-49")

    os.makedirs(args.output_root, exist_ok=True)
    root = args.output_root
    for part in args.parts:
        print(f"=== {part}")
        if part == "demos":
            hf_download(DEMOS_REPO, os.path.join(root, "2025-challenge-demos"),
                        demos_patterns(args.tasks, args.modalities, args.cameras), args.workers, args.dry_run)
        elif part == "rawdata":
            hf_download(RAWDATA_REPO, os.path.join(root, "2025-challenge-rawdata"),
                        rawdata_patterns(args.tasks), args.workers, args.dry_run)
        elif part == "assets_zip":
            hf_download(ZIPPED_REPO, os.path.join(root, "zipped-datasets"), ASSET_ZIPS, args.workers, args.dry_run)
        elif part == "assets":
            install_assets(root)
    print("Done.")


if __name__ == "__main__":
    main()
