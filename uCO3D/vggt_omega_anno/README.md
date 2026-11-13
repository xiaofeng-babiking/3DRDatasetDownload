# uCO3D — vggt_omega_anno

来源：<https://huggingface.co/datasets/facebook/uco3d/tree/main/vggt_omega_anno>（抓取于 2026-11-13）

uCO3D（UnCommon Objects in 3D，[论文](https://huggingface.co/papers/2501.07574)，[代码](https://github.com/facebookresearch/uco3d)，[项目主页](https://uco3d.github.io/)）是以物体为中心的大规模真实多视图视频数据集。`vggt_omega_anno` 是官方 Hugging Face 仓库中额外发布的 VGGT 系列标注，按序列名的十六进制前缀打包成 tar 分片。

## 下载 (Download)

数据托管在 Hugging Face：[facebook/uco3d](https://huggingface.co/datasets/facebook/uco3d)，非 gated，无需登录。

| 项目 | 数值 |
|---|---|
| 文件数 | 228 个 `.tar` 分片 |
| 总大小 | 约 7.59 TB（7,593,060,884,480 bytes） |
| 单个分片 | 最大约 49 GB |
| 命名 | `<hex前缀>.tar`；较大的前缀拆成 `<hex前缀>-00.tar`、`<hex前缀>-01.tar`（共 184 个前缀，`00`–`fc`，中间有缺号） |

`download_vggt_omega_anno.sh` 使用 Hugging Face CLI（`pip install -U huggingface_hub`）一次性下载整个目录：

```bash
# 默认：下载全部分片到 /Volumes/Expansion0/3DRDatasets/uCO3D/vggt_omega_anno/
./download_vggt_omega_anno.sh

# 指定输出目录，并在下载后解压
./download_vggt_omega_anno.sh -o /path/to/uCO3D -x

# 只下载部分分片（按分片名通配，记得加引号）
./download_vggt_omega_anno.sh '0*' '1a*'

# 等价于：
hf download facebook/uco3d --repo-type dataset --include "vggt_omega_anno/*.tar" --local-dir .
```

**断点续传**：用 `--local-dir` 下载时，`hf download` 会在 `<local-dir>/.cache/huggingface/` 记录每个文件的元数据；重新运行同一命令会**跳过已完整下载的文件**，没下完的文件则接着下。中断后直接重跑脚本即可（不要删掉 `.cache/huggingface/` 目录）。`-x` 解压时会为每个分片写一个 `.<name>.tar.extracted` 标记，重跑时跳过已解压的分片。

⚠️ 全部下载需要约 7.6 TB 磁盘空间，`-x` 解压还要再占一份相同的空间。

## 数据结构 (Dataset Overview)

```
vggt_omega_anno/
├── 00.tar
├── 01-00.tar
├── 01-01.tar
├── ...
└── fc.tar
```

每个分片里是多个按 uCO3D 序列名命名的子 tar（如 `96-834-41325-1ba4a832c6c4ddcb4eed15924fc08ae8.tar`，单个约数百 MB），一个子 tar 对应一个序列的标注。

## 许可 (License)

Hugging Face 数据卡未声明许可证。使用前请参阅 [uCO3D 官方仓库](https://github.com/facebookresearch/uco3d) 中的许可说明。

## 引用

```bibtex
@inproceedings{liu2025uco3d,
  title     = {UnCommon Objects in 3D},
  author    = {Liu, Xingchen and Tayal, Piyush and Wang, Jianyuan and Zarzar, Jesus and Monnier, Tom and Tertikas, Konstantinos and Duan, Jiali and Toisoul, Antoine and Zhang, Jason Y. and Neverova, Natalia and Vedaldi, Andrea and Shapovalov, Roman and Novotny, David},
  booktitle = {CVPR},
  year      = {2025}
}
```
