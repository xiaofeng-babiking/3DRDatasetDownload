# 数据集下载入口

覆盖给定论文清单的 30 个数据集名称。新增下载源按官方页面、代码或文件清单核对（2026-11-17），各目录 README 提供来源。不同发行版的内容并不相同；下表列出脚本实际范围，而不是假定复现了论文未提供的全部预处理数据。

## 统一用法

```bash
bash download_dataset.sh --list
bash download_dataset.sh DATASET --help
bash download_dataset.sh DATASET --target_dir /path/to/output -- DATASET_OPTIONS

# 例如：下载 SAIL-VOS 3D，4 个并发任务
bash download_dataset.sh sailvos3d --target_dir /data/SAIL-VOS-3D -- --n_workers 4

# 例如：只选择 CO3Dv2 的两个类别
bash download_dataset.sh co3dv2 --target_dir /data/Co3Dv2 -- --categories apple,chair

# 例如：DL3DV 的某一分区，先离线查看将运行的命令
bash download_dataset.sh dl3dv --target_dir /data/DL3DV -- --subset 1K --resolution 480P --dry_run
```

未传 `--target_dir` 时，统一入口下载到当前工作目录下的 `./data/<name>`。传入目录本身就是该数据集的根目录；个别脚本会在其中按发行版/子集建子目录。脚本路径按仓库位置解析，可从其他工作目录调用。

`--` 后保留各数据集原有参数。旧脚本的短选项请分开写，如 `-s mpi`，不要合并为 `-smpi`。统一入口禁止解压、删除压缩包及 BEHAVIOR 的 `assets` 安装模式；部分旧脚本直接调用时仍保留历史的 `-x` 等可选功能。**以下示例全部只下载**。

## 30 项覆盖表

