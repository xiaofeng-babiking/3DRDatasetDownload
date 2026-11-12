# SAIL-VOS

来源：<https://sailvos.web.illinois.edu/_site/index.html#download_dataset>、<https://sailvos.web.illinois.edu/_site/dataset_readme.html>（抓取于 2026-11-12）

SAIL-VOS（Semantic Amodal Instance Level Video Object Segmentation）是一个从 GTA-V 中提取的合成视频数据集，提供 RGB 帧、可见（modal）实例分割和非可见（amodal）实例分割。

| 划分 | 视频序列 | 帧数 | 物体实例 |
|---|---:|---:|---:|
| train | 160 | 84,781 | 1,388,389 |
| val | 41 | 26,873 | 507,906 |
| 合计 | 201 | 111,654 | 1,896,296 |

另有 test-dev、test-challenge 划分，未公开。共 162 个类别，平均遮挡率 56.3%。

## 使用条款

下载即表示同意：

1. 仅用于非商业的研究和教育用途，**禁止商业使用**。
2. **不得**再分发数据。
3. 需购买 Grand Theft Auto V。

## 下载 (Download)

### 方式一：官方脚本（推荐）

官方脚本 [download_sailvos.sh](https://sailvos.web.illinois.edu/_site/assests/download_sailvos.sh) 会下载 RGB 帧、分割掩码和 MSCOCO 格式 JSON（**不含** 24 类 JSON），并自动解包和解压：

```bash
mkdir -p /Volumes/Expansion0/3DRDatasets/sailvos && cd /Volumes/Expansion0/3DRDatasets/sailvos
curl -L -O https://sailvos.web.illinois.edu/_site/assests/download_sailvos.sh
sh download_sailvos.sh
```

- 依赖 `wget`（macOS：`brew install wget`）。
- 脚本逐个串行下载，没有断点续传，也没有校验。

### 方式二：直接链接

所有文件托管在 UIUC Box（`uofi.box.com/shared/static/...`）。注意：这些链接对 **HEAD 请求返回 404**，但 GET 正常（2026-11-12 测试），支持 `Range` 续传，例如 `curl -L -C - -o <文件名> <链接>`、`wget -c -O <文件名> <链接>`。官方没有提供 MD5/SHA 校验值。

#### 训练集 (train)

| 文件 | 内容 | 链接 |
|---|---|---|
| `sailvos_train.tar.001` ~ `.017` | RGB 帧（分卷 tar，第 1 卷约 8.5 GB） | 见下方列表 |
| `sailvos_train_annotations.zip` | amodal / modal 分割标注 | [download](https://uofi.box.com/shared/static/lpk44na77obt02h4ry1gmzxadb17x217.zip) |
| `train.json` | MSCOCO 格式 JSON 标注 | [download](https://uofi.box.com/shared/static/jbhejcbebzepeg0fmeow4xmtvkxoh4fz.json) |
| `train_24class.json`（文件名自取） | MSCOCO 格式 JSON 标注（24 类） | [download](https://uofi.box.com/shared/static/38aigbwn3i3ydqgumep1ibda7zwb4eni.json) |

RGB 帧分卷：

| 分卷 | 链接 |
|---|---|
| `sailvos_train.tar.001` | https://uofi.box.com/shared/static/98e10vflopc6z6w70h6me1acv0aqn4yt.001 |
| `sailvos_train.tar.002` | https://uofi.box.com/shared/static/yrzhc8m1gbz8nkc4eiw33ucz5mck5bbc.002 |
| `sailvos_train.tar.003` | https://uofi.box.com/shared/static/u4bhab5yio7shmdewvooilrpzq9hpr6j.003 |
| `sailvos_train.tar.004` | https://uofi.box.com/shared/static/16hnffnx10a1j8fnwddyscz7mjykrram.004 |
| `sailvos_train.tar.005` | https://uofi.box.com/shared/static/b6kyggl2qke5gpusncg7d4727w2kodrd.005 |
| `sailvos_train.tar.006` | https://uofi.box.com/shared/static/da32234yojvzd0h3h5uvsgyczyj14e79.006 |
| `sailvos_train.tar.007` | https://uofi.box.com/shared/static/hfnmbhbwsz7vix48yxl56xwhisqfp2mh.007 |
| `sailvos_train.tar.008` | https://uofi.box.com/shared/static/c2zy7k4bthtt09ty8z1uyyofwbx5512a.008 |
| `sailvos_train.tar.009` | https://uofi.box.com/shared/static/omwdysb4nh5n4yem21s4pmbqfib0st3s.009 |
| `sailvos_train.tar.010` | https://uofi.box.com/shared/static/vgunuka03mql6p1ihibb5zd80mhd8ayx.010 |
| `sailvos_train.tar.011` | https://uofi.box.com/shared/static/9g3yo3kn6ic4p26bb108cdved1nbvjgz.011 |
| `sailvos_train.tar.012` | https://uofi.box.com/shared/static/ii9z8pww8v50d14nrh5ifksahwksfhn4.012 |
| `sailvos_train.tar.013` | https://uofi.box.com/shared/static/08bcxx3ew59dpuerzx68by59ia02ag29.013 |
| `sailvos_train.tar.014` | https://uofi.box.com/shared/static/m7ikjt28pdskbh05x6v8hsrtyptv3enj.014 |
| `sailvos_train.tar.015` | https://uofi.box.com/shared/static/wwa4gevipnqen6tg2jlbwtc8rk5fln26.015 |
| `sailvos_train.tar.016` | https://uofi.box.com/shared/static/uazawpln7k14yj59cvc5b6fq3v246tsb.016 |
| `sailvos_train.tar.017` | https://uofi.box.com/shared/static/3jzrhnq8myamqidksonmr780mnc5dx6c.017 |

#### 验证集 (val)

| 文件 | 内容 | 链接 |
|---|---|---|
| `sailvos_val.tar.001` | RGB 帧分卷 1 | https://uofi.box.com/shared/static/ah5sj80zxa71mqdde46g52whlyqi2tp8.001 |
| `sailvos_val.tar.002` | RGB 帧分卷 2 | https://uofi.box.com/shared/static/389bubh56rc99zc214a3twzu73mhmuk8.002 |
| `sailvos_val.tar.003` | RGB 帧分卷 3 | https://uofi.box.com/shared/static/r5czz4ahvgy3yqj6c9sawbfi2z7ref9s.003 |
| `sailvos_val.tar.004` | RGB 帧分卷 4 | https://uofi.box.com/shared/static/ra9ba6j9f0ihljvkt89ujwovkbrqslwc.004 |
| `sailvos_val.tar.005` | RGB 帧分卷 5 | https://uofi.box.com/shared/static/r844e898jbfit520ptvhpbrhqbd7fjr2.005 |
| `sailvos_val_annotations.zip` | amodal / modal 分割标注 | [download](https://uofi.box.com/shared/static/rdz38pn6479vjhai4s444ejd004u2dgu.zip) |
| `val.json` | MSCOCO 格式 JSON 标注（约 1.1 GB） | [download](https://uofi.box.com/shared/static/hn5iewgvi86f0nq2lsjw4xonv9t5mt2o.json) |
| `val_24class.json`（文件名自取） | MSCOCO 格式 JSON 标注（24 类） | [download](https://uofi.box.com/shared/static/0mrjurj1jfhgi7xlz5uueq4tjral9476.json) |

### 解包与解压

使用官方脚本时无需手动执行。手动下载后：

```bash
# 合并分卷 tar，得到 sailvos_train.zip / sailvos_val.zip
cat sailvos_train.tar.* | tar xvf -
cat sailvos_val.tar.* | tar xvf -

# 解压
unzip sailvos_train.zip              # -d train
unzip sailvos_val.zip                # -d val
unzip sailvos_train_annotations.zip  # -d train
unzip sailvos_val_annotations.zip    # -d val
```

## 数据结构 (Dataset Overview)

解压后每个文件夹对应一个视频序列：

```
.
├── ah_1_mcs_1
├── ah_3a_mcs_3
├── ah_3a_mcs_6
└── ...
```

每个序列下：`images/` 存放 RGB 帧，`visible/` 存放实例级可见掩码；带 4 位数字前缀的文件夹存放 amodal 掩码，前缀即物体 ID（与 `visible/` 中的 ID 一致）。

```
ah_1_mcs_1
├── images                                       # RGB 帧：000000.bmp, 000001.bmp, ...
├── visible                                      # 可见掩码：000000.npy, 000001.npy, ...
├── 0001_Ped_000000225514697_000000000172546_00  # 物体 ID=1 的 amodal 掩码
│   ├── 000000.png
│   ├── 000001.png
│   └── ...
├── 0008_Ped_000002602752943_000000000000002_00  # 物体 ID=8
└── ...
```

读取示例：

```python
import numpy as np
from PIL import Image

# 可见掩码（每个像素为物体 ID）
m = np.load('ah_1_mcs_1/visible/000000.npy')
m1 = (m == 1)  # 物体 ID=1 的可见掩码

# amodal 掩码（取值 0 / 255）
am = np.asarray(Image.open('ah_1_mcs_1/0001_Ped_000000225514697_000000000172546_00/000000.png'))
print(np.unique(am))  # [0, 255]
```

## SAIL-VOS 3D

[SAIL-VOS 3D](https://sailvos.web.illinois.edu/_site/_site/index.html)（CVPR 2021，[arXiv 2105.08612](https://arxiv.org/abs/2105.08612)）是 SAIL-VOS 的扩展，增加了逐帧物体 mesh（`.obj`，相机坐标系）、相机矩阵（`camera/*.yaml`，含 `Rt` 和 `K`）和深度（`depth/*.npy`，需额外申请）。**没有公开下载链接**，需发邮件向作者索取下载脚本，详见其 [README](https://sailvos.web.illinois.edu/_site/_site/dataset_readme.html)。

## 论文

- Y.-T. Hu, H.-S. Chen, K. Hui, J.-B. Huang, A. G. Schwing. *SAIL-VOS: Semantic Amodal Instance Level Video Object Segmentation — A Synthetic Dataset and Baselines.* CVPR 2019. [PDF](http://openaccess.thecvf.com/content_CVPR_2019/papers/Hu_SAIL-VOS_Semantic_Amodal_Instance_Level_Video_Object_Segmentation_-_A_CVPR_2019_paper.pdf)

```bibtex
@inproceedings{HuCVPR2019,
  author    = {Y.-T. Hu and H.-S. Chen and K. Hui and J.-B. Huang and A.~G. Schwing},
  title     = {{SAIL-VOS: Semantic Amodal Instance Level Video Object Segmentation -- A Synthetic Dataset and Baselines}},
  booktitle = {Proc. CVPR},
  year      = {2019},
}
```
