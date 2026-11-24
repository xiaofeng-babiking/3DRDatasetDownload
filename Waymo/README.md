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

# 只下载 Perception 2.0.1
bash Waymo/download_waymo.sh --target_dir /path/to/Waymo --release perception-v2

# 选择两套；重复选择同一版本时只执行一次
bash Waymo/download_waymo.sh --target_dir /path/to/Waymo --release motion --release end-to-end

# 查看或下载单一版本下的子目录
bash Waymo/download_waymo.sh --release perception-v2 --prefix training/camera_image --list
bash Waymo/download_waymo.sh --target_dir /path/to/Waymo --release perception-v2 --prefix training/camera_image

# 从仓库统一入口调用，参数在 -- 后传入
bash download_dataset.sh waymo --target_dir /path/to/Waymo -- --release all --dry-run
```

默认目标目录为当前工作目录下的 `./data/Waymo`。文件保留在 `目标目录/发行版/桶内相对路径`，三个版本分别位于 `end-to-end/`、`motion/`、`perception-v2/`。`--target_dir` 必须是本地目录。`--prefix` 可选择已有桶子目录，只能与一个 `--release` 搭配，允许目录末尾带 `/`。不同版本的目录结构不同，先通过 `--list` 查看；`--list` 和 `--dry-run` 互斥，均需要联网和桶访问权限。

使用 [`gcloud storage rsync`](https://docs.cloud.google.com/sdk/gcloud/reference/storage/rsync) 增量下载并显示进度，开启 `--recursive`，不会删除本地多余文件，也不做解压或格式转换。脚本自动检测 CLI 是否支持 `--do-not-decompress`：支持时添加该参数，旧版则沿用默认保留压缩数据的行为（Google 在 [576.0.0 发布说明](https://docs.cloud.google.com/sdk/docs/release-notes#57600_2026-07-14)中记录了这项变更）。

版本之间依次执行，单个版本内的文件传输由 Cloud CLI 并行处理；重试、完整性判断和传输续传由 Cloud CLI 管理。某个版本失败时仍尝试其他已选择版本，最后汇总失败版本并返回非零；重新执行原命令即可继续。遇到 401/403 应检查账号和官网授权；遇到 `invalid_grant` 应重新运行 `gcloud auth login`，脚本不会自动登录或接受条款。
