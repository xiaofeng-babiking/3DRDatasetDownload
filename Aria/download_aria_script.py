#!/usr/bin/env python3
"""Download Project Aria dataset files listed in a *_download_urls.json.

Supported JSON layouts (all obtained from https://www.projectaria.com/datasets/):

1. Sequence datasets (ADT, AEA, AEO, DTC, DTC_DSLR, HOT3D, Nymeria, Gen2 Pilot,
   ReadingInTheWild):
       {"sequences": {<seq>: {<group>: {filename, sha1sum, file_size_bytes, download_url}}},
        "sequence_config": {...}}
2. Object catalogs (DTC_objects_*):
       {"releases": {<release>: {"objects": {<obj>: {<item>: {filename, sha1sum, ..., download_url}}}}}}
3. ATEK (AriaDigitalTwin_ATEK, AriaSyntheticEnvironment_ATEK):
       {"atek_data_for_all_configs": {<cfg>: {"wds_file_urls": {<seq>: {<shard>: {filename, sha1sum, ..., download_url}}}}}}
4. ASE (aria_synthetic_environments_dataset, ase_mesh):
       [{filename, cdn, sha}, ...]

Every file entry is a dict with a ``filename`` plus ``download_url`` or ``cdn``.
Files are saved to ``<output_dir>/<path of parent keys>/<filename>``, e.g.
``out/Apartment_release_clean_seq131_M1292/ADT_..._preview_rgb.mp4``.

Every entry carries a SHA1 checksum (``sha1sum`` or ``sha``; no MD5). Downloads
resume from ``.part`` files and are verified by size + SHA1. Verified files are
recorded in ``<output_dir>/.aria_verified.tsv``; on reruns, files listed there
whose size/mtime are unchanged are skipped without re-hashing, other existing
files are re-hashed, and corrupt ones are re-downloaded. Note: the URLs are signed and expire; re-download the JSON
from projectaria.com when you start getting HTTP 403 errors.
"""

import argparse
import hashlib
import json
import os
import sys
import threading
import time
import urllib.error
import urllib.request
from concurrent.futures import ThreadPoolExecutor, as_completed

# Container keys that only add nesting and are dropped from the output path.
CONTAINER_KEYS = {"sequences", "releases", "objects", "atek_data_for_all_configs", "wds_file_urls"}
# Metadata keys that never contain file entries.
SKIP_KEYS = {"sequence_config", "object_config", "atek_preprocessing_config_content",
             "atek_wds_shapes", "atek_wds_dtypes"}

DEFAULT_NUM_WORKERS = 8
MAX_RETRIES = 5
CHUNK_SIZE = 8 * 1024 * 1024   # sha1 hashing block size
READ_SIZE = 1024 * 1024         # network read size (finer-grained speed accounting)
REPORT_INTERVAL = 10            # seconds between [speed] log lines
VERIFIED_MANIFEST = ".aria_verified.tsv"  # per output_dir record of SHA1-verified files


def collect_entries(node, path=()):
    """Recursively yield (relative_dir, entry) for every file entry in the JSON."""
    if isinstance(node, dict):
        url = node.get("download_url") or node.get("cdn")
        if "filename" in node and isinstance(url, str):
            # Drop the entry's own key (e.g. "video_main_rgb"); its filename is unique.
            yield os.path.join(*path[:-1]) if len(path) > 1 else "", node
            return
        for key, value in node.items():
            if key in SKIP_KEYS:
                continue
            sub = path if key in CONTAINER_KEYS else path + (str(key),)
            yield from collect_entries(value, sub)
    elif isinstance(node, list):
        for item in node:
            # List items are flat (ASE); keep the parent path only.
            yield from collect_entries(item, path + ("_",))


def sha1_of(path):
    h = hashlib.sha1()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(CHUNK_SIZE), b""):
            h.update(chunk)
    return h.hexdigest()


class Progress:
    """Thread-safe byte counters shared by all download workers."""

    def __init__(self, total_bytes, total_files):
        self.lock = threading.Lock()
        self.total_bytes = total_bytes      # expected size of all files (0 if unknown)
        self.total_files = total_files
        self.done_bytes = 0                 # bytes on disk: skipped + resumed + newly fetched
        self.fetched_bytes = 0              # bytes transferred over the network this run
        self.done_files = 0
        self.start = time.time()

    def add(self, n, fetched=True):
        with self.lock:
            self.done_bytes += n
            if fetched:
                self.fetched_bytes += n

    def snapshot(self):
        with self.lock:
            return self.done_bytes, self.fetched_bytes, self.done_files


