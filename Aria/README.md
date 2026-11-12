# Project Aria Resources

来源：<https://www.projectaria.com/resources/>（抓取于 2026-11-12）

## 数据集 (Datasets)

| # | 名称 | 简介 | 链接 |
|---|------|------|------|
| 1 | Aria Gen 2 Pilot Dataset | Aria Gen 2 多模态传感器数据，用于第一视角感知研究 | [link](https://www.projectaria.com/datasets/gen2pilot/) |
| 2 | Aria Synthetic Environments (ASE) | 程序化生成的大规模合成室内场景数据，用于 ML 训练 | [link](https://www.projectaria.com/datasets/ase/) |
| 3 | Aria Everyday Activities (AEA) | 原 Aria Pilot Dataset，早期多用途第一视角数据集 | [link](https://www.projectaria.com/datasets/aea/) |
| 4 | HOT3D | 基于视觉的手-物交互基准 | [link](https://www.projectaria.com/datasets/hot3D/) |
| 5 | Aria Digital Twin (ADT) | 真实数据配套动态、照片级真实感数字孪生 | [link](https://www.projectaria.com/datasets/adt/) |
| 6 | Digital Twin Catalog (DTC) | 物体重建数据集 | [link](https://www.projectaria.com/datasets/dtc/) |
| 7 | Nymeria | 大规模多模态全身运动理解数据集 | [link](https://www.projectaria.com/datasets/nymeria/) |
| 8 | Reading Recognition in the Wild | 100+ 小时真实场景数据，含 60Hz 眼动追踪 | [link](https://www.projectaria.com/datasets/reading-in-the-wild/) |
| 9 | Aria Everyday Objects (AEO) | 小规模真实场景数据集，带高质量静态 3D 有向包围盒标注 | [link](https://www.projectaria.com/datasets/aeo/) |

## 下载 (Download)

### 1. 获取 URL JSON

在各数据集页面点击 "ACCESS THE DATASETS"，提交邮箱并同意许可协议，下载得到的 `*_download_urls.json` 放到 `Aria/urls/`。

- JSON 中是带签名的个人下载链接，**会过期**；出现 HTTP 403 时需重新获取。
- `urls/` 已加入 `.gitignore`，请勿提交。

### 2. 下载全部数据集：`download_aria_all.sh`

```bash
cd Aria
./download_aria_all.sh                                   # 默认输出目录、并发 8
./download_aria_all.sh -o /Volumes/OtherDisk/aria -j 16  # 指定输出目录和并发数
```

| 参数 | 含义 | 默认值 |
|---|---|---|
| `-o OUTPUT_ROOT` | 所有数据集的根目录（支持相对路径，不存在会自动创建） | `/Volumes/Expansion0/3DRDatasets/aria` |
| `-j NUM_WORKERS` | 每个数据集并行下载的文件（URL）数 | `8` |

脚本逐条列出了 17 个 JSON 的下载命令，每个 JSON 保存到 `OUTPUT_ROOT/<名称>`。只想下载部分数据集时，注释掉对应行即可。单条命令失败不影响后续命令。

| 数据集 | JSON (`urls/`) | 输出目录 | 文件数 | 大小 |
|---|---|---|---:|---:|
| Gen 2 Pilot | `gen2pilot_download_urls.json` | `gen2pilot` | 156 | 148.0 GB |
| ASE | `aria_synthetic_environments_dataset_download_urls.json` | `aria_synthetic_environments_dataset` | 10100 | 未提供 |
| ASE | `ase_mesh_download_urls.json` | `ase_mesh` | 100 | 未提供 |
| ASE | `AriaSyntheticEnvironment_ATEK_download_urls.json` | `AriaSyntheticEnvironment_ATEK` | 163074 | 6.3 TB |
| AEA | `AriaEverydayActivities_download_urls.json` | `AriaEverydayActivities` | 1287 | 369.7 GB |
| HOT3D | `Hot3DAria_download_urls.json` | `Hot3DAria` | 1980 | 490.2 GB |
| HOT3D | `Hot3DQuest_download_urls.json` | `Hot3DQuest` | 904 | 366.8 GB |
| HOT3D | `Hot3DAssets_download_urls.json` | `Hot3DAssets` | 1 | 151.5 MB |
| ADT | `ADT_download_urls.json` | `ADT` | 2832 | 2.1 TB |
| ADT | `DTC_objects_ADT_download_urls.json` | `DTC_objects_ADT` | 1200 | 5.1 GB |
| ADT | `AriaDigitalTwin_ATEK_download_urls.json` | `AriaDigitalTwin_ATEK` | 6060 | 337.8 GB |
| DTC | `DTC_download_urls.json` | `DTC` | 1600 | 285.9 GB |
| DTC | `DTC_objects_all_download_urls.json` | `DTC_objects_all` | 11173 | 141.5 GB |
| DTC | `DTC_DSLR_download_urls.json` | `DTC_DSLR` | 210 | 202.2 GB |
| Nymeria | `Nymeria_download_urls.json` | `Nymeria` | 15109 | 46.7 TB |
| Reading in the Wild (Seattle) | `ReadingInTheWild_download_urls.json` | `ReadingInTheWild` | 3948 | 6.2 TB |
| AEO | `AEO_download_urls.json` | `AEO` | 100 | 17.4 GB |

> 合计约 65 TB 以上（ASE 两个 JSON 未提供文件大小）。Reading in the Wild 的 Columbus 子集不在官方 JSON 中，见 [GitHub](https://github.com/AIoT-MLSys-Lab/Reading-in-the-Wild-Columbus/)。
>
> 如果只为复现 [VGGT-Ω](https://arxiv.org/abs/2605.15195) 的训练数据，论文中可确认的 Aria 数据为 ASE、ADT、HOT3D（另 EFM3D 涉及 ASE/ADT/AEO），可只保留这些行。

### 3. 下载单个 JSON：`download_aria_script.py`

```bash
python download_aria_script.py --url_json urls/AEO_download_urls.json --output_dir /data/aria/AEO --num_workers 8
```

| 参数 | 含义 | 默认值 |
|---|---|---|
| `--url_json` | `*_download_urls.json` 路径 | 必填 |
| `--output_dir` | 输出目录 | 必填 |
| `--num_workers` | 并行下载的文件（URL）数 | `4` |

- **目录结构**：按 JSON 层级保存，例如 `<output_dir>/<序列>/<文件>`、ATEK 为 `<output_dir>/<配置>/<序列>/<分片>.tar`、物体库为 `<output_dir>/<版本>/<物体>/<文件>`。zip 文件不会自动解压。
- **完整性校验**：每个文件都有 SHA1（JSON 中为 `sha1sum` 或 `sha`，无 MD5），下载后校验大小和 SHA1。
- **断点续传 / 跳过**：下载中的文件写为 `.part`，中断后重跑会续传。校验通过的文件记录在 `<output_dir>/.aria_verified.tsv`，重跑时直接跳过（`skipped`，不重新计算 SHA1）；不在记录中的已有文件会重新校验（`verified`），损坏的会重新下载。删除 `.aria_verified.tsv` 可强制全部重新校验。
- **日志**：每 10 秒打印一行 `[speed]`（当前速度、平均速度、进度、剩余时间），每个文件完成时打印大小与速度，结束时打印汇总；链接过期（HTTP 403）会给出提示。
- 仅依赖 Python 标准库。

## 工具与模型 (Tools & Models)

| # | 名称 | 简介 | 链接 |
|---|------|------|------|
| 1 | EgoBlur | 第一视角数据隐私模糊工具 | [link](https://www.projectaria.com/tools/egoblur/) |
| 2 | SceneScript | 场景结构化重建模型 | [link](https://www.projectaria.com/scenescript/) |
| 3 | EFM3D | 第一视角 3D 基础模型研究 | [link](https://www.projectaria.com/research/efm3d/) |
| 4 | Photoreal Reconstruction | 照片级真实感重建 | [link](https://www.projectaria.com/photoreal-reconstruction/) |
| 5 | Boxer | 3D 物体检测模型 | [link](https://www.projectaria.com/news/introducing-boxer/) |
| 6 | Data Utilities | Aria 数据处理工具 | [link](https://facebookresearch.github.io/projectaria_tools/docs/data_utilities) |
| 7 | Eye Gaze Services (MPS) | 机器感知服务中的眼动估计 | [link](https://facebookresearch.github.io/projectaria_tools/docs/ARK/mps#eye-gaze-services) |
| 8 | ATEK | Aria Training & Evaluation Kit | [link](https://facebookresearch.github.io/projectaria_tools/docs/ATEK/about_ATEK) |
| 9 | Aria VRS Format | VRS 数据格式文档 | [link](https://facebookresearch.github.io/projectaria_tools/docs/data_formats/aria_vrs) |

## 浏览器、文档与论文 (Explorers, Docs & Papers)

| # | 名称 | 简介 | 链接 |
|---|------|------|------|
| 1 | Project Aria Dataset Explorer | 浏览、可视化、筛选和下载公开 Aria 数据集 | [link](https://explorer.projectaria.com/) |
| 2 | Object Explorer | 浏览和下载 DTC 3D 模型 | [link](https://dtc.projectaria.com/) |
| 3 | Project Aria Docs (Gen 1) | Gen 1 文档 | [link](https://facebookresearch.github.io/projectaria_tools/docs/intro) |
| 4 | Project Aria Docs (Gen 2) | Gen 2 文档 | [link](https://facebookresearch.github.io/projectaria_tools/gen2/) |
| 5 | GitHub: projectaria_tools | 官方代码仓库 | [link](https://github.com/facebookresearch/projectaria_tools) |
| 6 | HuggingFace: projectaria | 托管的模型与数据集 | [link](https://huggingface.co/projectaria) |
| 7 | Aria Gen 1 Device Paper | arXiv 2308.13561 | [link](https://arxiv.org/abs/2308.13561) |
| 8 | Aria Gen 2 Device Paper | Gen 2 设备论文 | [link](https://www.projectaria.com/ariagen2devicepaper/) |
