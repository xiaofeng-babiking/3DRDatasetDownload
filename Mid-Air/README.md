# Mid-Air

来源：<https://midair.ulg.ac.be/>、<https://midair.ulg.ac.be/download.html>、<https://midair.ulg.ac.be/data_organization.html>（抓取于 2026-11-12）

Mid-Air 是列日大学（ULiège）发布的低空无人机多模态合成数据集，用 Unreal Engine + AirSim 渲染，共 54 条飞行轨迹、约 42 万帧，覆盖两个大型户外环境：

- **Kite**（城市 / 乡村）：轨迹 `0000`–`0029`，天气为 sunny / sunset / foggy / cloudy；
- **PLE**（森林）：轨迹 `4000`–`4023`，季节为 fall / spring / winter。

每帧提供 3 个相机（左右双目 + 下视）的 RGB，以及深度、表面法线、语义分割、双目视差和双目遮挡图；同时记录 IMU、GPS 和真值位姿。另提供三个基准测试集：视觉建图的天气鲁棒性、季节鲁棒性，以及定位的天气鲁棒性。

## 下载 (Download)

官网没有固定的直接链接，数据被切成大量 zip 分卷，需要在 [下载页面](https://midair.ulg.ac.be/download.html) 填表生成链接列表：

1. 选择视觉传感器（color left/right/down、depth、normals、segmentation、stereo disparity/occlusion）。
2. 选择轨迹与天气 / 季节组合（只要某个天气下选了至少一条轨迹，就会下载该天气完整的 `sensor_records.hdf5`）。
3. 选择需要的基准测试集。
4. 提交表单，得到 `download_config.txt`（页面直接生成或通过邮件发送）。

然后：

```bash
# 下载并解压
./download_midair.sh -c ~/Downloads/download_config.txt -o /path/to/Mid-Air -x

# 解压后删除 zip
./download_midair.sh -c ~/Downloads/download_config.txt -d
```

脚本执行的是官方命令（另外加了 `-c` 以支持断点续传）：

```bash
wget --content-disposition -x -nH -i path_to/download_config.txt
find . -name "*.zip" | while read filename; do unzip -o -d $(dirname "$filename") "$filename"; done;
```

> `-x -nH` 会保留服务器上的目录结构，压缩包里的相对路径必须与 `sensor_records.hdf5` 中记录的路径一致，**不要**移动解压后的文件。hdf5 文件已于 2019-09-06 修补过，请使用新版本。

## 数据结构 (Dataset Overview)

每个天气 / 季节组合（climate setup）下：

```
<climate setup>/
├── color_left/         trajectory_i/j.jpg
├── color_right/        trajectory_i/j.jpg
├── color_down/         trajectory_i/j.jpg
├── depth/              trajectory_i/j.png
├── normals/            trajectory_i/j.png
├── segmentation/       trajectory_i/j.png
├── stereo_disparity/   trajectory_i/j.png
├── stereo_occlusion/   trajectory_i/j.png
└── sensor_records.hdf5 # 所有轨迹的传感器记录与图像路径
```

- 采样频率：视觉传感器 25 Hz，GPS 1 Hz，真值位姿与 IMU 100 Hz。
- 彩色图像为 JPEG，其余视觉模态为 PNG（深度等的编码方式见官网 Data organization 页面）。
- `sensor_records.hdf5` 中的 `trajectory_XXXX` 组包含 `camera_data`（图像相对路径）、`groundtruth`（位置、姿态、速度等）、`imu`、`gps`。

## 许可 (License)

[Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)](https://creativecommons.org/licenses/by-nc-sa/4.0/)，需按作者指定方式署名。

## 引用

```bibtex
@inproceedings{Fonder2019MidAir,
  author    = {Fonder, Michael and Van Droogenbroeck, Marc},
  title     = {Mid-Air: A multi-modal dataset for extremely low altitude drone flights},
  booktitle = {Conference on Computer Vision and Pattern Recognition Workshop (CVPRW)},
  year      = {2019},
  month     = {June}
}
```
