# TartanAir V2

来源：<https://tartanair.org/>、<https://github.com/castacks/tartanairpy>（抓取于 2026-11-12）

TartanAir V2 是 CMU AirLab 推出的新一代合成 SLAM / 多模态感知数据集，用 Unreal Engine 采集 **74 个环境**，每个环境有 easy / hard 两种运动难度。每个时间步有 12 个同步针孔相机（左右两组，每组 6 个方向覆盖 360°，FoV 90°，640×640，基线 0.25 m，10 Hz），提供 RGB、深度、语义分割、相机位姿，并由此生成光流、鱼眼 / 全景图、LiDAR、带噪声模型的 IMU、事件相机（1000 Hz）和占据栅格地图。官方工具包还支持自定义相机模型重新采样。

## 下载 (Download)

完整数据约 **57 TB**（7,766 个 zip，按 `<env>/Data_<easy|hard>/<modality>_<camera>.zip` 组织），**请只下载需要的部分**。脚本封装了官方工具包 [tartanairpy](https://github.com/castacks/tartanairpy)：

```bash
pip install tartanair

# 查看可选的环境 / 难度 / 模态 / 相机名
python download_tartanair_v2.py --list

# 两个环境、easy 难度、左前相机的 RGB + 深度，并解压
python download_tartanair_v2.py -o /path/to/TartanAirV2 \
    --env ArchVizTinyHouseDay Prison --difficulty easy \
    --modality image depth --camera lcam_front --unzip

# 某个环境的全部数据，从 CMU AirLab 服务器下载
python download_tartanair_v2.py --env Prison --source airlab --unzip
```

| 参数 | 可选值 | 默认 |
|---|---|---|
| `--env` | 74 个环境名，如 `AbandonedCable` `Prison` `Office` `Ruins` …（`--list` 查看） | 全部 |
| `--difficulty` | `easy` `hard` | 两者 |
| `--modality` | `image` `depth` `seg` `imu` `lidar` `flow` `events` `mp4` | 全部 |
| `--camera` | `lcam_front` `lcam_left` `lcam_right` `lcam_back` `lcam_top` `lcam_bottom` `lcam_fish` `lcam_equirect`，以及对应的 `rcam_*` | 全部 |
| `--source` | `huggingface`（[theairlabcmu/tartanair2](https://huggingface.co/datasets/theairlabcmu/tartanair2)）/ `airlab`（CMU 服务器） | `huggingface` |
| `--workers` | 并行下载线程数 | 4 |
| `--unzip` / `--delete-zip` | 下载后解压 / 解压后删除 zip | 关 |

`imu`、`lidar` 等模态不需要指定相机。也可以直接写 Python：

```python
import tartanair as ta
ta.init('/path/to/TartanAirV2')
ta.download(env=['Prison'], difficulty=['easy'], modality=['image', 'depth'],
            camera_name=['lcam_front'], unzip=True, num_workers=4)
# 或者用 yaml 配置：ta.download(config='download_config.yaml')
```

各 zip 的大小见工具包内的 `tartanair/download_files.txt`。

## 数据结构 (Dataset Overview)

```
TartanAirV2_Root/
├── AbandonedCable/
│   ├── Data_easy/
│   │   ├── P000/
│   │   │   ├── image_lcam_front/   # 000000_lcam_front.png ...      (640x640 RGB PNG)
│   │   │   ├── depth_lcam_front/   # 000000_lcam_front_depth.png ... (float32 编码为 4 通道 PNG)
│   │   │   ├── seg_lcam_front/
│   │   │   ├── imu/
│   │   │   ├── lidar/
│   │   │   ├── pose_lcam_front.txt
│   │   │   └── ...
│   │   └── P001 ...
│   └── Data_hard/
└── ...
```

- 相机内参：640×640，f = 320，主点 (320, 320)，无畸变。
- 深度 PNG 是把 `float32` 深度无损打包成 H×W×4 的 8-bit PNG，解码：`cv2.imread(p, cv2.IMREAD_UNCHANGED).view('<f4').squeeze(-1)`。
- 详细模态说明见 [Modalities](https://tartanair.org/modalities.html)，数据加载、迭代器、自定义相机重采样等见 [Examples](https://tartanair.org/examples.html)。

## 许可 (License)

数据集：[Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/)；工具包：MIT。

## 引用

官网未单独给出 V2 的 BibTeX，可引用 TartanAir 原始论文：

```bibtex
@inproceedings{tartanair2020iros,
  title     = {TartanAir: A Dataset to Push the Limits of Visual SLAM},
  author    = {Wang, Wenshan and Zhu, Delong and Wang, Xiangwei and Hu, Yaoyu and Qiu, Yuheng and Wang, Chen and Hu, Yafei and Kapoor, Ashish and Scherer, Sebastian},
  booktitle = {2020 IEEE/RSJ International Conference on Intelligent Robots and Systems (IROS)},
  year      = {2020}
}
```
