#!/usr/bin/env python3
"""Download TartanGround with the official toolkit (pip install tartanair) — see README.md.

Examples:
  # front/left/right/back RGB + depth + poses of the omni robot in two environments
  python download_tartanground.py --env AbandonedFactory Hospital --version omni \
      --modality image depth meta --camera lcam_front lcam_left lcam_right lcam_back --unzip

  # one trajectory (front camera) from every environment
  python download_tartanground.py --version omni --traj P0000 --camera lcam_front

  # global semantic point clouds + label maps for all environments
  python download_tartanground.py --modality sem_pcd seg_labels

Empty --env / --version / --traj / --modality / --camera means "all" (the whole dataset is ~16.7 TB).
Re-running skips files that are already complete (huggingface_hub snapshot_download).
"""
import argparse
import sys

DEFAULT_ROOT = "/Volumes/Expansion0/3DRDatasets/TartanGround"
MODALITIES = ["image", "meta", "depth", "seg", "lidar", "imu", "rosbag", "sem_pcd", "seg_labels", "rgb_pcd"]


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("-o", "--output-root", default=DEFAULT_ROOT, help=f"default: {DEFAULT_ROOT}")
    p.add_argument("--env", nargs="*", default=[], help="environment names (default: all 63)")
    p.add_argument("--version", nargs="*", default=[], choices=["omni", "diff", "anymal"],
                   help="robot: omni (P00xx), diff (P10xx), anymal (P20xx); default: all")
    p.add_argument("--traj", nargs="*", default=[], help="trajectory ids, e.g. P0000 P1001 (default: all)")
    p.add_argument("--modality", nargs="*", default=[], choices=MODALITIES,
                   help="default: all (rosbag exists only for anymal)")
    p.add_argument("--camera", nargs="*", default=[],
                   help="lcam_front lcam_right lcam_left lcam_back lcam_top lcam_bottom and rcam_* (default: all)")
    p.add_argument("--source", default="huggingface", choices=["huggingface", "airlab"],
                   help="huggingface (theairlabcmu/TartanGround, default) or airlab (CMU server)")
    p.add_argument("--workers", type=int, default=4, help="parallel download workers (default: 4)")
    p.add_argument("--unzip", action="store_true", help="unzip after downloading")
    p.add_argument("--delete-zip", action="store_true", help="delete zips after unzipping")
    args = p.parse_args()

    try:
        import tartanair as ta
    except ImportError:
        sys.exit("tartanair is not installed: pip install tartanair")

    ta.init(args.output_root)
    print(f"Output: {args.output_root} | env: {args.env or 'ALL'} | version: {args.version or 'ALL'} | "
          f"traj: {args.traj or 'ALL'} | modality: {args.modality or 'ALL'} | camera: {args.camera or 'ALL'} | "
          f"source: {args.source}")
    ta.download_ground(env=args.env,
                       version=args.version,
                       traj=args.traj,
                       modality=args.modality,
                       camera_name=args.camera,
                       unzip=args.unzip,
                       delete_zip=args.delete_zip,
                       num_workers=args.workers,
                       data_source=args.source)


if __name__ == "__main__":
    main()
