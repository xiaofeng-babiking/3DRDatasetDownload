# Hypersim

来源：<https://github.com/apple/ml-hypersim>（抓取于 2026-11-12）

Hypersim 是 Apple 发布的照片级合成室内场景数据集，基于 Evermotion 专业建筑可视化资产，用 V-Ray 渲染。共 461 个室内场景、774 条相机轨迹、77,400 张图像（每条轨迹 100 帧，1024×768；公开版本人工剔除了含人物和显著商标的图像，实际为 74,619 张）。每张图像提供 HDR 颜色、漫反射光照 / 漫反射率 / 非漫反射残差的分解、深度、世界坐标、法线、语义与实例分割，以及场景网格和 3D 包围盒。

## 下载 (Download)

数据集约 **1.9 TB**，按场景切分为 457 个 zip（每个 1–20 GB）。`hypersim_urls.txt` 中的链接取自官方脚本 [`dataset_download_images.py`](https://github.com/apple/ml-hypersim/blob/main/code/python/tools/dataset_download_images.py)，格式为：

```
https://docs-assets.developer.apple.com/ml-research/datasets/hypersim/v1/scenes/ai_VVV_NNN.zip
```

```bash
# 全部场景，下载后解压并删除 zip
./download_hypersim.sh -o /path/to/Hypersim -d

# 只下载 volume 001 的场景
./download_hypersim.sh 'ai_001_*'

# 单个场景
./download_hypersim.sh -x ai_001_001
```

脚本使用 `wget -c` 支持断点续传；场景解压成功后会写入 `scenes/<scene>/.done`，再次运行时直接跳过。

也可以直接用官方脚本（依赖 `curl` 与 `unzip`，没有断点续传）：

```bash
python code/python/tools/dataset_download_images.py \
  --downloads_dir /path/to/downloads --decompress_dir /path/to/scenes
```

> 如果只需要部分模态，可以用 Thomas Germer 贡献的 [contrib/99991 下载脚本](https://github.com/apple/ml-hypersim/tree/main/contrib/99991) 只下载 zip 内的部分文件，无需下载整个场景。

## 数据结构 (Dataset Overview)

```
ai_VVV_NNN/
├── _detail/
│   ├── metadata_cameras.csv         # 该场景的所有相机轨迹
│   ├── metadata_node_strings.csv
│   ├── metadata_nodes.csv
│   ├── metadata_scene.csv           # 含 meters_per_asset_unit
│   ├── cam_XX/                      # 每条轨迹的相机位姿（camera_keyframe_*.hdf5）
│   └── mesh/                        # 网格标注、语义/实例 ID、3D 包围盒
└── images/
    ├── scene_cam_XX_final_hdf5/     # frame.IIII.color.hdf5, diffuse_illumination, diffuse_reflectance, residual
    ├── scene_cam_XX_final_preview/  # 上述的 JPG 预览
    ├── scene_cam_XX_geometry_hdf5/  # frame.IIII.depth_meters, position, normal_cam, normal_world, render_entity_id, semantic, semantic_instance
    └── scene_cam_XX_geometry_preview/
```

⚠️ 注意事项（详见仓库 README；转平面深度的代码见 [issue #9](https://github.com/apple/ml-hypersim/issues/9#issuecomment-754935697)）：

- `depth_meters.hdf5` 存储的是像素到相机光心的**欧氏距离**，不是平面 Z 深度，需按像素射线方向转换。
- 相机位姿与 `position.hdf5` 使用资产单位（asset units），需乘以 `metadata_scene.csv` 中的 `meters_per_asset_unit` 转为米。
- 官方 train / val / test 划分（v1，按场景划分）见 `evermotion_dataset/analysis/metadata_images_split_scene_v1.csv`；被剔除的图像列在 `evermotion_dataset/analysis/metadata_images.csv`。
- 不同场景之间存在少量家具资产复用，即使按场景划分也可能有物体泄漏到验证/测试集。
- 各场景相机内参略有不同（部分场景使用移轴参数），可参考 [`contrib/mikeroberts3000`](https://github.com/apple/ml-hypersim/tree/main/contrib/mikeroberts3000) 中每个场景的投影矩阵。

## 许可 (License)

[Creative Commons Attribution-ShareAlike 3.0 Unported (CC BY-SA 3.0)](https://creativecommons.org/licenses/by-sa/3.0/)

## 引用

```bibtex
@inproceedings{roberts:2021,
  author    = {Mike Roberts AND Jason Ramapuram AND Anurag Ranjan AND Atulit Kumar AND
               Miguel Angel Bautista AND Nathan Paczan AND Russ Webb AND Joshua M. Susskind},
  title     = {{Hypersim}: {A} Photorealistic Synthetic Dataset for Holistic Indoor Scene Understanding},
  booktitle = {International Conference on Computer Vision (ICCV) 2021},
  year      = {2021}
}
```