| # | 数据集 / 统一名称 | 下载脚本 | 实际范围、前置条件及完整范围选项 |
|---|---|---|---|
| 1 | Aria series / `aria` | [download_aria.sh](Aria/download_aria.sh) | AEA（默认）、ADT、AEO、ASE、Nymeria 等；使用 `--dataset` 选择，提供对应个人 CDN JSON。各系列分别运行。 |
| 2 | BEDLAM / `bedlam` | [download_bedlam.sh](BEDLAM/download_bedlam.sh) | 已有 HF/官方 MPI 两种入口，需账号或访问权；默认 GT+视频，HF 全模态使用 `-- all`；MPI 是脚本清单中的训练子集。 |
| 3 | BEHAVIOR-1K / `behavior1k` | [download_behavior_1k.sh](BEHAVIOR-1K/download_behavior_1k.sh) | 统一入口默认 `assets_zip`，保留加密场景/物体资产包；`-- demos rawdata assets_zip` 另下载 2025 示范与原始数据。资产包不是渲染好的全部 RGB-D 轨迹。 |
| 4 | Co3Dv2 / `co3dv2` | [download_co3dv2.sh](Co3Dv2/download_co3dv2.sh) | 默认全部类别的 full 归档和元数据；支持单序列子集及类别筛选。 |
| 5 | uCo3D / `uco3d` | [download_uco3d.sh](uCO3D/download_uco3d.sh) | 官方完整数据归档，默认全类别/全模态；可选择官方 HF 或 CDN。已有 VGGT 注释脚本不是本入口的替代品。 |
| 6 | DL3DV / `dl3dv` | [download_dl3dv.sh](DL3DV/download_dl3dv.sh) | 默认全分区 480P images+poses；可选 960P/2K/4K、视频、COLMAP；需 HF 仓库访问权及登录。 |
| 7 | Dynamic Replica / `dynamicreplica` | [download_dynamic_replica.sh](DynamicReplica/download_dynamic_replica.sh) | 提供 `-l links.json`；完整四划分用 `-- -l FILE train valid test real`，旧默认不含 train。 |
| 8 | EDEN / `eden` | [download_eden.sh](EDEN/download_eden.sh) | 默认主要模态，全部模态使用 `-- all`；`-s` 选择样本。 |
| 9 | EFM3D / `efm3d` | [download_efm3d.sh](EFM3D/download_efm3d.sh) | ASE 的 EFM train/eval/mesh、六条 ADT 评估序列及 mesh、AEO；需要相关 Aria JSON，与 Aria 数据有重叠。 |
| 10 | HOT3D / `hot3d` | [download_hot3d.sh](HOT3D/download_hot3d.sh) | 默认 Aria+Quest+Assets 的完整 VRS 发行版；先取得三个个人 JSON。 |
| 11 | Habitat / `habitat` | [download_habitat.sh](Habitat/download_habitat.sh) | 本仓库将此名称具体映射到 **HM3D v0.2** mesh/config/semantics；需 Matterport 凭证，公开 example 无需；不会渲染 RGB-D。 |
| 12 | Hypersim / `hypersim` | [download_hypersim.sh](Hypersim/download_hypersim.sh) | 现有官方清单的全部 457 个场景 ZIP，可按场景通配符筛选。 |
| 13 | Mapfree / `mapfree` | [download_mapfree.sh](Mapfree/download_mapfree.sh) | 默认官方 train/val/test/COLMAP ZIP；sample 是需另选的重复子集。 |
| 14 | Mapillary Metropolis / `mapillarymetropolis` | [download_mapillary_metropolis.sh](MapillaryMetropolis/download_mapillary_metropolis.sh) | **授权 URL/TSV 入口**：从官网登录后取得文件链接，不自动枚举门户全量文件。 |
| 15 | MPSD / `mpsd` | [download_mpsd.sh](MPSD/download_mpsd.sh) | **授权 URL/TSV 入口**：Mapillary Planet-Scale Depth，先取得官方文件链接。 |
| 16 | MegaDepth / `megadepth` | [download_megadepth.sh](MegaDepth/download_megadepth.sh) | Cornell 原始图像/深度包及 SfM 模型包，默认两者都下载。 |
| 17 | MegaSynth / `megasynth` | [download_megasynth.sh](MegaSynth/download_megasynth.sh) | 默认官方 HF 的 split 0–99，可指定范围。 |
| 18 | Mid-Air / `midair` | [download_midair.sh](Mid-Air/download_midair.sh) | 先用官方表单生成下载配置，传 `-- -c FILE`；范围取决于表单选择。 |
| 19 | Mvssynth / `mvssynth` | [download_mvs_synth.sh](MVS-Synth/download_mvs_synth.sh) | 官方 HF，默认 1080；全部分辨率使用 `-- all`。 |
| 20 | ParallelDomain-4D / `paralleldomain4d` | [download_paralleldomain4d.sh](ParallelDomain-4D/download_paralleldomain4d.sh) | 默认基础模态；含附加模态使用 `-- pd4d pd4d_other`。 |
| 21 | Replica / `replica` | [download_replica.sh](Replica/download_replica.sh) | 原始 v1.0 的 17 个分卷及 Habitat 配置；不是第三方渲染的 SLAM 子集，不合并分卷。 |
| 22 | SAIL-VOS / `sailvos` | [download_sailvos.sh](SAIL-VOS/download_sailvos.sh) | 原始 train/val；3D 扩展另用 [`sailvos3d`](SAIL-VOS/download_sailvos_3d.sh)，全部 51 个文件。 |
| 23 | ScanNet Series / `scannet` | [download_scannet.sh](ScanNet/download_scannet.sh) | 取得访问权后传 `--official_script FILE.py`；ScanNet++ 另用 [`scannetpp`](ScanNet/download_scannetpp.sh)，当前仅支持获授权 URL/TSV，不自动生成全量链接。 |
| 24 | TartanAirV2 / `tartanairv2` | [download_tartanair_v2.sh](TartanAirV2/download_tartanair_v2.sh) | 已有官方文件清单，默认全环境/难度/模态/相机；可筛选，使用 HF 或 AirLab。 |
| 25 | TartanGround / `tartanground` | [download_tartanground.sh](TartanGround/download_tartanground.sh) | 已有官方清单，默认全环境/版本/轨迹/模态/相机；可筛选。 |
| 26 | Taskonomy / `taskonomy` | [download_taskonomy.sh](Taskonomy/download_taskonomy.sh) | 官网推荐的 Omnidata Taskonomy 组件；默认 fullplus/all，需 `omnidata-tools`、`aria2c`。 |
| 27 | UnrealStereo4K / `unrealstereo4k` | [download_unrealstereo4k.sh](UnrealStereo4K/download_unrealstereo4k.sh) | 默认完整 4K 的 0–8 场景；`-q` 为低分辨率版本。 |
| 28 | Virtual KITTI / `virtualkitti` | [download_vkitti.sh](VirtualKITTI/download_vkitti.sh) | 默认原版 v1.3.1 全部六个模态包；v2.0.3 另用 [`virtualkitti2`](VirtualKITTI2/download_vkitti2.sh)，其全部模态使用 `-- all`。 |
| 29 | Waymo / `waymo` | [download_waymo.sh](Waymo/download_waymo.sh) | 默认依次下载 E2E 1.0.0、Motion 1.3.1、Perception 2.0.1；可重复 `--release` 选择版本，旧版 Perception 1.4.3 需显式选择；需官方授权及 `gcloud auth login`。 |
| 30 | WildRGBD / `wildrgbd` | [download_wildrgbd.sh](WildRGBD/download_wildrgbd.sh) | 官方 46 类、93 个 ZIP/分卷，支持类别筛选，不合并分卷。 |

