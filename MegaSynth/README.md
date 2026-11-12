# MegaSynth

来源：<https://hwjiang1510.github.io/MegaSynth/>、<https://huggingface.co/datasets/hwjiang/MegaSynth>（抓取于 2026-11-12）

MegaSynth 是一个用于扩展前馈式三维场景重建（如 LRM 类大模型）训练规模的程序化合成数据集，共约 **70 万个场景**，规模约为 DL3DV 的 70 倍。每个场景由随机户型（floor plan）、随机组合的基础几何物体、随机纹理与光照生成，并用随机相机渲染。语义信息被刻意去除，只保留几何与外观的多样性，同时提供精确的相机元数据。论文表明，与真实数据混合训练后可显著提升重建效果。

## 下载 (Download)

数据托管在 Hugging Face：[hwjiang/MegaSynth](https://huggingface.co/datasets/hwjiang/MegaSynth)（不需要申请），共 100 个分卷 `split_0.zip` ~ `split_99.zip`，每个约 40 GB，总计约 **4.04 TB**。

```bash
# 先下载一个分卷看看
./download_megasynth.sh -x 0

# 前 10 个分卷，解压后删除 zip
./download_megasynth.sh -o /path/to/MegaSynth -d 0-9

# 全部
./download_megasynth.sh -d
```

也可以用 Hugging Face CLI：

```bash
hf download hwjiang/MegaSynth --repo-type dataset --include "split_0.zip" --local-dir .
```

单个文件直链：`https://huggingface.co/datasets/hwjiang/MegaSynth/resolve/main/split_<N>.zip`

## 数据结构 (Dataset Overview)

项目页与数据卡没有给出目录说明，以下结构是 2026-11-12 远程读取 `split_0.zip` 文件列表得到的（每个分卷约 7,000 个场景，场景目录名为 UUID）：

```
split_0/
└── <scene-uuid>/
    ├── shape/
    │   └── info_layout.json        # 程序化户型与物体布局
    └── hanwen/
        ├── opencv_cameras.json     # 每帧相机内外参（OpenCV 约定）
        ├── minmax.txt              # 场景范围
        └── renderings/
            ├── 00000000_rgba.png   # RGBA 渲染图
            ├── 00000000_depth.exr  # 深度
            └── ...
```

数据读取与训练代码见 [hwjiang1510/MegaSynth](https://github.com/hwjiang1510/MegaSynth)。

## 许可 (License)

Hugging Face 数据卡标注为 **MIT**（项目网页本身为 CC BY-SA 4.0）。

## 引用

```bibtex
@article{jiang2024megasynth,
  title   = {MegaSynth: Scaling Up 3D Scene Reconstruction with Synthesized Data},
  author  = {Jiang, Hanwen and Xu, Zexiang and Xie, Desai and Chen, Ziwen and Jin, Haian and Luan, Fujun and Shu, Zhixin and Zhang, Kai and Bi, Sai and Sun, Xin and Gu, Jiuxiang and Huang, Qixing and Pavlakos, Georgios and Tan, Hao},
  journal = {arXiv preprint arXiv:2412.14166},
  year    = {2024},
}
```
