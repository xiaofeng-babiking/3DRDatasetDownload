#!/usr/bin/env bash
# Unified, download-only entry point for the dataset collection.
set -eo pipefail
ROOT=$(cd -- "$(dirname -- "$0")" && pwd)

usage() {
  cat <<'EOF'
Usage: bash download_dataset.sh DATASET [--target_dir DIR] [-- DATASET_OPTIONS...]
       bash download_dataset.sh --list
       bash download_dataset.sh DATASET --help

Default directory: ./data/DATASET (relative to your working directory).
Dataset options after -- are forwarded unchanged; use DATASET --help to see them.
Only downloads files; extraction/deletion options of legacy scripts are blocked.
Some datasets require an approved account, official URL manifest, or SDK.
See DOWNLOADS.md for all 30 datasets, prerequisites, scope, and examples.

Examples:
  bash download_dataset.sh sailvos3d --target_dir /data/SAIL-VOS-3D -- --n_workers 4
  bash download_dataset.sh hypersim --target_dir /data/Hypersim -- 'ai_001_*'
  bash download_dataset.sh dynamicreplica --target_dir /data/DynamicReplica -- -l /path/links.json train valid test real
EOF
}

list_datasets() {
  cat <<'EOF'
aria
bedlam
behavior1k
co3dv2
uco3d
dl3dv
dynamicreplica
eden
efm3d
hot3d
habitat
hypersim
mapfree
mapillarymetropolis
mpsd
megadepth
megasynth
midair
mvssynth
paralleldomain4d
replica
sailvos
scannet
tartanairv2
tartanground
taskonomy
unrealstereo4k
virtualkitti
waymo
wildrgbd
# Additional versions:
sailvos3d
scannetpp
virtualkitti2
EOF
}

[[ $# -gt 0 ]] || { usage >&2; exit 1; }
case "$1" in
  -h|--help) usage; exit 0 ;;
  --list) list_datasets; exit 0 ;;
esac
DATASET=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
DATASET=${DATASET//-/}
DATASET=${DATASET//_/}
DATASET=${DATASET// /}
shift
STYLE=long
case "$DATASET" in
  aria) SCRIPT=Aria/download_aria.sh ;;
  bedlam) SCRIPT=BEDLAM/download_bedlam.sh; STYLE=short ;;
  behavior1k) SCRIPT=BEHAVIOR-1K/download_behavior_1k.sh; STYLE=short ;;
  co3dv2|co3d) SCRIPT=Co3Dv2/download_co3dv2.sh ;;
  uco3d) SCRIPT=uCO3D/download_uco3d.sh ;;
  dl3dv) SCRIPT=DL3DV/download_dl3dv.sh ;;
  dynamicreplica) SCRIPT=DynamicReplica/download_dynamic_replica.sh; STYLE=short ;;
  eden) SCRIPT=EDEN/download_eden.sh; STYLE=short ;;
  efm3d) SCRIPT=EFM3D/download_efm3d.sh ;;
  hot3d) SCRIPT=HOT3D/download_hot3d.sh ;;
  habitat|hm3d) SCRIPT=Habitat/download_habitat.sh ;;
  hypersim) SCRIPT=Hypersim/download_hypersim.sh; STYLE=short ;;
  mapfree) SCRIPT=Mapfree/download_mapfree.sh ;;
  mapillarymetropolis|metropolis) SCRIPT=MapillaryMetropolis/download_mapillary_metropolis.sh ;;
  mpsd) SCRIPT=MPSD/download_mpsd.sh ;;
  megadepth) SCRIPT=MegaDepth/download_megadepth.sh ;;
  megasynth) SCRIPT=MegaSynth/download_megasynth.sh; STYLE=short ;;
  midair) SCRIPT=Mid-Air/download_midair.sh; STYLE=short ;;
  mvssynth) SCRIPT=MVS-Synth/download_mvs_synth.sh; STYLE=short ;;
  paralleldomain4d|pd4d) SCRIPT=ParallelDomain-4D/download_paralleldomain4d.sh; STYLE=short ;;
  replica) SCRIPT=Replica/download_replica.sh ;;
  sailvos) SCRIPT=SAIL-VOS/download_sailvos.sh; STYLE=cwd ;;
  sailvos3d) SCRIPT=SAIL-VOS/download_sailvos_3d.sh ;;
  scannet) SCRIPT=ScanNet/download_scannet.sh ;;
  scannetpp|scannet++) SCRIPT=ScanNet/download_scannetpp.sh ;;
  tartanairv2|tartanair2) SCRIPT=TartanAirV2/download_tartanair_v2.sh; STYLE=short ;;
  tartanground) SCRIPT=TartanGround/download_tartanground.sh; STYLE=short ;;
  taskonomy) SCRIPT=Taskonomy/download_taskonomy.sh ;;
  unrealstereo4k) SCRIPT=UnrealStereo4K/download_unrealstereo4k.sh; STYLE=short ;;
  virtualkitti|vkitti) SCRIPT=VirtualKITTI/download_vkitti.sh ;;
  virtualkitti2|vkitti2) SCRIPT=VirtualKITTI2/download_vkitti2.sh; STYLE=short ;;
  waymo) SCRIPT=Waymo/download_waymo.sh ;;
  wildrgbd) SCRIPT=WildRGBD/download_wildrgbd.sh ;;
  *) printf 'Unknown dataset: %s. Run --list.\n' "$DATASET" >&2; exit 1 ;;
