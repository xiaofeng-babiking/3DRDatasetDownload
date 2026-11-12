# ICL-NUIM

来源：<https://www.doc.ic.ac.uk/~ahanda/VaFRIC/iclnuim.html>（抓取于 2026-11-12）

ICL-NUIM 是用 POV-Ray 光线追踪渲染的室内 RGB-D 基准数据集，用于评测视觉里程计、三维重建和 SLAM。共 2 个场景（living room / office room），每个场景 4 条手持相机轨迹（kt0–kt3），每条 882–1,510 帧，分辨率 640×480。提供无噪声与模拟 Kinect 噪声两种深度。living room 场景还提供三维表面真值，可用于评测重建精度。

| 场景 | 轨迹 | 帧数 |
|---|---|---:|
| living room | kt0 / kt1 / kt2 / kt3 | 1510 / 967 / 882 / 1242 |
| office room | kt0 / kt1 / kt2 / kt3 | 1510 / 967 / 882 / 1242 |

## 下载 (Download)

```bash
# 默认：TUM 格式 PNG（无噪声）+ 位姿真值
./download_icl_nuim.sh

# 全部格式，并自动解压
./download_icl_nuim.sh -o /path/to/ICL-NUIM -x all

# 只要带噪声的 TUM 格式
./download_icl_nuim.sh tum_noise gt
```

| 参数 | 内容 |
|---|---|
| `tum` | TUM RGB-D 兼容 PNG（`rgb/`、`depth/`、`associations.txt`），无噪声 |
| `tum_noise` | TUM RGB-D 兼容 PNG，带模拟 Kinect 深度噪声 |
| `icl` | 原始 ICL-NUIM PNG（`scene_00_XXXX.png` + `.depth` + 每帧相机参数 `.txt`） |
| `gt` | 位姿真值：`livingRoomN.gt.freiburg` / `trajN.gt.freiburg`（TUM 格式），`livingRoomNn.gt.sim`（全局 [R\|t]） |

### 直接链接

所有压缩包位于 `http://www.doc.ic.ac.uk/~ahanda/` 下（N = 0..3）：

| 场景 | TUM 格式 | TUM 格式（含噪声） | 原始 ICL 格式 | 位姿真值 |
|---|---|---|---|---|
| living room | `living_room_trajN_frei_png.tar.gz` | `living_room_trajNn_frei_png.tar.gz` | `living_room_trajN_loop.tgz` | `VaFRIC/livingRoomN.gt.freiburg`、`VaFRIC/livingRoomNn.gt.sim` |
| office room | `trajN_frei_png.tar.gz` | `trajNn_frei_png.tar.gz` | `office_room_trajN_loop.tgz` | `VaFRIC/trajN.gt.freiburg` |

例如：<http://www.doc.ic.ac.uk/~ahanda/living_room_traj0_frei_png.tar.gz>（约 711 MB，2026-11-12 测试可访问）。

> 注意：官网页面上的位姿真值是相对链接，实际路径在 `~ahanda/VaFRIC/` 下（`~ahanda/livingRoom0.gt.freiburg` 返回 404）。living room 的三维表面真值网格页面上没有直接下载链接，可配合 [SurfReg](https://github.com/mp3guy/SurfReg) 工具评测。

## 数据结构 (Dataset Overview)

TUM 格式解压后（以 `living_room_traj0_frei_png` 为例）：

```
living_room/
├── living_room_traj0_frei_png.tar.gz
├── living_room_traj0_frei_png/
│   ├── rgb/            # 0.png, 1.png, ...  (640x480, 8-bit RGB)
│   ├── depth/          # 0.png, 1.png, ...  (16-bit PNG, 深度 = 值 / 5000 米)
│   └── associations.txt
├── livingRoom0.gt.freiburg   # timestamp tx ty tz qx qy qz qw
└── livingRoom0n.gt.sim
```

相机内参：fx = 481.20, fy = -480.00, cx = 319.50, cy = 239.50（注意 fy 为负，即 y 轴朝下的右手系翻转）。

## 许可 (License)

[Creative Commons Attribution 3.0 (CC BY 3.0)](http://creativecommons.org/licenses/by/3.0/)

## 引用

```bibtex
@InProceedings{handa:etal:ICRA2014,
  author    = {A. Handa and T. Whelan and J.B. McDonald and A.J. Davison},
  title     = {A Benchmark for {RGB-D} Visual Odometry, {3D} Reconstruction and {SLAM}},
  booktitle = {IEEE Intl. Conf. on Robotics and Automation, ICRA},
  address   = {Hong Kong, China},
  month     = {May},
  year      = {2014}
}
```
