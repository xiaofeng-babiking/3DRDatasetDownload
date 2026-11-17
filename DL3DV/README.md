# DL3DV 下载

使用 [DL3DV 官方仓库](https://github.com/DL3DV-10K/Dataset)指定的 Hugging Face 数据集。下载前需要用户在对应数据集页面申请访问并同意条款，然后使用 `hf auth login` 登录，或在环境中配置 `HF_TOKEN`。脚本不会代为申请、同意条款或安装依赖。

在自己的 Python 环境安装 `huggingface_hub` 后，使用其 `hf` CLI。下载显示进度与速度，缓存用于恢复未完成下载和跳过最新文件；请保留下载目录下的 `.cache/huggingface/`。只下载 ZIP/MP4，不解压。

```bash
# 查看将执行的命令与所需权限页面，不访问网络
bash DL3DV/download_dl3dv.sh --target_dir /path/to/DL3DV --dry_run

# 默认：480P 图像与位姿、全部分区（含 11K）
bash DL3DV/download_dl3dv.sh --target_dir /path/to/DL3DV

# 仅 1K 分区的 960P 图像与位姿
bash DL3DV/download_dl3dv.sh --target_dir /path/to/DL3DV \
  --resolution 960P --subset 1K

# 全量原始视频，或 COLMAP 缓存
bash DL3DV/download_dl3dv.sh --target_dir /path/to/DL3DV --file_type video
bash DL3DV/download_dl3dv.sh --target_dir /path/to/DL3DV --file_type colmap_cache
```

`--resolution` 可选 `480P`、`960P`、`2K`、`4K`，仅影响 `images+poses`。`--subset 2K` 指第 2 个千场景分区，不是前 2,000 个场景；可选 `1K` 至 `11K` 或默认 `all`。

数据存放在 `目标目录/DL3DV-ALL-480P/` 等对应仓库子目录中，避免不同分辨率的同名 ZIP 相互覆盖。来源：[官方下载器的仓库与路径映射](https://github.com/DL3DV-10K/Dataset/blob/main/scripts/download.py)、[480P 数据集与权限入口](https://huggingface.co/datasets/DL3DV/DL3DV-ALL-480P)、[hf CLI 文档](https://huggingface.co/docs/huggingface_hub/guides/cli)。核对日期：2026-11-17。
