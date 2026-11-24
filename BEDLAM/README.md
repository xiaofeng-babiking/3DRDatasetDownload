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

### BEDLAM-depth 专用脚本（默认官网源）

[`download_bedlam_depth.sh`](download_bedlam_depth.sh) 默认按 [BEDLAM 官方下载页](https://bedlam.is.tue.mpg.de/download.php) 的完整深度下载流程，使用 MPI 服务器；`-s hf` 可切换到官方 [Hugging Face 镜像](https://huggingface.co/datasets/Intelligent-Systems/BEDLAM-depth)。这里下载的是 **30 fps 的完整 EXR 深度数据**：30 个批次、每批次 5 个 tar 分片，共 150 个文件，约 4.09 TB。

官网协议和文件列表取自 [官方 `be_imagedata_download.zip`](https://bedlam.is.tuebingen.mpg.de/media/upload/be_imagedata_download.zip)，核对日期为 2026-11-22。其中 `be_download.sh` 结合 `b0.txt` 生成 `b0/<批次>/depth/<批次>_depth.0.tar` 至 `.4.tar`。本目录的 [`bedlam_depth_checksums.xxh128`](bedlam_depth_checksums.xxh128) 原样保存官方包中的 `b0_checksums_depth.xxh128`，既作为 150 个文件的下载清单，也用于可选的 XXH128 校验。文件内是 `32 位十六进制校验值 + 两个空格 + tar 文件名`，没有 `b0/` 前缀；脚本会转换为实际保存路径。

先在官网注册并接受许可。官网模式需要 `wget`、`file` 和 Bash；未设置 `BEDLAM_USERNAME`、`BEDLAM_PASSWORD` 时，脚本会在终端提示输入注册邮箱和密码，密码不回显。也可以通过环境变量提供这两个值；脚本将 URL 编码后的表单放在权限为 `0600` 的临时文件中，使用 `wget --post-file`，退出时清理该文件，保持正常的 TLS 证书验证。

在本目录执行：

```bash
# 离线预览官方清单中的文件和 URL；不联网、不创建输出目录、不需要凭据
./download_bedlam_depth.sh --dry-run

# 默认使用官网源下载全部深度数据，同时下载 4 个文件
./download_bedlam_depth.sh

# 指定输出根目录、并发数和批次；glob 必须加引号
./download_bedlam_depth.sh -o /path/to/BEDLAM -j 2 -q '20221010_*'

# 可选：逐个校验已存在和新下载的文件（需 xxhsum 0.8.1 或更新版本）
./download_bedlam_depth.sh -q '20221010_3_1000_batch01hand' --verify

# 改用 Hugging Face；先安装 huggingface_hub、接受该仓库访问条件并 hf auth login
./download_bedlam_depth.sh -s hf -q '20221010_*'
```

`-o` 与原脚本含义一致：默认根目录为 `/Volumes/Expansion1/3DRDatasets/BEDLAM`，两个源都保存到 `<输出根目录>/BEDLAM-depth/<批次>/depth/`。`-q` 无匹配时直接报错。`-n` / `--dry-run` 对两个源均使用本地官方清单预览，不查询在线权限、文件大小或本地完成情况。

官网模式把未完成传输保存为 `<文件名>.part`；成功返回并通过 tar 文件类型检查后才重命名为最终文件。已存在的 tar 会跳过，添加 `--verify` 后也会校验这些文件。脚本会拒绝服务器以 HTTP 200 返回的 HTML 登录错误页；错误内容或校验失败的新文件会保留为 `.part.rejected.*`，方便检查及重新下载。网络中断后重新执行同一命令即可续传。若完整 `.part` 的续传得到 HTTP 416，脚本会要求用 `xxhsum` 核对官方校验值后才确认完成。已存在的最终文件若校验失败会原样保留并报错，请先检查或移走该文件再重试。默认的文件类型检查不能替代完整校验；`--verify` 会读取全部已选文件，数 TB 数据校验需要时间。

HF 模式使用 `hf` 自带的续传机制，并下载所选 tar 对应的 `.xxh128` 文件、`README.md` 和 `LICENSE.md`；保留 `BEDLAM-depth/.cache/huggingface/` 中的下载元数据。HF 身份使用 `hf auth login` 或 `HF_TOKEN`，与官网邮箱密码分别配置。两个模式都不解包或删除下载的数据。

相机真值和 RGB 图像位于另一个 BEDLAM 仓库，如需同批次相机参数，可使用 `./download_bedlam.sh -q '20221010_*' ground_truth` 单独下载。

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
