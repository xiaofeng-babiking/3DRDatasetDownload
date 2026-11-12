# Virtual KITTI 2

来源：<https://europe.naverlabs.com/research/computer-vision/proxy-virtual-worlds-vkitti-2/>（抓取于 2026-11-12）

Virtual KITTI 2 是用 Unity 引擎重建 KITTI 跟踪基准中 5 个序列（"克隆"）得到的合成驾驶数据集，相比第一版提升了真实感，并新增双目相机。每个场景有 10 种变体：相机旋转 ±15°/±30°、clone，以及 fog / morning / overcast / rain / sunset 等天气与光照。提供 RGB、深度、类别/实例分割、前后向光流、前后向场景流、相机内外参、2D/3D 检测框与 MOT 真值。

| 场景 | Scene01 | Scene02 | Scene06 | Scene18 | Scene20 |
|---|---:|---:|---:|---:|---:|
| 帧数（每个变体、每个相机） | 447 | 233 | 270 | 339 | 837 |

## 下载 (Download)

```bash
# 默认：RGB + 深度 + 文本真值（约 14.6 GB）
./download_vkitti2.sh

# 全部模态，校验 MD5 并解压（约 102 GB）
./download_vkitti2.sh -o /path/to/VirtualKITTI2 -c -x all

# 只下载光流
./download_vkitti2.sh forwardFlow backwardFlow
```

### 直接链接

MD5 校验：<https://download.europe.naverlabs.com/virtual_kitti_2.0.3/vkitti_2.0.3_md5_checksums.txt>

| 数据 | 大小 | 链接 |
|---|---:|---|
| RGB | 7.01 GB | <https://download.europe.naverlabs.com/virtual_kitti_2.0.3/vkitti_2.0.3_rgb.tar> |
| Depth | 7.58 GB | <https://download.europe.naverlabs.com/virtual_kitti_2.0.3/vkitti_2.0.3_depth.tar> |
| Class Segmentation | 969 MB | <https://download.europe.naverlabs.com/virtual_kitti_2.0.3/vkitti_2.0.3_classSegmentation.tar> |
| Instance Segmentation | 166 MB | <https://download.europe.naverlabs.com/virtual_kitti_2.0.3/vkitti_2.0.3_instanceSegmentation.tar> |
| Forward Optical Flow | 29.6 GB | <https://download.europe.naverlabs.com/virtual_kitti_2.0.3/vkitti_2.0.3_forwardFlow.tar> |
| Backward Optical Flow | 27.1 GB | <https://download.europe.naverlabs.com/virtual_kitti_2.0.3/vkitti_2.0.3_backwardFlow.tar> |
| Forward Scene Flow | 14.8 GB | <https://download.europe.naverlabs.com/virtual_kitti_2.0.3/vkitti_2.0.3_forwardSceneFlow.tar> |
| Backward Scene Flow | 14.8 GB | <https://download.europe.naverlabs.com/virtual_kitti_2.0.3/vkitti_2.0.3_backwardSceneFlow.tar> |
| 相机参数、2D/3D 检测框、MOT 真值 | 23.3 MB | <https://download.europe.naverlabs.com/virtual_kitti_2.0.3/vkitti_2.0.3_textgt.tar.gz> |

## 数据结构 (Dataset Overview)

`X ∈ {01, 02, 06, 18, 20}` 为场景编号，`Y` 为变体（`15-deg-left`、`15-deg-right`、`30-deg-left`、`30-deg-right`、`clone`、`fog`、`morning`、`overcast`、`rain`、`sunset`），`Z ∈ {0, 1}` 为左/右相机，帧号从 0 开始。所有 tar 包解压到同一棵目录树：

```
SceneX/Y/frames/rgb/Camera_Z/rgb_%05d.jpg
SceneX/Y/frames/depth/Camera_Z/depth_%05d.png
SceneX/Y/frames/classsegmentation/Camera_Z/classgt_%05d.png
SceneX/Y/frames/instancesegmentation/Camera_Z/instancegt_%05d.png
SceneX/Y/frames/forwardFlow/Camera_Z/flow_%05d.png
SceneX/Y/frames/backwardFlow/Camera_Z/backwardFlow_%05d.png
SceneX/Y/frames/forwardSceneFlow/Camera_Z/sceneFlow_%05d.png
SceneX/Y/frames/backwardSceneFlow/Camera_Z/backwardSceneFlow_%05d.png
SceneX/Y/colors.txt
SceneX/Y/extrinsic.txt
SceneX/Y/intrinsic.txt
SceneX/Y/info.txt
SceneX/Y/bbox.txt
SceneX/Y/pose.txt
```

- 深度：16-bit PNG，单位厘米，最大 655.35 m（天空等远处被截断）。
- 光流：16-bit 3 通道 PNG，编码方式与 KITTI 相同（详见官网说明）。
- 双目基线 0.532725 m；图像分辨率 1242×375。

## 许可 (License)

仅限**非商业用途**，遵循 [CC BY-NC-SA 3.0](https://creativecommons.org/licenses/by-nc-sa/3.0/legalcode)，版权归 Naver Corporation 所有。

## 引用

```bibtex
@misc{cabon2020vkitti2,
  title         = {Virtual KITTI 2},
  author        = {Cabon, Yohann and Murray, Naila and Humenberger, Martin},
  year          = {2020},
  eprint        = {2001.10773},
  archivePrefix = {arXiv},
  primaryClass  = {cs.CV}
}

@inproceedings{gaidon2016virtual,
  title     = {Virtual worlds as proxy for multi-object tracking analysis},
  author    = {Gaidon, Adrien and Wang, Qiao and Cabon, Yohann and Vig, Eleonora},
  booktitle = {Proceedings of the IEEE conference on Computer Vision and Pattern Recognition},
  pages     = {4340--4349},
  year      = {2016}
}
```
