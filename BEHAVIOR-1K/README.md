# BEHAVIOR-1K

来源：<https://behavior.stanford.edu/>、<https://github.com/StanfordVL/BEHAVIOR-1K>、<https://huggingface.co/behavior-1k>（抓取于 2026-11-12）

BEHAVIOR-1K 是斯坦福发布的具身智能仿真基准，包含 1,000 项源自真实人类时间使用调查的日常家务活动（清洁、烹饪、整理等），以及基于 NVIDIA Omniverse / Isaac Sim 的仿真器 **OmniGibson**。数据部分包括 **50 个可交互的完整室内场景**和 9,000 多个标注了物理与语义属性的物体模型。仿真器可以渲染 RGB、深度、法线、语义 / 实例分割、光流等，因此它本身是**仿真环境，没有固定帧序列**。2025 BEHAVIOR Challenge 额外发布了 10,000 条遥操作示范，带渲染好的 RGB / 深度 / 实例分割视频，可直接作为离线数据使用。

## 下载 (Download)

| 文件 | 作用 |
|---|---|
| `download_behavior_1k.sh` | 入口脚本：解析参数，按需安装 `requirements.txt`，然后调用 Python 脚本 |
| `download_behavior_1k.py` | 实际的下载逻辑（`huggingface_hub.snapshot_download` + OmniGibson 官方函数），也可单独运行 |
| `requirements.txt` | Python 依赖（`huggingface_hub`）；OmniGibson 需用官方安装程序另外安装 |

用环境变量 `PYTHON` 指定解释器（默认 `python3`），缺少依赖时会自动 `pip install -r requirements.txt` 到该解释器。下面几个 Hugging Face 仓库无需申请。

```bash
# 先看看会下载哪些文件（-n：dry run）
./download_behavior_1k.sh -n -t 0 -m rgb -c head demos

# 示范数据：任务 0~2，只要头部相机的 RGB 和深度
./download_behavior_1k.sh -o /path/to/BEHAVIOR-1K -t 0,1,2 -m rgb,depth -c head demos

# 全部示范视频 + 状态 / 动作 / 标注（约 1.57 TB）
./download_behavior_1k.sh demos

# 原始 HDF5 示范（约 793 GB）
./download_behavior_1k.sh -t 0 rawdata

# 仿真器场景与物体资产（需先安装 OmniGibson，会显示数据许可并要求同意）
PYTHON=~/miniconda3/envs/behavior/bin/python ./download_behavior_1k.sh assets

# 也可以直接运行 Python 脚本
pip install -r requirements.txt
python download_behavior_1k.py --tasks 0 1 2 --modalities rgb depth --cameras head demos
```

> `demos` 仓库有约 10 万个文件，开始下载前列出文件需要约 1 分钟。重新运行同一命令会跳过已下载完成的文件。

