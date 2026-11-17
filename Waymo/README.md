# Waymo Open Dataset

使用 [Waymo 官方下载页面](https://waymo.com/open/download/)列出的 Google Cloud Storage 桶，核验于 2026-11-17。先在官网申请/取得数据访问权限，再安装 Google Cloud CLI，并用获授权的 Google 账号执行 `gcloud auth login`。

| `--release` | 发行版 | 官方桶 |
|---|---|---|
| `perception-v2`（默认） | Perception 2.0.1，模块化 Parquet | `waymo_open_dataset_v_2_0_1` |
| `perception-v1` | Perception 1.4.3，含地图 | `waymo_open_dataset_v_1_4_3` |
| `motion` | Motion 1.3.1 | `waymo_open_dataset_motion_v_1_3_1` |
| `end-to-end` | End-to-End Driving 1.0.0 | `waymo_open_dataset_end_to_end_camera_v_1_0_0` |

```bash
bash Waymo/download_waymo.sh --list
bash Waymo/download_waymo.sh --release perception-v2 --prefix training/camera_image --list
bash Waymo/download_waymo.sh --target_dir /path/to/Waymo --dry-run
bash Waymo/download_waymo.sh --target_dir /path/to/Waymo --release perception-v2
```

默认下载选定发行版的整个桶；其他发行版分别运行。可用 `--prefix` 选择已有桶子目录。文件保留在 `目标目录/发行版/桶内相对路径`，避免不同发行版互相覆盖。

使用 [`gcloud storage rsync`](https://cloud.google.com/sdk/gcloud/reference/storage/rsync) 增量下载并显示进度，固定加 `--recursive --do-not-decompress`，不会删除本地多余文件，也不做解压或格式转换。重试、完整性判断和传输续传由 Cloud CLI 管理。遇到 401/403 应检查账号和官网授权，脚本不会自动登录或接受条款。
