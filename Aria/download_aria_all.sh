#!/usr/bin/env bash
# Download all Project Aria datasets.
# Usage: ./download_aria_all.sh [-o OUTPUT_ROOT] [-j NUM_WORKERS]
#   -o OUTPUT_ROOT   default: /Volumes/Expansion0/3DRDatasets/aria
#   -j NUM_WORKERS   parallel downloads per dataset, default: 8

OUTPUT_ROOT=/Volumes/Expansion0/3DRDatasets/aria
NUM_WORKERS=8
while getopts "o:j:h" opt; do
  case "$opt" in
    o) OUTPUT_ROOT="$OPTARG" ;;
    j) NUM_WORKERS="$OPTARG" ;;
    *) echo "Usage: $0 [-o OUTPUT_ROOT] [-j NUM_WORKERS]"; exit 1 ;;
  esac
done

# Resolve to an absolute path before cd, so a relative -o is relative to the caller's cwd.
mkdir -p "$OUTPUT_ROOT" || exit 1
OUTPUT_ROOT="$(cd "$OUTPUT_ROOT" && pwd)"
echo "Output: $OUTPUT_ROOT | workers: $NUM_WORKERS"
cd "$(dirname "$0")" || exit 1

# Aria Gen 2 Pilot
python download_aria_script.py --url_json urls/gen2pilot_download_urls.json --output_dir "$OUTPUT_ROOT/gen2pilot" --num_workers "$NUM_WORKERS"

# Aria Synthetic Environments (ASE)
python download_aria_script.py --url_json urls/aria_synthetic_environments_dataset_download_urls.json --output_dir "$OUTPUT_ROOT/aria_synthetic_environments_dataset" --num_workers "$NUM_WORKERS"
python download_aria_script.py --url_json urls/ase_mesh_download_urls.json --output_dir "$OUTPUT_ROOT/ase_mesh" --num_workers "$NUM_WORKERS"
python download_aria_script.py --url_json urls/AriaSyntheticEnvironment_ATEK_download_urls.json --output_dir "$OUTPUT_ROOT/AriaSyntheticEnvironment_ATEK" --num_workers "$NUM_WORKERS"

# Aria Everyday Activities (AEA)
# python download_aria_script.py --url_json urls/AriaEverydayActivities_download_urls.json --output_dir "$OUTPUT_ROOT/AriaEverydayActivities" --num_workers "$NUM_WORKERS"

# HOT3D
python download_aria_script.py --url_json urls/Hot3DAria_download_urls.json --output_dir "$OUTPUT_ROOT/Hot3DAria" --num_workers "$NUM_WORKERS"
# python download_aria_script.py --url_json urls/Hot3DQuest_download_urls.json --output_dir "$OUTPUT_ROOT/Hot3DQuest" --num_workers "$NUM_WORKERS"
python download_aria_script.py --url_json urls/Hot3DAssets_download_urls.json --output_dir "$OUTPUT_ROOT/Hot3DAssets" --num_workers "$NUM_WORKERS"

# Aria Digital Twin (ADT)
python download_aria_script.py --url_json urls/ADT_download_urls.json --output_dir "$OUTPUT_ROOT/ADT" --num_workers "$NUM_WORKERS"
python download_aria_script.py --url_json urls/DTC_objects_ADT_download_urls.json --output_dir "$OUTPUT_ROOT/DTC_objects_ADT" --num_workers "$NUM_WORKERS"
python download_aria_script.py --url_json urls/AriaDigitalTwin_ATEK_download_urls.json --output_dir "$OUTPUT_ROOT/AriaDigitalTwin_ATEK" --num_workers "$NUM_WORKERS"

# Digital Twin Catalog (DTC)
python download_aria_script.py --url_json urls/DTC_download_urls.json --output_dir "$OUTPUT_ROOT/DTC" --num_workers "$NUM_WORKERS"
python download_aria_script.py --url_json urls/DTC_objects_all_download_urls.json --output_dir "$OUTPUT_ROOT/DTC_objects_all" --num_workers "$NUM_WORKERS"
python download_aria_script.py --url_json urls/DTC_DSLR_download_urls.json --output_dir "$OUTPUT_ROOT/DTC_DSLR" --num_workers "$NUM_WORKERS"

# Nymeria
# python download_aria_script.py --url_json urls/Nymeria_download_urls.json --output_dir "$OUTPUT_ROOT/Nymeria" --num_workers "$NUM_WORKERS"

# Reading Recognition in the Wild
# python download_aria_script.py --url_json urls/ReadingInTheWild_download_urls.json --output_dir "$OUTPUT_ROOT/ReadingInTheWild" --num_workers "$NUM_WORKERS"

# Aria Everyday Objects (AEO)
python download_aria_script.py --url_json urls/AEO_download_urls.json --output_dir "$OUTPUT_ROOT/AEO" --num_workers "$NUM_WORKERS"
