#!/usr/bin/env python3
"""Download TartanAir V2 with the official toolkit (pip install tartanair) — see README.md.

Examples:
  # left front camera RGB + depth of two environments, easy level
  python download_tartanair_v2.py --env ArchVizTinyHouseDay Prison \
      --difficulty easy --modality image depth --camera lcam_front --unzip

  # everything for one environment
  python download_tartanair_v2.py --env Prison --unzip

  # list valid names
  python download_tartanair_v2.py --list

Empty --env / --difficulty / --modality / --camera means "all" (the whole dataset is ~57 TB!).
Re-running skips files that are already complete (huggingface_hub snapshot_download).
"""
import argparse
import sys

DEFAULT_ROOT = "/Volumes/Expansion0/3DRDatasets/TartanAirV2"


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("-o", "--output-root", default=DEFAULT_ROOT, help=f"default: {DEFAULT_ROOT}")
    p.add_argument("--env", nargs="*", default=[], help="environment names (default: all 74)")
    p.add_argument("--difficulty", nargs="*", default=[], choices=["easy", "hard"], help="default: both")
    p.add_argument("--modality", nargs="*", default=[],
                   help="image depth seg imu lidar flow events mp4 (default: all)")
    p.add_argument("--camera", nargs="*", default=[],
                   help="lcam_front lcam_left lcam_right lcam_back lcam_top lcam_bottom lcam_fish "
                        "lcam_equirect and the rcam_* equivalents (default: all)")
    p.add_argument("--source", default="huggingface", choices=["huggingface", "airlab"],
                   help="huggingface (theairlabcmu/tartanair2, default) or airlab (CMU server)")
    p.add_argument("--workers", type=int, default=4, help="parallel download workers (default: 4)")
    p.add_argument("--unzip", action="store_true", help="unzip after downloading")
    p.add_argument("--delete-zip", action="store_true", help="delete zips after unzipping")
    p.add_argument("--list", action="store_true", help="print valid names and exit")
    args = p.parse_args()

    try:
        import tartanair as ta
    except ImportError:
        sys.exit("tartanair is not installed: pip install tartanair")

    ta.init(args.output_root)

    if args.list:
        for k, v in ta.get_all_data().items():
            print(f"{k} ({len(v)}): {' '.join(v)}")
        return

    print(f"Output: {args.output_root} | env: {args.env or 'ALL'} | difficulty: {args.difficulty or 'ALL'} | "
          f"modality: {args.modality or 'ALL'} | camera: {args.camera or 'ALL'} | source: {args.source}")
    ta.download(env=args.env,
                difficulty=args.difficulty,
                modality=args.modality,
                camera_name=args.camera,
                unzip=args.unzip,
                delete_zip=args.delete_zip,
                num_workers=args.workers,
                data_source=args.source)


if __name__ == "__main__":
    main()