| PART | 来源 | 内容 | 大小 |
|---|---|---|---:|
| `demos` | [behavior-1k/2025-challenge-demos](https://huggingface.co/datasets/behavior-1k/2025-challenge-demos) | LeRobot v2.1 格式：10,000 条示范、50 个任务、约 1.19 亿帧（30 fps），R1Pro 机器人头部（720×720）与左右手腕（480×480）相机的 RGB / 深度 / 实例分割视频，及状态、动作、相机相对位姿、标注 | ~1.57 TB |
| `rawdata` | [behavior-1k/2025-challenge-rawdata](https://huggingface.co/datasets/behavior-1k/2025-challenge-rawdata) | 同一批示范的原始 HDF5（`task-XXXX/episode_XXXXXXXX.hdf5`） | ~793 GB |
| `assets` | 官方安装函数 | OmniGibson 机器人资产、BEHAVIOR-1K 场景与物体资产（加密）、解密密钥、2026 Challenge 任务实例 | ~32 GB |
| `assets_zip` | [behavior-1k/zipped-datasets](https://huggingface.co/datasets/behavior-1k/zipped-datasets) | 只下载上述资产压缩包（`behavior-1k-assets-3.9.0.zip` 31.5 GB 等），不安装 | ~32 GB |

### 关于仿真器资产（`assets`）

BEHAVIOR 数据包包含第三方美术资产，有再分发限制，因此资产是**加密**的，解密密钥只能由官方安装程序在你同意 BEHAVIOR Data Bundle 许可后下载。本仓库的脚本不绕过这一步，而是直接调用 OmniGibson 自带的函数：

```bash
# 1. 安装 OmniGibson（需要 Linux/Windows + NVIDIA GPU，Isaac Sim 不支持 macOS）
git clone https://github.com/StanfordVL/BEHAVIOR-1K && cd BEHAVIOR-1K
./setup.sh --new-env --omnigibson --bddl            # 加 --dataset 可在安装时一并下载资产

# 2. 用装有 OmniGibson 的解释器下载资产到 $OMNIGIBSON_DATA_PATH（脚本默认设为 OUTPUT_ROOT/omnigibson-data）
PYTHON=$(conda run -n behavior which python) ./download_behavior_1k.sh assets
```

等价的官方命令：

```bash
python -c "from omnigibson.utils.asset_utils import download_omnigibson_robot_assets; download_omnigibson_robot_assets()"
python -c "from omnigibson.utils.asset_utils import download_behavior_1k_assets; download_behavior_1k_assets()"
python -c "from omnigibson.utils.asset_utils import download_2026_challenge_task_instances; download_2026_challenge_task_instances()"
```

详见官方 [Installation Guide](https://behavior.stanford.edu/getting_started/installation.html)。

## 数据结构 (Dataset Overview)

`demos`（LeRobot v2.1）：

```
2025-challenge-demos/
├── meta/
│   ├── info.json                 # 特征定义、fps、路径模板
│   ├── tasks.jsonl
│   ├── episodes.jsonl
│   ├── episodes_stats.jsonl
│   └── episodes/task-XXXX/episode_XXXXXXXX.json
├── data/task-XXXX/episode_XXXXXXXX.parquet          # action(23) / observation.state(256) / cam_rel_poses(21) / timestamp ...
├── videos/task-XXXX/
│   ├── observation.images.rgb.{head,left_wrist,right_wrist}/episode_XXXXXXXX.mp4
│   ├── observation.images.depth.{head,left_wrist,right_wrist}/episode_XXXXXXXX.mp4
│   └── observation.images.seg_instance_id.{head,left_wrist,right_wrist}/episode_XXXXXXXX.mp4
└── annotations/task-XXXX/episode_XXXXXXXX.json
```

视频均为 libx265 编码；深度和实例分割也被编码成视频，解码方式请参考 BEHAVIOR Challenge 的 [文档](https://behavior.stanford.edu/challenge/)。

`assets` 安装后位于 `$OMNIGIBSON_DATA_PATH/`：`omnigibson-robot-assets/`、`behavior-1k-assets/`（场景与物体）、`2026-challenge-task-instances/`、`omnigibson.key`。

## 许可 (License)

- 仿真器资产：BEHAVIOR Data Bundle License Agreement（安装时显示，禁止再分发和逆向解密第三方内容）；OmniGibson 代码为 MIT。
- 2025 Challenge 示范数据（`demos`、`rawdata`）：Hugging Face 数据卡标注为 MIT。

## 引用

```bibtex
@article{li2024behavior1k,
  title   = {BEHAVIOR-1K: A Human-Centered, Embodied AI Benchmark with 1,000 Everyday Activities and Realistic Simulation},
  author  = {Chengshu Li and Ruohan Zhang and Josiah Wong and Cem Gokmen and Sanjana Srivastava and Roberto Martín-Martín and Chen Wang and Gabrael Levine and Wensi Ai and Benjamin Martinez and Hang Yin and Michael Lingelbach and Minjune Hwang and Ayano Hiranaka and Sujay Garlanka and Arman Aydin and Sharon Lee and Jiankai Sun and Mona Anvari and Manasi Sharma and Dhruva Bansal and Samuel Hunter and Kyu-Young Kim and Alan Lou and Caleb R Matthews and Ivan Villa-Renteria and Jerry Huayang Tang and Claire Tang and Fei Xia and Yunzhu Li and Silvio Savarese and Hyowon Gweon and C. Karen Liu and Jiajun Wu and Li Fei-Fei},
  journal = {arXiv preprint arXiv:2403.09227},
  year    = {2024}
}
```
