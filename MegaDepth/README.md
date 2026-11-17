# MegaDepth 下载

从 [Cornell 官方 MegaDepth 页面](https://www.cs.cornell.edu/projects/megadepth/)下载两个原始发布包：图像与深度 `MegaDepth_v1.tar.gz`（官网标注约 199 GB）及相机/稀疏重建 `MegaDepth_SfM_v1.tar.xz`（约 667 GB）。默认两者都下载，只保留归档、不解压。

依赖 Bash 和 `wget` 或 `curl`。显示速度，支持 `.part` 续传、跳过已有最终文件；没有额外的全文件校验。官方深度与 SfM 数据采用 CC BY 4.0，原始图像有各自许可，详见官网。来源核对日期：2026-11-17。

```bash
bash MegaDepth/download_megadepth.sh --target_dir /path/to/MegaDepth

# 仅下载图像和深度
bash MegaDepth/download_megadepth.sh --target_dir /path/to/MegaDepth --component images_depth

# 仅下载 SfM 模型
bash MegaDepth/download_megadepth.sh --target_dir /path/to/MegaDepth --component sfm

# 离线查看两个官方链接
bash MegaDepth/download_megadepth.sh --list
```
