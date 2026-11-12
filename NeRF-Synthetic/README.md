# NeRF Synthetic (Blender)

来源：<https://www.matthewtancik.com/nerf>、<https://github.com/bmild/nerf>（抓取于 2026-11-12）

NeRF Synthetic（又称 Blender 数据集）是 NeRF（ECCV 2020）论文使用的合成物体数据集：8 个 Blender 模型（chair、drums、ficus、hotdog、lego、materials、mic、ship），在上半球上随机采样视角，用 Cycles 路径追踪渲染，分辨率 800×800，带透明背景（RGBA）。每个场景有 100 张训练、100 张验证、200 张测试图像，测试集额外提供深度和法线。它是新视角合成（NeRF / 3DGS）最常用的基准之一。

## 下载 (Download)

```bash
# 默认：从 Hugging Face 镜像按场景下载（8 个 zip，共约 1.28 GB），并解压
./download_nerf_synthetic.sh -x

# 只要 lego 和 ship
./download_nerf_synthetic.sh -x lego ship

# 官方 Google Drive 的 nerf_synthetic.zip（需要 pip install gdown）
./download_nerf_synthetic.sh -s gdrive -x
```

### 方式一：官方 Google Drive

作者的数据文件夹：<https://drive.google.com/drive/folders/1cK3UDIJqKAAm7zyrxRYVFJ0BRMgrwhh4>（包含 `nerf_synthetic.zip`、`nerf_llff_data.zip` 等）。`nerf_synthetic.zip` 的文件 ID 为 `18JxhpWD-4ZmuFKLzKlAw-w5PpzZxXOcG`（nerfstudio 的 `ns-download-data blender` 也用这个 ID）：

```bash
pip install gdown
gdown 18JxhpWD-4ZmuFKLzKlAw-w5PpzZxXOcG -O nerf_synthetic.zip
```

> Google Drive 对大文件有下载配额限制，直接 `curl`/`wget` 会拿到确认页面（2026-11-12 测试返回 404/HTML），因此需要 gdown 或浏览器下载。

### 方式二：Hugging Face 镜像（默认）

[nerfbaselines/nerfbaselines-data](https://huggingface.co/datasets/nerfbaselines/nerfbaselines-data/tree/main/blender) 的 `blender/` 目录按场景存放原始数据（附原始 README），无需登录，支持断点续传：

| 场景 | 大小 | 链接 |
|---|---:|---|
| chair | 130 MB | <https://huggingface.co/datasets/nerfbaselines/nerfbaselines-data/resolve/main/blender/chair.zip> |
| drums | 152 MB | <https://huggingface.co/datasets/nerfbaselines/nerfbaselines-data/resolve/main/blender/drums.zip> |
| ficus | 134 MB | <https://huggingface.co/datasets/nerfbaselines/nerfbaselines-data/resolve/main/blender/ficus.zip> |
| hotdog | 158 MB | <https://huggingface.co/datasets/nerfbaselines/nerfbaselines-data/resolve/main/blender/hotdog.zip> |
| lego | 180 MB | <https://huggingface.co/datasets/nerfbaselines/nerfbaselines-data/resolve/main/blender/lego.zip> |
| materials | 144 MB | <https://huggingface.co/datasets/nerfbaselines/nerfbaselines-data/resolve/main/blender/materials.zip> |
| mic | 100 MB | <https://huggingface.co/datasets/nerfbaselines/nerfbaselines-data/resolve/main/blender/mic.zip> |
| ship | 285 MB | <https://huggingface.co/datasets/nerfbaselines/nerfbaselines-data/resolve/main/blender/ship.zip> |

## 数据结构 (Dataset Overview)

```
nerf_synthetic/
└── SCENE_NAME/
    ├── train/   r_*.png                      # 100 张，800x800 RGBA
    ├── val/     r_*.png                      # 100 张
    ├── test/    r_*.png                      # 200 张
    │            r_*_depth_0000.png
    │            r_*_normal_0000.png
    ├── transforms_train.json
    ├── transforms_val.json
    └── transforms_test.json
```

`transforms_*.json`：`camera_angle_x` 为水平视场角（焦距 = 0.5 · W / tan(0.5 · camera_angle_x)），`frames` 中每项的 `transform_matrix` 为 4×4 相机→世界矩阵（OpenGL / Blender 约定：相机朝 -Z，Y 朝上）。

## 许可 (License)

官网未声明整体许可。渲染所用 Blender 模型来自 blendswap.com，各自许可如下：

| 场景 | 作者 | 许可 |
|---|---|---|
| chair | 1DInc | CC-0 |
| drums | bryanajones | CC-BY |
| ficus | Herberhold | CC-0 |
| hotdog | erickfree | CC-0 |
| lego | Heinzelnisse | CC-BY-NC |
| materials | elbrujodelatribu | CC-0 |
| mic | up3d.de | CC-0 |
| ship | gregzaal | CC-BY-SA |

## 引用

```bibtex
@inproceedings{mildenhall2020nerf,
  title     = {NeRF: Representing Scenes as Neural Radiance Fields for View Synthesis},
  author    = {Ben Mildenhall and Pratul P. Srinivasan and Matthew Tancik and Jonathan T. Barron and Ravi Ramamoorthi and Ren Ng},
  year      = {2020},
  booktitle = {ECCV},
}
```
