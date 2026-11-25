# Waymo Open Dataset

使用 [Waymo 官方下载页面](https://waymo.com/intl/en-ca/open/download/)列出的 Google Cloud Storage 桶，核验于 2026-11-22。默认依次下载下面三个版本（`--release all`）：End-to-End 1.0.0、Motion 1.3.1、Perception 2.0.1。先在[官网](https://waymo.com/open/download/)取得对应数据的访问权限，再安装 Google Cloud CLI，并用获授权的 Google 账号执行 `gcloud auth login`。

| `--release` | 发行版 | 官方桶 |
|---|---|---|
| `end-to-end` | End-to-End Driving 1.0.0，Camera | [`waymo_open_dataset_end_to_end_camera_v_1_0_0`](https://console.cloud.google.com/storage/browser/waymo_open_dataset_end_to_end_camera_v_1_0_0) |
| `motion` | Motion 1.3.1 | [`waymo_open_dataset_motion_v_1_3_1`](https://console.cloud.google.com/storage/browser/waymo_open_dataset_motion_v_1_3_1) |
| `perception-v2` | Perception 2.0.1，模块化 Parquet，不含地图 | [`waymo_open_dataset_v_2_0_1`](https://console.cloud.google.com/storage/browser/waymo_open_dataset_v_2_0_1) |

兼容保留 `--release perception-v1`（Perception 1.4.3，桶 `waymo_open_dataset_v_1_4_3`），仅在显式指定时下载，不包含在 `all` 中。

```bash
# 列出三个桶的顶层目录，不下载
bash Waymo/download_waymo.sh --list

# 预览三个版本的增量下载计划，不下载数据
bash Waymo/download_waymo.sh --target_dir /path/to/Waymo --dry-run

# 下载三个版本的全部数据（与 --release all 等价）
bash Waymo/download_waymo.sh --target_dir /path/to/Waymo

# 只下载 Motion 1.3.1；先预览，再同步
bash Waymo/download_waymo.sh --release motion --dry-run
bash Waymo/download_waymo.sh --release motion

# 只下载 Perception 2.0.1
bash Waymo/download_waymo.sh --target_dir /path/to/Waymo --release perception-v2

# 只下载 Perception 2.0.1 和 End-to-End 1.0.0
bash Waymo/download_waymo.sh --release perception-v2 --release end-to-end

# 选择两套；重复选择同一版本时只执行一次
bash Waymo/download_waymo.sh --target_dir /path/to/Waymo --release motion --release end-to-end

# 查看或下载单一版本下的子目录
bash Waymo/download_waymo.sh --release perception-v2 --prefix training/camera_image --list
bash Waymo/download_waymo.sh --target_dir /path/to/Waymo --release perception-v2 --prefix training/camera_image

# 从仓库统一入口调用，参数在 -- 后传入
bash download_dataset.sh waymo --target_dir /path/to/Waymo -- --release all --dry-run
```

直接运行脚本时默认下载到 `/Volumes/Expansion1/3DRDatasets/Waymo`；统一入口 `download_dataset.sh waymo` 默认使用 `./data/waymo`。文件保留在 `目标目录/发行版/桶内相对路径`，三个版本分别位于 `end-to-end/`、`motion/`、`perception-v2/`。`--target_dir` 必须是本地目录。`--prefix` 可选择已有桶子目录，只能与一个 `--release` 搭配，允许目录末尾带 `/`。不同版本的目录结构不同，先通过 `--list` 查看；`--list` 和 `--dry-run` 互斥，均需要联网和桶访问权限。

整桶下载使用 Google Cloud CLI 附带的原生 `gsutil -m rsync -r -e`。该命令通过对象列表同步，账号可以列出和读取对象时就能下载。它保留 Motion 的 `uncompressed/`、Perception 的各级子目录，也会下载 End-to-End 直接放在桶根的分片和 JSON 文件。旧脚本用 `gcloud storage rsync` 同步桶根时会额外请求 `storage.buckets.get`，可能在下载前返回 403。[Google Cloud 权限说明](https://docs.cloud.google.com/storage/docs/access-control/iam-gsutil)

`--list` 使用 `gcloud storage ls`。指定 `--prefix` 时，脚本对选定子目录执行 [`gcloud storage rsync`](https://docs.cloud.google.com/sdk/gcloud/reference/storage/rsync)，并在 CLI 支持时添加 `--do-not-decompress`。整桶预览使用 `gsutil rsync -n`；若目标目录尚不存在，脚本会用临时空目录进行比较。两种下载方式都会保留本地额外文件，重新运行相同命令可继续同步。

版本之间依次执行，单个版本内的文件传输由 Cloud CLI 并行处理；重试、完整性判断和传输续传由 Cloud CLI 管理。某个版本失败时仍尝试其他已选择版本，最后汇总失败版本并返回非零；重新执行原命令即可继续。遇到 401/403 应检查账号和官网授权；遇到 `invalid_grant` 应重新运行 `gcloud auth login`，脚本不会自动登录或接受条款。