def report_speed(progress, stop_event):
    """Print overall throughput every REPORT_INTERVAL seconds until stopped."""
    _, last_fetched, _ = progress.snapshot()
    last_t = time.time()
    while not stop_event.wait(REPORT_INTERVAL):
        done, fetched, files = progress.snapshot()
        now = time.time()
        cur = (fetched - last_fetched) / (now - last_t)
        avg = fetched / (now - progress.start)
        msg = f"[speed] now {human(cur)}/s | avg {human(avg)}/s | files {files}/{progress.total_files}"
        if progress.total_bytes:
            remaining = max(progress.total_bytes - done, 0)
            pct = 100 * done / progress.total_bytes
            eta = fmt_duration(remaining / avg) if avg > 0 else "?"
            msg += f" | {human(done)}/{human(progress.total_bytes)} ({pct:.1f}%) | ETA {eta}"
        else:
            msg += f" | fetched {human(fetched)}"
        print(msg, flush=True)
        last_fetched, last_t = fetched, now


class VerifiedCache:
    """Manifest of files whose SHA1 has been verified, so reruns skip re-hashing.

    Stored as ``<output_dir>/.aria_verified.tsv`` with lines
    ``relpath<TAB>sha1<TAB>size<TAB>mtime_ns``. A record is trusted only while the
    file's size and mtime are unchanged; otherwise the file is re-hashed.
    """

    def __init__(self, output_dir):
        self.output_dir = output_dir
        self.path = os.path.join(output_dir, VERIFIED_MANIFEST)
        self.lock = threading.Lock()
        self.records = {}
        if os.path.exists(self.path):
            with open(self.path) as f:
                for line in f:
                    parts = line.rstrip("\n").split("\t")
                    if len(parts) == 4:
                        self.records[parts[0]] = (parts[1], int(parts[2]), int(parts[3]))

    def _key(self, path):
        return os.path.relpath(path, self.output_dir)

    def is_verified(self, path, sha):
        rec = self.records.get(self._key(path))
        if not rec or not os.path.exists(path):
            return False
        st = os.stat(path)
        return rec == (sha, st.st_size, st.st_mtime_ns)

    def mark(self, path, sha):
        st = os.stat(path)
        rec = (sha, st.st_size, st.st_mtime_ns)
        key = self._key(path)
        with self.lock:
            self.records[key] = rec
            os.makedirs(self.output_dir, exist_ok=True)
            with open(self.path, "a") as f:
                f.write(f"{key}\t{rec[0]}\t{rec[1]}\t{rec[2]}\n")


def is_intact(path, sha, size):
    """Full integrity check: size (if known) and SHA1 (if known)."""
    if size is not None and os.path.getsize(path) != size:
        return False
    return not sha or sha1_of(path) == sha


def download_one(entry, dest, progress, cache):
    """Return (status, bytes fetched over network, seconds spent fetching).

    status: "skipped"    - already in the verified manifest, unchanged on disk (no hashing)
            "verified"   - existing file hashed and matched; added to the manifest
            "downloaded" - fetched (or resumed) and verified
    """
    url = entry.get("download_url") or entry["cdn"]
    sha = entry.get("sha1sum") or entry.get("sha")
    size = entry.get("file_size_bytes")

    if os.path.exists(dest):
        if sha and cache.is_verified(dest, sha):
            progress.add(os.path.getsize(dest), fetched=False)
            return "skipped", 0, 0.0
        if is_intact(dest, sha, size):
            if sha:
                cache.mark(dest, sha)
            progress.add(os.path.getsize(dest), fetched=False)
            return "verified", 0, 0.0
        print(f"  corrupt {os.path.basename(dest)}: size/sha1 mismatch, re-downloading", flush=True)
        os.remove(dest)

    os.makedirs(os.path.dirname(dest) or ".", exist_ok=True)
    part = dest + ".part"
    fetched, elapsed = 0, 0.0
    counted = 0  # bytes of this file already credited to progress.done_bytes
    for attempt in range(1, MAX_RETRIES + 1):
        try:
            offset = os.path.getsize(part) if os.path.exists(part) else 0
            if size is not None and offset > size:
                os.remove(part)
                offset = 0
            if offset > counted:  # resumed bytes from a previous run
                progress.add(offset - counted, fetched=False)
                counted = offset
            if size is None or offset < size:  # otherwise .part is complete; just verify
                req = urllib.request.Request(url, headers={"User-Agent": "aria-downloader"})
                if offset:
                    req.add_header("Range", f"bytes={offset}-")
                t0 = time.time()
                with urllib.request.urlopen(req, timeout=60) as resp:
                    if offset and resp.status != 206:  # server ignored Range
                        progress.add(-counted, fetched=False)
                        offset = counted = 0
                    with open(part, "ab" if offset else "wb") as f:
                        for chunk in iter(lambda: resp.read(READ_SIZE), b""):
                            f.write(chunk)
                            progress.add(len(chunk))
                            fetched += len(chunk)
                            counted += len(chunk)
                elapsed += time.time() - t0
            if size is not None and os.path.getsize(part) != size:
                raise IOError(f"size mismatch: {os.path.getsize(part)} != {size}")
            if sha and sha1_of(part) != sha:
                os.remove(part)
                progress.add(-counted, fetched=False)
                counted = 0
                raise IOError("sha1 mismatch")
            os.replace(part, dest)
            if sha:
                cache.mark(dest, sha)
            return "downloaded", fetched, elapsed
        except urllib.error.HTTPError as e:
            if e.code in (403, 410):
                raise RuntimeError(f"HTTP {e.code}: URL expired? Re-download the JSON") from e
            err = e
        except Exception as e:  # network errors, size/sha mismatch
            err = e
        print(f"  retry {attempt}/{MAX_RETRIES} {os.path.basename(dest)}: {err}", flush=True)
        time.sleep(min(2 ** attempt, 30))
    raise RuntimeError(f"failed after {MAX_RETRIES} attempts: {err}")


