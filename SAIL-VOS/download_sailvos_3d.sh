#!/usr/bin/env bash
# Copyright (c) Meta Platforms, Inc. and affiliates.
#
# This source code is licensed under the Apache License, Version 2.0
# found in the LICENSE file in the root directory of this source tree.
#
# Download-only Bash adaptation of download_sailvos_3d.py.
# Reference: Jeff Tan (Carnegie Mellon University).

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: bash download_sailvos_3d.sh --target_dir DIR [--n_workers N]

Download all SAIL-VOS 3D training and validation files without extracting them.

Options:
  --target_dir DIR  Directory to download files to (required).
  --n_workers N    Number of parallel downloads (default: 8).
  -h, --help       Show this help message.

Completed files are skipped. Partial downloads are saved as <name>.part;
re-run the script with the same target directory to resume them.
Progress bars show download speed and estimated time remaining.
Requires Bash, wget, and xargs.
EOF
}

TARGET_DIR="/Volumes/Expansion1/3DRDatasets/SAIL-VOS-3D"
N_WORKERS=8

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target_dir)
      if [[ $# -lt 2 || -z "$2" ]]; then
        echo "Error: --target_dir requires a directory." >&2
        exit 1
      fi
      TARGET_DIR="$2"
      shift 2
      ;;
    --n_workers)
      if [[ $# -lt 2 ]]; then
        echo "Error: --n_workers requires a positive integer." >&2
        exit 1
      fi
      N_WORKERS="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$TARGET_DIR" ]]; then
  echo "Error: --target_dir is required." >&2
  usage >&2
  exit 1
fi

if [[ ! "$N_WORKERS" =~ ^[1-9][0-9]*$ ]]; then
  echo "Error: --n_workers must be a positive integer." >&2
  exit 1
fi

for dependency in wget xargs; do
  if ! command -v "$dependency" >/dev/null 2>&1; then
    echo "Error: required command not found: $dependency" >&2
    exit 1
  fi
done

# Only rename a partial file after wget succeeds. An existing final filename
# is treated as a completed download, matching download_sailvos.sh.
fetch() {
  local out="$1"
  local url="$2"

  if [[ -f "$out" ]]; then
    echo "[skip] $out already exists"
    return 0
  fi

  echo "[download] $out"
  if wget -nv --show-progress --progress=bar:force:noscroll -c -O "$out.part" "$url"; then
    if mv -- "$out.part" "$out"; then
      echo "[done] $out"
      return 0
    fi
  fi

  echo "[fail] $out (partial data kept in $out.part; re-run to resume)" >&2
  return 1
}
export -f fetch

mkdir -p -- "$TARGET_DIR"
cd -- "$TARGET_DIR"
echo "Downloading SAIL-VOS 3D to $PWD ($N_WORKERS parallel downloads)..."

# xargs works with Bash 3.2 on macOS as well as newer Bash versions on Linux.
# Each input row is a filename and URL; all downloads finish before we exit.
if xargs -n 2 -P "$N_WORKERS" bash -c 'fetch "$@"' _ <<'LINKS'
sailvos3d_train_images.tar.001 https://uofi.box.com/shared/static/3eripmzmomw5702ni3twfrk0l8743fxs.001
sailvos3d_train_images.tar.002 https://uofi.box.com/shared/static/8jib67fxo8lwzqdytxb1h1ort9uxsn2a.002
sailvos3d_train_images.tar.003 https://uofi.box.com/shared/static/qix2bb0q03qx1rw982f3uuaoeqdbvclk.003
sailvos3d_train_images.tar.004 https://uofi.box.com/shared/static/pwt8k9d4s5rvakt8n9on6nid7aua6qp3.004
sailvos3d_train_images.tar.005 https://uofi.box.com/shared/static/20mx6rotndrw13bqlwrd9iz0ymr838pw.005
sailvos3d_train_images.tar.006 https://uofi.box.com/shared/static/fy922rc89rqc8jxrnymou4ef26rmyyux.006
sailvos3d_train_images.tar.007 https://uofi.box.com/shared/static/j3wk6g882kkkc266011amcx7m4wc7qz7.007
sailvos3d_train_images.tar.008 https://uofi.box.com/shared/static/pyace6q4r9azoo5s64omfq6i0q7uwbu0.008
sailvos3d_train_depth.tar.001 https://uofi.box.com/shared/static/ro2dbtfbmb9lg1104v4rrvllzojr33tt.001
sailvos3d_train_depth.tar.002 https://uofi.box.com/shared/static/69fd5zbce3a3p5va0js4r3g1easnf90u.002
sailvos3d_train_depth.tar.003 https://uofi.box.com/shared/static/1vvnh1fmqg1j92709hho86cwziserjm9.003
sailvos3d_train_depth.tar.004 https://uofi.box.com/shared/static/z4g1mbpn656jwb8vyewmjgo2s4kmgdx2.004
sailvos3d_train_depth.tar.005 https://uofi.box.com/shared/static/vedj0h131a2bo27vy1teg8xrpm0r94nk.005
sailvos3d_train_depth.tar.006 https://uofi.box.com/shared/static/s8kplxffgbl20nq6811lx0vu50tmm6mu.006
sailvos3d_train_depth.tar.007 https://uofi.box.com/shared/static/57lp89cvkef32z2e6qgkmeakd2ib83qk.007
sailvos3d_train_depth.tar.008 https://uofi.box.com/shared/static/5apa94i6mycd2f25vwja7zrrspnxxtub.008
sailvos3d_train_depth.tar.009 https://uofi.box.com/shared/static/gn01iqa1lsc7varcwwpckxg264x9rnub.009
sailvos3d_train_depth.tar.010 https://uofi.box.com/shared/static/kh7uad59z1mgpiimyd5zoju53tq6qfoa.010
sailvos3d_train_depth.tar.011 https://uofi.box.com/shared/static/ytbnj7ipwo8mcswpyc4h7ufl5zeo9zj8.011
sailvos3d_train_depth.tar.012 https://uofi.box.com/shared/static/bko72b2ozj9wi2mc95n8x6g8dqnjt5j6.012
sailvos3d_train_depth.tar.013 https://uofi.box.com/shared/static/jux284t3hrqo6lz56f4km4yrxvv48tn9.013
sailvos3d_train_depth.tar.014 https://uofi.box.com/shared/static/yhaqa0fu947cztgv631he7yg1614ya08.014
sailvos3d_train_depth.tar.015 https://uofi.box.com/shared/static/72b53cf64tinuyiedyy6pemaxei2q9rw.015
sailvos3d_train_mesh.tar.001 https://uofi.box.com/shared/static/m8efy5ig99ld0qw4de83ecb2vlpqfk1x.001
sailvos3d_train_mesh.tar.002 https://uofi.box.com/shared/static/jjfvsdk09xie8mh8dgudl8tpj2fgot2h.002
sailvos3d_train_mesh.tar.003 https://uofi.box.com/shared/static/3rlv1nmljar7nzn05qbyu8446pefv2dg.003
sailvos3d_train_mesh.tar.004 https://uofi.box.com/shared/static/ik94tms25zru0ppwoz2suggvrs08pewx.004
sailvos3d_train_mesh.tar.005 https://uofi.box.com/shared/static/5xm7qqoe3a543kd8vzlu05kn4vi80tut.005
sailvos3d_train_mesh.tar.006 https://uofi.box.com/shared/static/tiyzm7hd17u5gou00qvruu64znl6b7ni.006
sailvos3d_train_visible.zip https://uofi.box.com/shared/static/3247j2yt5mfvfh69ka80c5apj9bhacrk.zip
sailvos3d_train_voxel.zip https://uofi.box.com/shared/static/y51av4iow9aoxhl3yoas8drpqb25s1mk.zip
sailvos3d_train_camera.zip https://uofi.box.com/shared/static/xz0j5rza2odwqny05kmw4g5yf1hxte7t.zip
sailvos3d_train_rage_matrices.zip https://uofi.box.com/shared/static/gouw67icrievh139w80nhetzeojoi1pp.zip
sailvos3d_train_annot_24.json https://uofi.box.com/shared/static/k46rj1zwi7brtsq55gufsrpb50lvypjt.json
sailvos3d_train_split.txt https://uofi.box.com/shared/static/cz4lqofgbq5dqq5qrhqt9vxeme1ac0om.txt
sailvos3d_val_images.tar.001 https://uofi.box.com/shared/static/f22dfmi9wfslqty71yjvrqxg3rbdznbe.001
sailvos3d_val_images.tar.002 https://uofi.box.com/shared/static/aifckiwh01dkgs9ty5rlfk9oyjf2bf2w.002
sailvos3d_val_depth.tar.001 https://uofi.box.com/shared/static/f63ma0q8aa0xaghjpsv1n4sfz0kvlnzo.001
sailvos3d_val_depth.tar.002 https://uofi.box.com/shared/static/i41albg2qvaaholpsigyn5m0wzhp79q6.002
sailvos3d_val_depth.tar.003 https://uofi.box.com/shared/static/1idnnpqfbwnwyt3hqfmk1pusg81zbn0q.003
sailvos3d_val_depth.tar.004 https://uofi.box.com/shared/static/c9k5o0y2q8wtl5bkppdnz56aufdboe3p.004
sailvos3d_val_depth.tar.005 https://uofi.box.com/shared/static/i0kzp2ubn9bpqqqs01457bpx3u4d3zu9.005
sailvos3d_val_mesh.tar.001 https://uofi.box.com/shared/static/a404zcz7ntrukzxo3hmp90bvccmzkpgy.001
sailvos3d_val_mesh.tar.002 https://uofi.box.com/shared/static/i1btueb5ncj2q2uedhtny47i5m7baddl.002
sailvos3d_val_mesh.tar.003 https://uofi.box.com/shared/static/675u55ai5ra0qnl1zvetxb6ii9czj2z5.003
sailvos3d_val_visible.zip https://uofi.box.com/shared/static/bkps8e53r711qynsinofnnwgzoexikh2.zip
sailvos3d_val_voxel.zip https://uofi.box.com/shared/static/euomlke8gu3ifuog9mx0roibab48ce8g.zip
sailvos3d_val_camera.zip https://uofi.box.com/shared/static/a07b3biw6c8plc7x7tb9q9u4uyiiohg2.zip
sailvos3d_val_rage_matrices.zip https://uofi.box.com/shared/static/6vew1eje42rwwm13m3y4q8ishbdsiib6.zip
sailvos3d_val_annot_24.json https://uofi.box.com/shared/static/zqn1vnxwdp6g54mmzoz977cpjux76the.json
sailvos3d_val_split.txt https://uofi.box.com/shared/static/a8vq5asaykxph37ezru7scxjm819ya42.txt
LINKS
then
  echo "Download complete! Files were not extracted."
else
  echo "Some downloads failed; re-run this script to resume." >&2
  exit 1
fi
