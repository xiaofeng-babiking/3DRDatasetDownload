# uCO3D 下载

[官方项目](https://github.com/facebookresearch/uco3d)提供视频、掩码、深度、点云和 Gaussian Splat 归档。这里的脚本读取官方类别清单，默认从[官方 Hugging Face 镜像](https://huggingface.co/datasets/facebook/uco3d)下载所有模态及类别（包含深度）；完整数据规模约 19 TB。只保留 ZIP，不解压。

依赖 Bash、Python 3 标准库及 `wget` 或 `curl`。支持速度显示、`.part` 断点续传、跳过已有最终文件。来源核对日期：2026-11-17。

```bash
# 全量（含 depth_maps）
bash uCO3D/download_uco3d.sh --target_dir /path/to/uCO3D

# 只下载指定超类别的视频、点云；自动包含 metadata.zip
bash uCO3D/download_uco3d.sh --target_dir /path/to/uCO3D \
  --modalities rgb_videos,point_clouds --super_categories stationery

# 52 段视频的小样本 examples.zip，约 9.6 GB
bash uCO3D/download_uco3d.sh --target_dir /path/to/uCO3D --small_subset

# 只查看清单（会获取官方类别 JSON，不下载归档）
bash uCO3D/download_uco3d.sh --modalities metadata --list
```

`--source cdn` 可改用官方 CDN；脚本每次刷新链接 JSON，因为 CDN 签名可能过期。也可用 `--category_json`、`--links_json` 指定对应官方清单的本地副本。默认 Hugging Face 来源不需要执行官方 Python 下载器，也不需要安装 uCO3D 包。

类别与文件映射来自 [category_to_archives.json](https://github.com/facebookresearch/uco3d/blob/main/dataset_download/category_to_archives.json)，CDN 清单来自 [uco3d_dataset_download_urls.json](https://github.com/uco3d/uco3d.github.io/blob/main/links/uco3d_dataset_download_urls.json)。已有文件按完成处理，不重新计算 SHA256。`vggt_omega_anno/` 是仓库原有的附加标注脚本，不属于本次全量数据下载入口。
