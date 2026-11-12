# SceneNet RGB-D

来源：<https://robotvault.bitbucket.io/scenenet-rgbd.html>、<https://huggingface.co/datasets/haotongl/SceneNetRGBD>（抓取于 2026-11-12）

SceneNet RGB-D 是 Imperial College Dyson Robotics Lab 发布的大规模照片级合成室内数据集：在随机生成的室内布局中，用 Chrono 物理引擎随机抛洒 ShapeNet 物体，再用 NVIDIA OptiX 光线追踪沿随机相机轨迹渲染。共 16,865 条轨迹（训练 15K+，验证 1K），每条 300 帧（320×240），总计约 500 万张图像，提供 RGB、深度、实例分割、光流和相机位姿真值。

## ⚠️ 下载链接现状

官网上的所有下载链接（`www.doc.ic.ac.uk/~bjm113/scenenet_data/...`）在 2026-11-12 测试**均返回 404**。本脚本改用 Hugging Face 上的**非官方镜像** [haotongl/SceneNetRGBD](https://huggingface.co/datasets/haotongl/SceneNetRGBD)。镜像声明版权归原作者所有，仅供学术研究使用；镜像没有提供校验值，请自行核对文件完整性。

## 下载 (Download)

```bash
# 默认：验证集 + 全部 protobuf
./download_scenenet_rgbd.sh

# 完整训练集 + 验证集 + protobuf，并解压（约 292 GB）
./download_scenenet_rgbd.sh -o /path/to/SceneNet-RGBD -x all

# 只下载某个训练分片
./download_scenenet_rgbd.sh train_0 protobuf
```

| 文件 | 大小 | 内容 |
|---|---:|---|
| `SceneNetRGBD-val.tar.gz` | 15.5 GB | 验证集（1,000 条轨迹） |
| `train_0.tar.gz` ~ `train_16.tar.gz` | 每个约 16.6 GB，共约 277 GB | 训练集 17 个分片 |
| `protobufs/scenenet_rgbd_val.pb` | 32 MB | 验证集轨迹、相机位姿、实例→类别映射 |
| `protobufs/scenenet_rgbd_train_N.pb` | 每个约 32 MB | 训练分片 N 对应的 protobuf |

官网原始链接（已失效，仅作记录）：`SceneNet-train.tar.gz`（263 GB）、`train_protobufs.tar.gz`（323 MB）、`SceneNetRGBD-val.tar.gz`（15 GB）、`scenenet_rgbd_val.pb`（31 MB）、`train_split/train_{0..16}.tar.gz`（每个 16 GB）。

## 数据结构 (Dataset Overview)

解压需要较长时间（子目录数量极多）。解析代码见官方 [pySceneNetRGBD](https://github.com/jmccormac/pySceneNetRGBD)。

```
train/0/                      # 分片 0
├── 0/                        # 轨迹编号
│   ├── photo/      0.jpg, 25.jpg, 50.jpg, ...   # RGB (320x240)
│   ├── depth/      0.png, 25.png, ...           # 16-bit PNG，单位毫米
│   └── instance/   0.png, 25.png, ...           # 实例 ID，类别映射见 protobuf
├── 1/
└── ...
```

- 每条轨迹 300 帧，文件名为渲染时刻（每隔 25 个时间步一帧）。
- 相机位姿、实例→WordNet/NYU 类别映射都保存在对应的 `.pb` 文件中，用 `scenenet.proto` 解析。
- 光流需用 pySceneNetRGBD 中的脚本由位姿和深度计算得到。

## 许可 (License)

官网标注为 GPL。

## 引用

```bibtex
@inproceedings{McCormac:etal:ICCV2017,
  title     = {SceneNet RGB-D: Can 5M Synthetic Images Beat Generic ImageNet Pre-training on Indoor Segmentation?},
  author    = {McCormac, John and Handa, Ankur and Leutenegger, Stefan and Davison, Andrew J},
  booktitle = {Proceedings of the IEEE International Conference on Computer Vision (ICCV)},
  year      = {2017}
}

@article{McCormac:etal:arXiv2016,
  title   = {SceneNet RGB-D: 5M Photorealistic Images of Synthetic Indoor Trajectories with Ground Truth},
  author  = {McCormac, John and Handa, Ankur and Leutenegger, Stefan and Davison, Andrew J},
  journal = {arXiv preprint arXiv:1612.05079},
  year    = {2016}
}
```
