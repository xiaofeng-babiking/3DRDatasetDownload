# MVS-Synth

来源：<https://phuang17.github.io/DeepMVS/mvs-synth.html>（抓取于 2026-11-12）

MVS-Synth 是 DeepMVS（CVPR 2018）论文发布的照片级合成多视图立体数据集，从 GTA-V 中采集城市场景，共 120 个序列，每个序列 100 帧，提供 RGB、深度和相机参数，用于训练学习型 MVS 网络。

## 下载 (Download)

数据托管在 Hugging Face：[phuang17/MVS-Synth](https://huggingface.co/datasets/phuang17/MVS-Synth)，无需登录。

```bash
# 默认：1920x1080
./download_mvs_synth.sh

# 960x540 并解压
./download_mvs_synth.sh -o /path/to/MVS-Synth -x 540
```

| 分辨率 | 大小 | 链接 |
|---|---:|---|
| 1920×1080 | 34 GB | <https://huggingface.co/datasets/phuang17/MVS-Synth/resolve/main/GTAV_1080.tar.gz> |
| 1280×720 | 16 GB | <https://huggingface.co/datasets/phuang17/MVS-Synth/resolve/main/GTAV_720.tar.gz> |
| 960×540 | 9 GB（实际 10.49 GB） | <https://huggingface.co/datasets/phuang17/MVS-Synth/resolve/main/GTAV_540.tar.gz> |

`download_mvs_synth.sh` 使用 Hugging Face CLI（`pip install -U huggingface_hub`）下载，可断点续传：

```bash
./download_mvs_synth.sh            # 默认 1080
./download_mvs_synth.sh -x 540 720 # 下载并解压
# 等价于：
hf download phuang17/MVS-Synth GTAV_1080.tar.gz --repo-type dataset --local-dir .
```

## 数据结构 (Dataset Overview)

```
GTAV_1080/
├── num_images.json
├── 0000/
│   ├── images/   # 0000.png ... 0099.png
│   ├── depths/   # 0000.exr ... 0099.exr
│   └── poses/    # 0000.json ... 0099.json
├── 0001/
└── ... 0119/
```

- **深度**：EXR，半精度浮点。视差为 0 的像素（如天空）存为 `inf`，没有无效深度。取倒数即得视差。
- **相机参数**（JSON）：`extrinsic` 为 4×4 世界→相机矩阵；`c_x`、`c_y` 为主点；`f_x`、`f_y` 为焦距。
- ⚠️ 外参旋转矩阵的行列式为 **-1** 而非 1（坐标系存在镜像），使用前需要处理。

## 许可 (License)

官网说明：数据仅供研究和教育用途（"for research and educational use only"），未给出正式许可协议。

## 引用

```bibtex
@inproceedings{DeepMVS,
  author    = {Huang, Po-Han and Matzen, Kevin and Kopf, Johannes and Ahuja, Narendra and Huang, Jia-Bin},
  title     = {DeepMVS: Learning Multi-View Stereopsis},
  booktitle = {IEEE Conference on Computer Vision and Pattern Recognition (CVPR)},
  year      = {2018}
}
```
