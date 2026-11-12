# EDEN

来源：<https://lhoangan.github.io/eden/>（抓取于 2026-11-12）

EDEN（Enclosed garDEN）是一个多模态合成花园场景数据集，包含 100 多个程序化生成的花园模型，共约 30 万张图像。场景中有草地、树篱、灌木、玫瑰、树木等植物，在不同光照与天气下渲染。提供 RGB、语义/实例分割、深度、表面法线、本征图像分解（albedo / shading）、相机位姿和光照信息。主要用于户外深度估计、语义分割和本征分解，也是 3DRMS 挑战赛的数据来源。

## 下载 (Download)

```bash
# 默认：统计/划分 + 相机位姿 + 光照 + RGB + 深度（约 575 GB）
./download_eden.sh

# 先下载小规模样例集（约 38 GB）熟悉数据
./download_eden.sh -s -x all

# 全部模态（约 1.16 TB）
./download_eden.sh -o /path/to/EDEN -x all
```

### 直接链接

| 模态 | 完整集 | 大小 | 样例集 | 大小 |
|---|---|---:|---|---:|
| 统计与划分 | [Stats.zip](https://isis-data.science.uva.nl/hale/EDEN/Stats.zip) | 26 MB | - | - |
| 相机位姿 | [CameraInfo.zip](https://isis-data.science.uva.nl/hale/EDEN/CameraInfo.zip) | 197 MB | - | - |
| 光照信息 | [LightInfo.zip](https://isis-data.science.uva.nl/hale/EDEN/LightInfo.zip) | 131 MB | - | - |
| RGB | [RGB.zip](https://isis-data.science.uva.nl/hale/EDEN/RGB.zip) | 333 GB | [RGB.zip](https://isis-data.science.uva.nl/hale/EDEN-samples/RGB.zip) | 11 GB |
| 分割 | [Segmentation.zip](https://isis-data.science.uva.nl/hale/EDEN/Segmentation.zip) | 13 GB | [Segmentation.zip](https://isis-data.science.uva.nl/hale/EDEN-samples/Segmentation.zip) | 439 MB |
| 深度 | [Depth.zip](https://isis-data.science.uva.nl/hale/EDEN/Depth.zip) | 241 GB | [Depth.zip](https://isis-data.science.uva.nl/hale/EDEN-samples/Depth.zip) | 7.7 GB |
| 表面法线 | [SurfaceNormal.zip](https://isis-data.science.uva.nl/hale/EDEN/SurfaceNormal.zip) | 130 GB | [SurfaceNormal.zip](https://isis-data.science.uva.nl/hale/EDEN-samples/SurfaceNormal.zip) | 4.6 GB |
| 本征分解 | [Intrinsics](https://isis-data.science.uva.nl/hale/EDEN/Intrinsics) | 440 GB | [Intrinsics.zip](https://isis-data.science.uva.nl/hale/EDEN-samples/Intrinsics.zip) | 14 GB |

> 官网完整集的 Intrinsics 链接没有 `.zip` 后缀，脚本会把它保存为 `Intrinsics.zip`。论文摘要提到光流，但官网没有光流的下载链接。

## 数据结构 (Dataset Overview)

- 场景编号为 4 位数字（如 `0001`）。部分场景相对 3DRMS 数据重新渲染并重新编号，**不要混用 EDEN 与 3DRMS 中同一图像的不同模态**。
- 实例分割 `*_Inst.png` 为 32-bit 整数 PNG，编码为 `instance_label = semantic_label * 100 + instance_number`。
- 语义标签采用完整的 TrimBot2020 标签集。3DRMS 挑战赛与论文使用精简的 9 类（0 为 void）：

| 精简标签 | 名称 | 对应完整标签 |
|---:|---|---|
| 0 | void / unknown | 0 |
| 1 | grass | 2 |
| 2 | ground | 1, 3, 4, 5, 6, 7 |
| 3 | pavement | 8 |
| 4 | hedge | 10 |
| 5 | topiary | 20 |
| 6 | rose | 30–35 |
| 7 | obstacle | 100, 103, 104, 105, 106 |
| 8 | tree | 102 |
| 9 | background | 220, 223 |

## 许可 (License)

官网未声明许可协议，使用前请联系作者确认。

## 引用

论文：[WACV 2021](https://openaccess.thecvf.com/content/WACV2021/papers/Le_EDEN_Multimodal_Synthetic_Dataset_of_Enclosed_GarDEN_Scenes_WACV_2021_paper.pdf) | [arXiv 2011.04389](https://arxiv.org/abs/2011.04389)

```bibtex
@inproceedings{le21wacv,
  author    = {Le, Hoang{-}An and Das, Partha and Mensink, Thomas and Karaoglu, Sezer and Gevers, Theo},
  title     = {{EDEN: Multimodal Synthetic Dataset of Enclosed garDEN Scenes}},
  booktitle = {Proceedings of the IEEE/CVF Winter Conference of Applications on Computer Vision (WACV)},
  year      = {2021},
}
```
