# ScanNet Series

两个数据集独立申请，不能共用授权。本目录的入口均保留原始下载文件，不运行 SensReader、ZIP 解压或图像处理。

## ScanNet

按 [ScanNet 官方说明](https://github.com/ScanNet/ScanNet#scannet-data)签署协议并取得下载权限。把官方提供的 `download-scannet.py` 路径传给脚本：

```bash
bash ScanNet/download_scannet.sh --target_dir /path/to/ScanNet \
  --official_script /path/to/download-scannet.py
# 可限定场景和类型
bash ScanNet/download_scannet.sh --target_dir /path/to/ScanNet \
  --official_script /path/to/download-scannet.py --id scene0000_00 --type .sens
```

默认使用 Python 3；老版本官方脚本若要求 Python 2，可用 `--python python2` 指定。官方脚本自己的许可确认会保留，不会自动代答。核验的[官方脚本](https://kaldir.vc.in.tum.de/scannet/download-scannet.py)只下载 `.sens`、ZIP 和标注，不解压；它会跳过现有文件，但没有本仓库通用下载器的速度显示与部分文件续传能力。

## ScanNet++

[官网](https://scannetpp.mlsg.cit.tum.de/scannetpp/)要求注册、申请获批后取得个人 token 和下载工具。其最新下载工具需登录才能获取，未核实其下载配置中的解压开关，因此本目录不猜测下载 API，也不直接运行无法确认解压行为的版本。

`download_scannetpp.sh` **目前是授权链接下载入口，不是自动枚举全量场景的下载器**。先从获批页面/下载配置取得真实文件链接，手动整理 TSV，然后运行：

```bash
bash ScanNet/download_scannetpp.sh --target_dir /path/to/ScanNetPP --manifest /path/to/scannetpp.tsv
```

## 授权 URL/清单模式

两个入口都接受 `--manifest FILE.tsv`，每行是“相对保存路径 + Tab + 有效 HTTP(S) 下载链接”，无表头，可包含 `#` 注释。也可以使用 `--url "$AUTHORIZED_URL" --filename scene/archive.zip` 下载单个文件。

此模式依赖 Bash 与 wget 或 curl，显示速度、跳过最终文件，续传 `.part`。它不会获取 token、自动生成授权链接或代办申请。链接过期时需从官方更新；保留同一相对文件名即可续传。不要把私人 token 或签名 URL 提交到 Git。核验日期：2026-11-17。