esac

TARGET_DIR="./data/$DATASET"
ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target_dir)
      [[ $# -ge 2 && -n "$2" && "$2" != --* ]] || { echo '--target_dir requires a directory.' >&2; exit 1; }
      TARGET_DIR="$2"; shift 2 ;;
    --) shift; ARGS+=("$@"); break ;;
    -h|--help) exec bash "$ROOT/$SCRIPT" --help ;;
    *) ARGS+=("$1"); shift ;;
  esac
done
for option in "${ARGS[@]}"; do
  # Legacy getopts accepts bundles such as -sx, which would also enable -x.
  # Require separate short flags so extraction cannot hide inside a bundle.
  if [[ "$STYLE" == short && "$option" == -?* && "$option" != --* && ${#option} -gt 2 ]]; then
    echo 'Pass short options separately (for example -s mpi); bundled/attached options are disabled.' >&2
    exit 1
  fi
  # argparse accepts abbreviated long flags; block those extraction aliases too.
  option_name=${option%%=*}
  if [[ "$STYLE" == short && "$option_name" == --?* &&
        ( --unzip == "$option_name"* || --delete-zip == "$option_name"* ) ]]; then
    echo 'This entry point only downloads; extraction/deletion options are disabled.' >&2
    exit 1
  fi
  case "$option" in
    -h|--help) exec bash "$ROOT/$SCRIPT" --help ;;
    -x|-d|-xd|-dx|--extract|--unzip|--delete-zip|--delete_zip)
      echo 'This entry point only downloads; extraction/deletion options are disabled.' >&2
      exit 1 ;;
  esac
  if [[ "$DATASET" == behavior1k && "$option" == assets ]]; then
    echo 'Use assets_zip to download BEHAVIOR assets without installing/unpacking them.' >&2
    exit 1
  fi
done
if [[ "$DATASET" == behavior1k && ${#ARGS[@]} -eq 0 ]]; then
  ARGS=(assets_zip)
fi

case "$STYLE" in
  short) exec bash "$ROOT/$SCRIPT" -o "$TARGET_DIR" "${ARGS[@]}" ;;
  long) exec bash "$ROOT/$SCRIPT" --target_dir "$TARGET_DIR" "${ARGS[@]}" ;;
  cwd)
    [[ ${#ARGS[@]} -eq 0 ]] || { echo 'SAIL-VOS takes no extra options.' >&2; exit 1; }
    mkdir -p -- "$TARGET_DIR"
    cd -- "$TARGET_DIR"
    exec bash "$ROOT/$SCRIPT" ;;
esac