def human(n):
    for unit in ("B", "KB", "MB", "GB", "TB"):
        if abs(n) < 1024:
            return f"{n:.1f}{unit}"
        n /= 1024
    return f"{n:.1f}PB"


def fmt_duration(sec):
    sec = int(sec)
    d, rem = divmod(sec, 86400)
    h, rem = divmod(rem, 3600)
    m, s = divmod(rem, 60)
    return (f"{d}d" if d else "") + f"{h:02d}:{m:02d}:{s:02d}"


def main():
    parser = argparse.ArgumentParser(description="Download Project Aria dataset files from a URL JSON.")
    parser.add_argument("--url_json", required=True, help="Path to *_download_urls.json")
    parser.add_argument("--output_dir", required=True, help="Directory to save downloaded files")
    parser.add_argument("--num_workers", type=int, default=DEFAULT_NUM_WORKERS,
                        help=f"Number of URLs downloaded in parallel (default: {DEFAULT_NUM_WORKERS})")
    args = parser.parse_args()
    if args.num_workers < 1:
        parser.error("--num_workers must be >= 1")

    with open(args.url_json) as f:
        data = json.load(f)

    entries = list(collect_entries(data))
    if not entries:
        sys.exit(f"No file entries found in {args.url_json}")
    # Strip the "_" placeholder used for list items.
    jobs = [(e, os.path.join(args.output_dir, *[p for p in d.split(os.sep) if p and p != "_"], e["filename"]))
            for d, e in entries]
    total = sum(e.get("file_size_bytes") or 0 for e, _ in jobs)
    print(f"{len(jobs)} files" + (f", {human(total)}" if total else "") + f" -> {args.output_dir} ({args.num_workers} workers)")

    counts = {"downloaded": 0, "verified": 0, "skipped": 0, "failed": 0}
    failures = []
    progress = Progress(total, len(jobs))
    cache = VerifiedCache(args.output_dir)
    stop = threading.Event()
    reporter = threading.Thread(target=report_speed, args=(progress, stop), daemon=True)
    reporter.start()
    try:
        with ThreadPoolExecutor(max_workers=args.num_workers) as pool:
            futures = {pool.submit(download_one, e, dest, progress, cache): dest for e, dest in jobs}
            for i, fut in enumerate(as_completed(futures), 1):
                dest = futures[fut]
                info = ""
                try:
                    status, nbytes, secs = fut.result()
                    if status == "downloaded":
                        info = f" ({human(nbytes)} in {secs:.1f}s, {human(nbytes / secs) if secs > 0 else '-'}/s)"
                except Exception as e:
                    status = "failed"
                    failures.append((dest, str(e)))
                counts[status] += 1
                with progress.lock:
                    progress.done_files += 1
                print(f"[{i}/{len(jobs)}] {status:10s} {os.path.relpath(dest, args.output_dir)}{info}", flush=True)
    finally:
        stop.set()
        reporter.join()

    _, fetched, _ = progress.snapshot()
    wall = time.time() - progress.start
    print(f"Done: {counts['downloaded']} downloaded, {counts['verified']} verified, "
          f"{counts['skipped']} skipped, {counts['failed']} failed | "
          f"fetched {human(fetched)} in {fmt_duration(wall)} (avg {human(fetched / wall if wall else 0)}/s)")
    if failures:
        for dest, msg in failures:
            print(f"  FAILED {dest}: {msg}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
