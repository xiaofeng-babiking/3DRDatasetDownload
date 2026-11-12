# TartanAir

来源：<https://theairlab.org/tartanair-dataset/>、<https://github.com/castacks/tartanair_tools>（抓取于 2026-11-12）

TartanAir 是 CMU AirLab 用 Unreal Engine + AirSim 采集的大规模合成 SLAM 数据集，覆盖城市、乡村、自然、室内、科幻等多种环境，包含动态物体、光照变化、雨雪雾天气，以及剧烈的 6-DoF 相机运动。按运动难度分为 Easy / Hard 两级，共 1,037 条轨迹（每条 500–4,000 帧，640×480），提供双目 RGB、深度、语义分割、光流（含遮挡掩码）、相机位姿，可额外生成 IMU 与 LiDAR。TartanVO 等学习型视觉里程计都在该数据集上训练。新版请见 [TartanAirV2](../TartanAirV2/)。

## 下载 (Download)

完整数据约 **1.1 TB**（288 个 zip，18 个环境目录 × Easy/Hard × 8 种文件）。`download_training_zipfiles.txt` 复制自官方仓库，脚本按关键字筛选后用 `wget -c` 从 AirLab 服务器下载（支持断点续传），也可以改从 Hugging Face 镜像下载。

```bash
# 先看看会下载哪些文件、共多大
./download_tartanair.sh -n image left

# 所有左目 RGB 图像并解压
./download_tartanair.sh -o /path/to/TartanAir -x image left

# 困难级别的深度（左右目）
./download_tartanair.sh depth hard

# 指定环境的全部数据，从 Hugging Face 下载
./download_tartanair.sh -s hf office abandonedfactory

# 全部数据
./download_tartanair.sh -x
```

筛选关键字（不同组之间取交集，同组内取并集）：

| 组 | 取值 |
|---|---|
| 模态 | `image` `depth` `seg` `flow`（= `flow_flow` + `flow_mask`） |
| 相机 | `left` `right`（光流只有左目） |
| 难度 | `easy` `hard` |
| 环境 | `abandonedfactory` `abandonedfactory_night` `amusement` `carwelding` `endofworld` `gascola` `hospital` `japanesealley` `neighborhood` `ocean` `office` `office2` `oldtown` `seasidetown` `seasonsforest` `seasonsforest_winter` `soulcity` `westerndesert` |

### 数据源

| 来源 | 地址 |
|---|---|
| AirLab 服务器（默认） | `https://airlab-cloud.andrew.cmu.edu:8080/swift/v1/AUTH_ac8533a83cff4d48bc8c608ad222d330/tartanair/<env>/<Easy\|Hard>/<file>.zip`（匿名可读，支持 Range） |
| Hugging Face | [theairlabcmu/tartanair](https://huggingface.co/datasets/theairlabcmu/tartanair) |

也可以用官方脚本：

```bash
git clone https://github.com/castacks/tartanair_tools && cd tartanair_tools
pip install boto3 colorama
python download_training.py --output-dir OUTPUTDIR --rgb --only-left --unzip
# 加 --huggingface 改从 Hugging Face 下载
```

## 数据结构 (Dataset Overview)

```
ROOT
├── ENV_NAME_0                      # 环境
│   ├── Easy                        # 难度
│   │   ├── P000                    # 轨迹
│   │   │   ├── depth_left/         # 000000_left_depth.npy ...
│   │   │   ├── depth_right/        # 000000_right_depth.npy ...
│   │   │   ├── flow/               # 000000_000001_flow.npy / _mask.npy ...
│   │   │   ├── image_left/         # 000000_left.png ...
│   │   │   ├── image_right/        # 000000_right.png ...
│   │   │   ├── seg_left/           # 000000_left_seg.npy ...
│   │   │   ├── seg_right/          # 000000_right_seg.npy ...
│   │   │   ├── pose_left.txt
│   │   │   └── pose_right.txt
│   │   └── P001 ...
│   └── Hard
└── ENV_NAME_1 ...
```

- 相机内参：fx = fy = 320.0，cx = 320.0，cy = 240.0，640×480；双目基线 0.25 m。
- 位姿文件每行 `tx ty tz qx qy qz qw`，坐标系为 NED（x 前、y 右、z 下），相机→世界。
- 深度为 `float32` 米制 `.npy`；光流为 `float32` 像素位移，掩码标记遮挡/越界像素。
- 详细说明见官方 [data_type.md](https://github.com/castacks/tartanair_tools/blob/master/data_type.md)。

## 许可 (License)

[Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)

## 引用

```bibtex
@inproceedings{tartanair2020iros,
  title     = {TartanAir: A Dataset to Push the Limits of Visual SLAM},
  author    = {Wang, Wenshan and Zhu, Delong and Wang, Xiangwei and Hu, Yaoyu and Qiu, Yuheng and Wang, Chen and Hu, Yafei and Kapoor, Ashish and Scherer, Sebastian},
  booktitle = {2020 IEEE/RSJ International Conference on Intelligent Robots and Systems (IROS)},
  year      = {2020}
}
```
