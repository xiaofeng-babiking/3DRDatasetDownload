#!/usr/bin/env python3
"""Select an official Aria CDN manifest without downloading or extracting files."""

import argparse
import fnmatch
import json
from pathlib import PurePosixPath

from download_aria_script import collect_entries


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--config")
    parser.add_argument("--sequence", action="append", default=[])
    parser.add_argument("--max_sequences", type=int)
    parser.add_argument("--list", action="store_true")
    args = parser.parse_args()
    if args.max_sequences is not None and args.max_sequences < 1:
        parser.error("--max_sequences must be positive")
    with open(args.input) as stream:
        data = json.load(stream)

    sequence_maps = []
    if isinstance(data, dict) and "atek_data_for_all_configs" in data:
        configs = data["atek_data_for_all_configs"]
        if args.config:
            if args.config not in configs:
                parser.error(f"Unknown ATEK config: {args.config}; available: {', '.join(configs)}")
            data["atek_data_for_all_configs"] = {args.config: configs[args.config]}
        for config in data["atek_data_for_all_configs"].values():
            sequence_maps.append((config, "wds_file_urls"))
    elif args.config:
        parser.error("--config requires an ATEK manifest")
    elif isinstance(data, dict) and "sequences" in data:
        sequence_maps.append((data, "sequences"))

    if (args.sequence or args.max_sequences) and not sequence_maps:
        parser.error("Sequence selection requires a sequences or ATEK manifest")
    matched_patterns = set()
    for container, key in sequence_maps:
        selected = {}
        for name, value in container[key].items():
            matches = [pattern for pattern in args.sequence if fnmatch.fnmatchcase(name, pattern)]
            matched_patterns.update(matches)
            if args.sequence and not matches:
                continue
            selected[name] = value
        if args.max_sequences:
            selected = dict(list(selected.items())[:args.max_sequences])
        container[key] = selected
    missing = set(args.sequence) - matched_patterns
    if missing:
        parser.error(f"Sequence patterns matched nothing: {', '.join(sorted(missing))}")

    entries = list(collect_entries(data))
    if not entries:
        parser.error("No downloadable file entries found")
    seen = set()
    for directory, entry in entries:
        filename = entry["filename"]
        path = PurePosixPath(directory, filename)
        if (not isinstance(filename, str) or not filename or path.is_absolute()
                or ".." in path.parts or "\\" in str(path)):
            parser.error("Manifest contains an unsafe output path")
        if path in seen:
            parser.error(f"Duplicate output path: {path}")
        seen.add(path)
        url = entry.get("download_url") or entry.get("cdn")
        if not url.startswith(("https://", "http://")):
            parser.error("Manifest contains a non-HTTP download URL")
        if args.list:
            print(path)
    with open(args.output, "w") as stream:
        json.dump(data, stream)
    print(f"Selected {len(entries)} files")


if __name__ == "__main__":
    main()
