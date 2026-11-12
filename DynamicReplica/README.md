# Dynamic Replica

来源：<https://dynamic-stereo.github.io/>、<https://github.com/facebookresearch/dynamic_stereo>（抓取于 2026-11-12）

Dynamic Replica 是 Meta AI 与牛津 VGG 在 DynamicStereo（CVPR 2023）中发布的合成双目视频数据集：把带动画的人体与动物放进 Replica 室内场景，用相机沿平滑轨迹拍摄。共 524 段双目视频，每段 300 帧（1280×720，30 fps），提供左右目 RGB、深度、实例分割、前后向光流、相机内外参，以及人体/动物表面点的长时轨迹。另有少量真实拍摄的 `real` 序列用于定性评测。主要用于评测**时序一致**的双目深度估计。

| 划分 | 解压后大小（含全部标注） |
|---|---:|
| train | 1.8 TB |
| valid | 106 GB |
| test | 328 GB |
| real | 152 MB |

## 下载 (Download)

1. 在 [项目网站](https://dynamic-stereo.github.io/) 的 **data** 标签页接受许可协议，下载 `links.json`（下载链接与账号相关，所以不放在本仓库中）。
2. 运行脚本：它会把官方仓库克隆到 `OUTPUT_ROOT/_code/dynamic_stereo`，按需安装 `requirements.txt`（官方下载器依赖的 `requests`、`tqdm`），再调用官方 Python 下载器。可用环境变量 `PYTHON` 指定解释器（默认 `python3`）。

```bash
# 默认：real + valid + test
./download_dynamic_replica.sh -l ~/Downloads/links.json

# 全部划分，解压后删除压缩包，8 个并行线程
./download_dynamic_replica.sh -l ~/Downloads/links.json -o /path/to/DynamicReplica -c -w 8 real valid test train
```

官方下载器会校验 SHA256（`scripts/dr_sha256.json`），并跳过已下载的压缩包，中断后重新运行同一命令即可继续。

等价的官方命令：

```bash
git clone https://github.com/facebookresearch/dynamic_stereo
cd dynamic_stereo
export PYTHONPATH=`(cd ../ && pwd)`:`pwd`:$PYTHONPATH
python ./scripts/download_dynamic_replica.py --link_list_file links.json \
  --download_folder ./dynamic_replica_data --download_splits real valid test train
```

## 数据结构 (Dataset Overview)

```
dynamic_replica_data/
├── train/
│   ├── frame_annotations_train.jgz   # gzip 压缩的 JSON：每帧的路径、相机参数、元数据
│   └── <sequence>_<left|right>/...    # 每个序列、每个相机的 images / depths / masks / 光流 / 轨迹
├── valid/
│   └── frame_annotations_valid.jgz ...
├── test/
│   └── frame_annotations_test.jgz ...
└── real/
```

`frame_annotations_<split>.jgz` 的每条记录给出 `image.path`、`depth.path`、`mask.path`（相对 `<split>/`）、`viewpoint`（PyTorch3D 风格的 R、T、焦距、主点）等字段。按序列遍历数据可以直接用官方的 PyTorch 数据集类 [`DynamicReplicaDataset`](https://github.com/facebookresearch/dynamic_stereo/blob/main/datasets/dynamic_stereo_datasets.py)。

## 许可 (License)

数据需在项目网站接受许可协议后才能下载。代码仓库主体为 CC-BY-NC（部分第三方组件为 MIT / Apache 2.0）。

## 引用

```bibtex
@article{karaev2023dynamicstereo,
  title   = {DynamicStereo: Consistent Dynamic Depth from Stereo Videos},
  author  = {Nikita Karaev and Ignacio Rocco and Benjamin Graham and Natalia Neverova and Andrea Vedaldi and Christian Rupprecht},
  journal = {CVPR},
  year    = {2023}
}
```