## 授权数据的运行示例

```bash
# Aria：从官网取得个人下载 JSON 后使用
bash download_dataset.sh aria --target_dir /data/Aria/AEA -- \
  --dataset aea --url_json /path/to/AriaEverydayActivities_download_urls.json

# HOT3D：目录内放入 Aria、Quest、Assets 三份官方 JSON
bash download_dataset.sh hot3d --target_dir /data/HOT3D -- --urls_dir /path/to/urls

# ScanNet：获批后官方提供的脚本仍保留自身许可交互
bash download_dataset.sh scannet --target_dir /data/ScanNet -- \
  --official_script /path/to/download-scannet.py

# HM3D：凭证放在用户自己的 netrc 中
bash download_dataset.sh habitat --target_dir /data/HM3D -- --netrc /path/to/matterport.netrc

# Mapillary / MPSD / ScanNet++：取得实际直链后准备 TSV
bash download_dataset.sh mpsd --target_dir /data/MPSD -- --manifest /path/to/mpsd.tsv
```

TSV 不带表头，每行是 `相对保存路径<Tab>官方直链`，允许空行和 `#` 注释。需填真实且未过期的链接；网页地址不等于文件直链。清单及个人 token 应保存在自己的位置，更新过期链接时保留相对文件名以续传。

## 依赖与续传

- 普通 HTTP 入口使用 `wget`，缺少时回退到 `curl`；部分旧脚本要求 `wget`。共同 helper 显示速度，把未完成内容保存在 `.part` 中，成功后重命名，已完成文件直接跳过。
- JSON 清单解析和 Aria 下载器使用 Python 3。HF 入口依赖 `huggingface_hub`/`hf`；需要登录时由用户运行 `hf auth login`。建议在自己的虚拟环境中安装依赖。部分历史 Python 封装仍会按其 README 自动安装缺少的 requirements；`--help` 不会触发安装。
- 本机默认的 python.org Python 3.13 在 HTTPS 检查中报告缺少 CA 证书。使用该解释器进行 Aria/其他 Python HTTPS 下载前，需运行它随安装提供的 `Install Certificates.command`，或切换到证书配置正常的 Python 环境；本次未修改全局 Python 环境，也未关闭证书校验。`wget`/`curl` 的证书校验正常。
- Taskonomy 使用 `omnidata-tools` 和 `aria2c`，Waymo 使用 Google Cloud CLI。相应工具负责进度、重试与续传。ScanNet 原始官方下载器没有通用 helper 的速度/部分文件续传功能，可改用授权 URL/TSV 模式。
- 普通 HTTP helper 不为既有最终文件重新校验内容；Aria 使用清单提供的 SHA1，Dynamic Replica 沿用其 SHA256 校验，HF/Cloud CLI 使用各自完整性机制。
- 一些完整数据集达到 TB 级；模态、相机、子集和发行版应按实际需要选择。脚本不会完成许可申请、代答协议或绕过访问控制。

## 本次验证范围

已检查 Bash 3.2 语法、33 个统一入口的离线 `--help`、官方清单筛选与参数转发，并用本机 HTTP 服务验证 `wget`/`curl` 的续传、跳过、失败处理及清单路径校验。未启动实际数据集下载，也未验证用户受限账号或全量归档传输。
