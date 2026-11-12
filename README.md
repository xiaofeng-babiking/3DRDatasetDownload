# 3DRDatasetDownload
3D Reconstruction Dataset Download Scripts

本仓库整理三维重建领域（涵盖多视图立体匹配 MVS、稠密 SLAM、室内几何重建及新视角合成 NVS 等）常用数据集的官网、核心参数与下载脚本。数据集按来源分为**合成数据集**与**真实场景数据集**两类；由真实扫描/真实图像重建网格后再重投影渲染的数据集（如 BlendedMVS、Replica、HM3D）归入真实场景数据集，并标注为“半合成”。

> 说明：“—”表示无固定值或暂未整理；带“约”的数字为近似值，具体以各数据集官网/论文为准。

## 合成数据集

| 编号 | 数据集 | 官网地址 | 序列数量 | 序列长度 | 数据模态 |
|:---:| :--- | :--- | :--- | :--- | :--- |
| 1 | **Aria Synthetic Environments (ASE)** | [Project Aria](https://www.projectaria.com/datasets/ase/) | 100,000 个室内场景 | 每场景 1 条轨迹 | 鱼眼 RGB、Depth、Instance Seg、Pose、结构化场景语言 |
| 2 | **BEDLAM** | [MPI](https://bedlam.is.tue.mpg.de/) | 约 1 万段视频 | 共约 38 万帧 | RGB、Depth、Seg、SMPL-X、Pose |
| 3 | **BEHAVIOR-1K** | [Stanford](https://behavior.stanford.edu/) | 50 个场景 (1,000 项活动) | 仿真环境 (无固定帧) | 仿真 RGB、Depth、Seg、Pose、物体资产 |
| 4 | **Dynamic Replica** | [GitHub Pages](https://dynamic-stereo.github.io/) | 524 段视频 | 300 帧 | 双目 RGB、Depth、Flow、Seg、Pose、点轨迹 |
| 5 | **EDEN** | [GitHub Pages](https://lhoangan.github.io/eden/) | 100+ 个花园场景 | 共约 30 万帧 | RGB、Depth、Normal、Seg、Flow、Pose |
| 6 | **Hypersim** | [GitHub](https://github.com/apple/ml-hypersim) | 461 场景 (774 轨迹) | 100 帧 | HDR RGB、Depth、Normal、Seg、光照 |
| 7 | **ICL-NUIM** | [Imperial College](https://www.doc.ic.ac.uk/~ahanda/VaFRIC/iclnuim.html) | 8 条轨迹 (2 个场景) | 882–1,510 帧 | RGB、Depth、Pose、Mesh |
| 8 | **InteriorNet** | [interiornet.org](https://interiornet.org/) | 约 20,000 条轨迹 | 1,000 帧 | RGB、Depth、Normal、IMU、Seg |
| 9 | **MegaSynth** | [GitHub Pages](https://hwjiang1510.github.io/MegaSynth/) | 约 70 万个程序化场景 | — | RGB、Pose |
| 10 | **Mid-Air** | [ULiège](https://midair.ulg.ac.be/) | 54 条无人机轨迹 | 共约 42 万帧 | 多视角 RGB、Depth、Normal、Seg、IMU、GPS |
| 11 | **MVS-Synth** | [GitHub Pages](https://phuang17.github.io/DeepMVS/mvs-synth.html) | 120 个序列 | 100 帧 | RGB、Depth、Pose |
| 12 | **NeRF Synthetic** | [UC Berkeley](https://www.matthewtancik.com/nerf) | 8 个物体场景 | 400 视角 | RGB、Depth、Normal、Pose |
| 13 | **ParallelDomain-4D** | [Columbia](https://gcd.cs.columbia.edu/) | — | — | 多视角 RGB、Depth、Seg、Flow、LiDAR、Pose |
| 14 | **SAIL-VOS (3D)** | [UIUC](https://sailvos.web.illinois.edu/) | 201 段视频 (train+val) | 共 111,654 帧 | RGB、Modal/Amodal Seg、Depth、Mesh、Pose (3D 版) |
| 15 | **SceneNet RGB-D** | [Imperial RobotVault](https://robotvault.bitbucket.io/scenenet-rgbd.html) | 16,865 条轨迹 | 300 帧 | RGB、Depth、Flow、Seg、Pose |
| 16 | **TartanAir** | [The AirLab](https://theairlab.org/tartanair-dataset/) | 1,037 条轨迹 (30 场景) | 500–4,000 帧 | 双目 RGB、Depth、Flow、IMU、LiDAR |
| 17 | **TartanAirV2** | [tartanair.org](https://tartanair.org/) | 70+ 个环境 | — | 多相机 RGB、Depth、Seg、Flow、IMU、LiDAR、Event |
| 18 | **TartanGround** | [tartanair.org](https://tartanair.org/tartanground/) | 60+ 个环境 | — | 多相机 RGB、Depth、Seg、IMU、LiDAR、Pose |
| 19 | **UnrealStereo4K** | [GitHub](https://github.com/fabiotosi92/SMD-Nets) | 8 个场景 | 共约 7,700 对 | 4K 双目 RGB、Disparity |
| 20 | **Virtual KITTI 2** | [Naver Labs](https://europe.naverlabs.com/research/computer-vision/proxy-virtual-worlds-vkitti-2/) | 50 个序列 (5 克隆场景) | 200–800 帧 | 双目 RGB、Depth、Flow、Seg、Pose |
| 21 | **3D-FRONT** | [Tianchi](https://tianchi.aliyun.com/specials/promotion/alibaba-3d-scene-dataset) | 6,813 户型 (18,968 房间) | 静态 3D 资产 (无固定帧) | CAD Mesh、Layout、纹理、语义 |

## 真实场景数据集

| 编号 | 数据集 | 官网地址 | 序列数量 | 序列长度 | 数据模态 |
|:---:| :--- | :--- | :--- | :--- | :--- |
| 1 | **Aria series** (Aria Everyday Activities / Aria Digital Twin / AEO 等) | [Project Aria](https://www.projectaria.com/datasets/) | AEA 143 段、ADT 200+ 段 | 数分钟/段 | RGB、SLAM 灰度、IMU、眼动、音频、Pose、半稠密点云 (ADT 另含 Depth、Seg、物体位姿) |
| 2 | **BlendedMVS** (半合成) | [GitHub](https://github.com/YoYo000/BlendedMVS) | 113 (BlendedMVG 502) | 20–1,000 帧 | RGB、Depth、Pose、Mesh |
| 3 | **Co3Dv2** | [GitHub](https://github.com/facebookresearch/co3d) | 约 3.7 万段视频 (50 类) | 约 100–200 帧 | RGB、Depth (MVS)、Mask、Pose、点云 |
| 4 | **uCO3D** | [GitHub Pages](https://uco3d.github.io/) | 约 17 万段视频 (1,000+ 类) | — | RGB、Mask、Pose、点云、3DGS、文本描述 |
| 5 | **DL3DV** | [GitHub Pages](https://dl3dv-10k.github.io/DL3DV-10K/) | 10,510 段视频 | 数百至数千帧 | 4K RGB、Pose (COLMAP) |
| 6 | **EFM3D** | [GitHub](https://github.com/facebookresearch/efm3d) | — (基于 ASE / ADT / AEO) | — | Aria RGB/SLAM、Pose、3D OBB、Mesh |
| 7 | **HOT3D** | [GitHub Pages](https://facebookresearch.github.io/hot3d/) | 约 3,800 段 | 共约 370 万帧 | 多视角 RGB/灰度、Pose、MANO 手部、物体 6DoF、Mesh |
| 8 | **Habitat (HM3D)** (半合成) | [AI Habitat](https://aihabitat.org/datasets/hm3d/) | 1,000 个室内场景 | 连续网格 (无固定帧) | Textured Mesh、Seg (HM3D-Semantics) |
| 9 | **Map-free** | [Niantic](https://research.nianticlabs.com/mapfree-reloc-benchmark) | 655 个地点 | 数百帧/扫描 | RGB、Depth (估计)、Pose |
| 10 | **Mapillary Metropolis** | [Mapillary](https://www.mapillary.com/dataset/metropolis) | 1 座城市 (费城) | — | 街景 RGB、航拍、LiDAR、Pose、语义 |
| 11 | **MPSD** (Mapillary Planet-Scale Depth) | [Mapillary](https://www.mapillary.com/dataset/depth) | 约 75 万张图像 | 单帧 | RGB、稀疏 Depth (SfM)、Pose |
| 12 | **MegaDepth** | [Cornell](https://www.cs.cornell.edu/projects/megadepth/) | 196 个地标 | 共约 13 万张图像 | RGB、Depth (MVS)、Pose (COLMAP) |
| 13 | **Replica** (半合成) | [GitHub](https://github.com/facebookresearch/Replica-Dataset) | 18 个室内场景 | 连续网格 (常采样 2,000 帧) | HDR Mesh、RGB、Depth、Seg |
| 14 | **ScanNet Series** (ScanNet / ScanNet++) | [ScanNet](http://www.scan-net.org/)；[ScanNet++](https://kaldir.vc.in.tum.de/scannetpp/) | ScanNet 1,513 次扫描；ScanNet++ 1,000+ 场景 | 数千帧/扫描 | RGB-D、Pose、Mesh、Seg (ScanNet++ 另含 DSLR、iPhone、激光扫描) |
| 15 | **Taskonomy** | [Stanford](http://taskonomy.stanford.edu/) | 约 600 栋建筑 | 共约 450 万张图像 | RGB、Depth、Normal、Seg、Edge 等 20+ 任务 |
| 16 | **Waymo Open Dataset** | [Waymo](https://waymo.com/open/) | 2,030 个片段 (Perception) | 约 200 帧 (20 s @ 10 Hz) | 多相机 RGB、LiDAR、3D Box、Pose |
| 17 | **WildRGB-D** | [GitHub Pages](https://wildrgbd.github.io/) | 约 2 万段视频 (46 类) | — | RGB-D (iPhone)、Mask、Pose、点云 |

## 采集机制与合成范式说明

* **半合成重投影范式（BlendedMVS、Replica、HM3D）：** 数据并非由纯人工 3D 建模生成，而是先通过现实多视角图像（Altizure 平台）或高精 RGB-D 红外扫描获取初始稠密 3D 网格，再重投影渲染真值深度图。BlendedMVS 通过高低通滤波将渲染图与真实图像融合以保留真实环境光照；Replica 则经过人工几何修复并赋予 HDR 纹理与真实镜面/玻璃反射属性，并常配合 Habitat 仿真器渲染固定轨迹（如 NICE-SLAM 标准评测集每条轨迹采样 2,000 帧）。
* **纯光线追踪与游戏引擎渲染（ICL-NUIM、SceneNet RGB-D、Hypersim、TartanAir）：** 基于 POV-Ray、NVIDIA OptiX、V-Ray 或 Unreal Engine 4 从零渲染 CAD 模型。ICL-NUIM 提供了人工合成的 Kinect 传感器深度噪声模型；SceneNet RGB-D 引入 Chrono 物理引擎随机抛洒物体以构建杂乱遮挡场景；Hypersim 提供去色调映射（Un-tonemapped）的漫反射与残差光照分解数据；TartanAir 则针对动态雨雪天气与剧烈 6-DoF 运动轨迹进行了专门设计。
* **合成数据局限与使用注意事项：**
  1. **完美位姿与传感器噪声缺失：** 除 ICL-NUIM 与 TartanAir 外，多数合成数据集（如 SceneNet RGB-D、Hypersim）提供无误差的解析深度（Analytical Depth）与绝对准确的相机位姿。在无噪声深度上训练或评估 TSDF 融合及学习型 MVS 算法时，模型极易过拟合完美几何边界，迁移至真实消费级传感器（如 RealSense D435i 的多径干扰、飞行时间伪影及边缘缺失）时性能会出现显著退化。
  2. **尺度与坐标系歧义：** Hypersim 的原始深度图存储的是像素到相机光心的欧氏距离（Euclidean Distance）而非标准平面深度（Planar Z-Depth），且相机坐标采用设计师原始资产单位（Asset Units）而非物理米制，直接用于多视图几何重建时若不经过单位与投影转换会导致严重尺度畸变。
  3. **资产复用导致的泛化虚高：** Hypersim 与 3D-FRONT 在不同房间布局中存在底层 CAD 家具资产跨场景复用的情况，按场景随机划分训练/测试集时仍可能出现几何特征泄漏（Data Leakage）。
