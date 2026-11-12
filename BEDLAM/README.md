# BEDLAM

来源：<https://bedlam.is.tue.mpg.de/>、<https://github.com/pixelite1201/BEDLAM>、<https://huggingface.co/datasets/Intelligent-Systems/BEDLAM>（抓取于 2026-11-12）

BEDLAM（Bodies Exhibiting Detailed Lifelike Animated Motion，CVPR 2023）是 MPI-IS 发布的大规模合成人体视频数据集：用 Unreal Engine 5 渲染穿着物理仿真服装、带真实头发与皮肤纹理的 SMPL-X 人体，置于多样的 HDRI / 3D 场景中，配合多种相机运动（静止、环绕、推拉、特写等）。共 10,450 段图像序列（30 fps，1280×720，约 160 万帧），提供 RGB、深度（EXR）、分割掩码（身体 / 服装 / 头发 / 环境）、视频，以及相机、场景与 SMPL-X 真值。论文表明，只用 BEDLAM 训练的 HPS 回归器即可在真实基准上达到 SOTA 水平。

## 使用条款

需在官网注册并接受 [BEDLAM 许可](https://bedlam.is.tuebingen.mpg.de/license.html)：仅限**非商业科研用途**，**禁止再分发**下载的数据。商业授权请联系 smpl@max-planck-innovation.de。

## 下载 (Download)

### 方式一：Hugging Face 镜像（推荐，默认）

官方于 2026-02-26 将完整的图像与深度数据放到 Hugging Face 镜像上，下载更快，但仍需授权：

1. 打开 [Intelligent-Systems/BEDLAM](https://huggingface.co/datasets/Intelligent-Systems/BEDLAM) 和 [Intelligent-Systems/BEDLAM-depth](https://huggingface.co/datasets/Intelligent-Systems/BEDLAM-depth)，登录后接受 BEDLAM 许可（自动审批）。
2. 本机登录：`hf auth login`（`pip install -U huggingface_hub`）。

```bash
# 默认：全部序列的真值 + 视频（约 22 GB）
./download_bedlam.sh

# 全部 30fps PNG + 掩码 + 真值，下载后解包（约 2.4 TB）
./download_bedlam.sh -o /path/to/BEDLAM -x png masks ground_truth

# 只下载某个批次的深度
./download_bedlam.sh -q '20221010_3_1000_batch01hand' depth

# 全部（约 6.5 TB）
./download_bedlam.sh all
```

| 仓库 | 目录 | 内容 | 大小 |
|---|---|---|---:|
| BEDLAM | `<seq>/png/<seq>_png.N.tar` | 30 fps PNG 图像（1280×720） | ~2.39 TB |
| BEDLAM | `<seq>/masks/<seq>_masks.tar` | 分割掩码 | ~33 GB |
| BEDLAM | `<seq>/mp4/<seq>_mp4.tar` | MP4 视频 | ~22 GB |
| BEDLAM | `<seq>/ground_truth/<seq>_gt.tar.gz` | 相机 / 场景 / 人体真值（CSV + JSON） | ~0.1 GB |
| BEDLAM-depth | `<seq>/depth/<seq>_depth.N.tar` | 32-bit EXR 深度 | ~4.09 TB |

`<seq>` 为 30 个渲染批次，如 `20221010_3-10_500_batch01hand_zoom_suburb_d`。每个文件都附带 `.xxh128` 校验值（`xxhsum -c`）。

### 方式二：MPI 下载服务器（6fps 训练子集）

BEDLAM 训练代码使用的 6 fps 图像子集（27 个批次 tar + AGORA 图像）和训练标签，来自官方 [`fetch_training_data.sh`](https://github.com/pixelite1201/BEDLAM/blob/master/fetch_training_data.sh)，文件列表见 `bedlam_mpi_files.txt`：

```bash
export BEDLAM_USERNAME=...  # 官网注册的账号；不设置则交互输入
export BEDLAM_PASSWORD=...
./download_bedlam.sh -s mpi -x
```

请求格式（POST 账号密码，支持 `resume=1` 断点续传）：

```
wget --post-data "username=<u>&password=<p>" \
  'https://download.is.tue.mpg.de/download.php?domain=bedlam&resume=1&sfile=bedlam_images_train/<name>.tar' -O <name>.tar --continue
```

其余资产（身体 / 服装纹理、服装模型、SMPL-X 动作文件、原始 6 fps 图像等）请登录官网 [Download 页面](https://bedlam.is.tuebingen.mpg.de/download.php) 获取。

## 数据结构 (Dataset Overview)

```
BEDLAM/
└── <seq>/                       # 一个渲染批次，如 20221010_3_1000_batch01hand
    ├── png/<seq>_png.N.tar      # 解包后：<seq>/png/seq_XXXXXX/seq_XXXXXX_YYYY.png
    ├── masks/<seq>_masks.tar    # 每个人体的 body / clothing / hair 掩码及环境掩码
    ├── mp4/<seq>_mp4.tar        # 每个序列一个 mp4
    └── ground_truth/<seq>_gt.tar.gz  # 解包后含 be_seq.csv（序列/人体列表）、ground_truth/camera/*.csv 等
BEDLAM-depth/
└── <seq>/depth/<seq>_depth.N.tar  # EXR 深度，与 png 一一对应
```

真值（CSV）包含每个人体的 SMPL-X 参数、身体在相机坐标系下的位姿、相机内外参等。把渲染数据转换为训练用 `npz` 标签的脚本见 [BEDLAM 仓库](https://github.com/pixelite1201/BEDLAM) 的 `data_processing/df_full_body.py`（读取 `<seq>/png/`、`<seq>/be_seq.csv`、`<seq>/ground_truth/camera/`，场景列表见 `bedlam_scene_names.csv`），渲染管线见 [bedlam_render](https://github.com/PerceivingSystems/bedlam_render)。

## 许可 (License)

[BEDLAM 非商业许可](https://bedlam.is.tuebingen.mpg.de/license.html)（Hugging Face 镜像标注为 `bedlam-non-commercial`），禁止再分发。

## 引用

```bibtex
@inproceedings{Black_CVPR_2023,
  title     = {{BEDLAM}: A Synthetic Dataset of Bodies Exhibiting Detailed Lifelike Animated Motion},
  author    = {Black, Michael J. and Patel, Priyanka and Tesch, Joachim and Yang, Jinlong},
  booktitle = {Proceedings IEEE/CVF Conf.~on Computer Vision and Pattern Recognition (CVPR)},
  pages     = {8726--8737},
  month     = jun,
  year      = {2023},
}
```
