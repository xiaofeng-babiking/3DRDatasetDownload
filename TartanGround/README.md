# TartanGround

来源：<https://tartanair.org/tartanground/>、<https://github.com/castacks/tartanairpy>（抓取于 2026-11-12）

TartanGround 是 CMU AirLab 与 ETH RSL 发布的大规模地面机器人感知与导航数据集，在 TartanAir V2 的 **63 个照片级 Unreal 环境**（室内、自然、乡村、城市、工业/基础设施、历史/主题六类）中，用三种地面机器人运动模型采集了 **878 条轨迹、约 144 万个样本**。每个机器人装有与 TartanAir V2 相同的双目 6 相机 360° 阵列（FoV 90°，640×640），提供 RGB、深度、语义分割、IMU、32 线仿真 LiDAR、真值位姿与元数据（含机器人高度），每个环境还提供全局 RGB / 语义点云，四足机器人另有含关节状态的 ROS bag。

| 机器人 | `--version` | 轨迹编号 | 环境数 |
|---|---|---|---:|
| 全向移动 | `omni` | `P0000`, `P0001`, … | 63 |
| 差速驱动 | `diff` | `P1000`, `P1001`, … | 42 |
| 四足（ANYmal） | `anymal` | `P2000`, `P2001`, … | 12 |

## 下载 (Download)

完整数据约 **16.7 TB**（34,671 个 zip，按 `<env>/Data_<omni|diff|anymal>/<traj>/<modality>_<camera>.zip` 组织，另有每个环境的 `<env>_rgb_pcd.zip`、`<env>_sem_pcd.zip`、`seg_labels.zip`）。

| 文件 | 作用 |
|---|---|
| `download_tartanground.sh` | 入口脚本：按需安装 `requirements.txt`，然后调用 Python 脚本（参数原样传递） |
| `download_tartanground.py` | 下载逻辑：按条件筛选文件列表，多线程下载，可选解压；也可单独运行 |
| `tartanground_files.txt` | 官方文件列表（含每个 zip 的大小），复制自 [tartanairpy](https://github.com/castacks/tartanairpy) 的 `tartanair/download_ground_files.txt`（2026-06-09 版本） |
| `requirements.txt` | Python 依赖：只需要 `huggingface_hub` |

> 没有直接使用官方工具包 `pip install tartanair`：它强制依赖 torch、kornia、opencv 以及只支持 CUDA 的 `cupy-cuda12x`，在 macOS 上无法安装。本脚本只复用官方的文件列表、下载地址和解压方式（每个 zip 解压到其所在目录），结果与官方 `ta.download_ground()` 相同。

```bash
# 查看三种机器人各自可用的环境
./download_tartanground.sh --list

# 每个环境各一条轨迹的前视相机，先 dry run
./download_tartanground.sh --version omni --traj P0000 --camera lcam_front --dry-run

# 两个环境的全向机器人：前/左/右/后相机的 RGB + 深度 + 位姿，并解压
./download_tartanground.sh -o /path/to/TartanGround \
    --env AbandonedFactory Hospital --version omni \
    --modality image depth meta --camera lcam_front lcam_left lcam_right lcam_back --unzip

# 全部环境的语义点云与标签映射（语义占据任务）
./download_tartanground.sh --modality sem_pcd seg_labels --unzip

# 也可以直接运行 Python 脚本
pip install -r requirements.txt
python download_tartanground.py --env Hospital --version omni --modality meta
```

| 参数 | 可选值 | 默认 |
|---|---|---|
| `-o` / `--output-root` | 输出目录 | `/Volumes/Expansion0/3DRDatasets/TartanGround` |
| `--env` | 63 个环境名，如 `AbandonedCable` `ConstructionSite` `Hospital` `Downtown` …（`--list` 查看） | 全部 |
| `--version` | `omni` `diff` `anymal` | 全部 |
| `--traj` | 轨迹编号，如 `P0000` `P1001` | 全部 |
| `--modality` | `image` `meta` `depth` `seg` `lidar` `imu` `rosbag`（仅 anymal）`sem_pcd` `seg_labels` `rgb_pcd` | 全部 |
| `--camera` | `lcam_front` `lcam_right` `lcam_left` `lcam_back` `lcam_top` `lcam_bottom` 及对应的 `rcam_*` | 全部 |
| `--source` | `huggingface`（[theairlabcmu/TartanGround](https://huggingface.co/datasets/theairlabcmu/TartanGround)）/ `airlab`（CMU 服务器） | `huggingface` |
| `--workers` | 并行下载数 | 4 |
| `--unzip` / `--delete-zip` | 下载后解压 / 解压后删除 zip | 关 |
| `--dry-run` | 只列出选中的文件和总大小 | 关 |

`--version`、`--traj`、`--camera` 只作用于带这些属性的文件；每个环境级别的点云 / 标签文件只受 `--env`、`--modality` 筛选。断点续传、跳过已完成文件和 `PYTHON` 环境变量的行为与 [TartanAir V2](../TartanAirV2/) 相同。

各环境的轨迹数、长度等元数据见官方 [Google Sheet](https://docs.google.com/spreadsheets/d/1d_px4Ss19OmrJrdOLwPsVNYe7Blcdmr6JKs0GdOORCg/edit?usp=sharing)。

## 数据结构 (Dataset Overview)

```
TartanGround_Root/
├── AbandonedCable/
│   ├── AbandonedCable_rgb.pcd      # 全局 RGB 点云
│   ├── AbandonedCable_sem.pcd      # 全局语义点云
│   ├── seg_label_map.json          # 语义标签映射
│   ├── Data_omni/                  # 全向机器人
│   │   ├── P0000/
│   │   │   ├── image_lcam_front/
│   │   │   ├── depth_lcam_front/
│   │   │   ├── seg_lcam_front/
│   │   │   ├── imu/
│   │   │   ├── lidar/
│   │   │   ├── pose_lcam_front.txt
│   │   │   ├── P0000_metadata.json
│   │   │   └── ...
│   │   └── P00XX/
│   ├── Data_diff/                  # 差速机器人 P1000 ...
│   └── Data_anymal/                # 四足机器人 P2000 ...
└── ...
```

相机内参、深度 PNG 解码方式与 [TartanAir V2](../TartanAirV2/) 相同。

## 许可 (License)

数据集：[Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)；工具包：MIT。

## 引用

```bibtex
@article{patel2025tartanground,
  title   = {TartanGround: A Large-Scale Dataset for Ground Robot Perception and Navigation},
  author  = {Patel, Manthan and Yang, Fan and Qiu, Yuheng and Cadena, Cesar and Scherer, Sebastian and Hutter, Marco and Wang, Wenshan},
  journal = {arXiv preprint arXiv:2505.10696},
  year    = {2025}
}
```
