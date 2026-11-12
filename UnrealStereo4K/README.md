# UnrealStereo4K

来源：<https://github.com/fabiotosi92/SMD-Nets>（抓取于 2026-11-12）

UnrealStereo4K 是 SMD-Nets（CVPR 2021）论文提出的合成双目数据集，用 Unreal Engine + [UnrealCV](https://unrealcv.org/) 渲染 8 个静态场景（室内与室外），双目图像分辨率 **3840×2160**，提供与左右图都对齐的像素级视差真值和相机位姿。另有第 9 个场景（`00008`，200 对）作为域外测试集。

## 下载 (Download)

```bash
# 全分辨率，全部 9 个场景（约 600 GB）
./download_unrealstereo4k.sh

# 只下载第 0 个场景并解压
./download_unrealstereo4k.sh -o /path/to/UnrealStereo4K -x 0

# 1/4 分辨率版本（960x540，JPG + NPY 视差，Hugging Face）
./download_unrealstereo4k.sh -q -x
```

### 全分辨率（3840×2160，S3）

官方仓库也提供 [`scripts/download_data.sh`](https://github.com/fabiotosi92/SMD-Nets/blob/main/scripts/download_data.sh)。

| 文件 | 大小 |
|---|---:|
| [UnrealStereo4K_00000.zip](https://s3.eu-central-1.amazonaws.com/avg-projects/smd_nets/UnrealStereo4K_00000.zip) | 74 GB |
| [UnrealStereo4K_00001.zip](https://s3.eu-central-1.amazonaws.com/avg-projects/smd_nets/UnrealStereo4K_00001.zip) | 73 GB |
| [UnrealStereo4K_00002.zip](https://s3.eu-central-1.amazonaws.com/avg-projects/smd_nets/UnrealStereo4K_00002.zip) | 74 GB |
| [UnrealStereo4K_00003.zip](https://s3.eu-central-1.amazonaws.com/avg-projects/smd_nets/UnrealStereo4K_00003.zip) | 73 GB |
| [UnrealStereo4K_00004.zip](https://s3.eu-central-1.amazonaws.com/avg-projects/smd_nets/UnrealStereo4K_00004.zip) | 72 GB |
| [UnrealStereo4K_00005.zip](https://s3.eu-central-1.amazonaws.com/avg-projects/smd_nets/UnrealStereo4K_00005.zip) | 74 GB |
| [UnrealStereo4K_00006.zip](https://s3.eu-central-1.amazonaws.com/avg-projects/smd_nets/UnrealStereo4K_00006.zip) | 67 GB |
| [UnrealStereo4K_00007.zip](https://s3.eu-central-1.amazonaws.com/avg-projects/smd_nets/UnrealStereo4K_00007.zip) | 76 GB |
| [UnrealStereo4K_00008.zip](https://s3.eu-central-1.amazonaws.com/avg-projects/smd_nets/UnrealStereo4K_00008.zip) | 16 GB（200 对，域外测试集） |

### 1/4 分辨率（960×540，Hugging Face）

[fabiotosi92/UnrealStereo4K](https://huggingface.co/datasets/fabiotosi92/UnrealStereo4K)：`00000.zip` ~ `00008.zip`，图像为高质量 JPG，视差为按分辨率缩放后的 NPY。

```bash
hf download fabiotosi92/UnrealStereo4K --repo-type dataset --local-dir ./quarter_res
```

## 数据结构 (Dataset Overview)

每个场景解压后：

```
000XX/
├── Image0/       # 左图   00000.png ...  (3840x2160, 8 MPx PNG)
├── Image1/       # 右图
├── Disp0/        # 左视差 00000.npy ...
├── Disp1/        # 右视差
└── Extrinsics/   # 相机位姿
```

> 原始 RGB 为 8 MPx 的 PNG，读取很慢。官方建议离线转成 raw 二进制以加速训练（见仓库 README 的 `convert` 片段，记得同步修改文件名）。训练/测试划分见仓库 `filenames/` 目录。

## 许可 (License)

仓库与数据集页面没有单独声明数据许可；使用前请参考 [SMD-Nets 仓库](https://github.com/fabiotosi92/SMD-Nets) 的 LICENSE 并联系作者。Hugging Face 上的 1/4 分辨率版本标注为 MIT。

## 引用

```bibtex
@inproceedings{tosi2021smd,
  title     = {SMD-Nets: Stereo Mixture Density Networks},
  author    = {Tosi, Fabio and Liao, Yiyi and Schmitt, Carolin and Geiger, Andreas},
  booktitle = {Conference on Computer Vision and Pattern Recognition (CVPR)},
  year      = {2021}
}
```
