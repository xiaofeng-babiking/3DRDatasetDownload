# WildRGB-D 下载

脚本依据 [WildRGB-D 官方下载器](https://github.com/wildrgbd/wildrgbd/blob/main/download.py)的类别、分卷名和 Hugging Face 地址，下载全部 46 类、93 个 ZIP/ZIP 分卷。文件清单保存在 `archives.tsv`，默认全量，也可以按类别筛选。只下载，不合并分卷、不解压、不删除归档。

依赖 Bash 和 `wget` 或 `curl`。显示下载速度，使用 `.part` 断点续传，跳过已有最终文件。官方估计归档约 3.37 TiB。现有下载地址是作者的 [hongchi/wildrgbd](https://huggingface.co/hongchi/wildrgbd) **model 类型仓库**，不是 `/datasets/` 路径。来源核对日期：2026-11-17。

```bash
bash WildRGBD/download_wildrgbd.sh --target_dir /path/to/WildRGBD

# 下载指定类别，自动包括该类别的所有分卷
bash WildRGBD/download_wildrgbd.sh --target_dir /path/to/WildRGBD --categories apple,bottle

# 离线查看清单；TV 为大写，其他类别也须精确匹配
bash WildRGBD/download_wildrgbd.sh --categories TV,remote_control --list
```

全部类别名可查看 `archives.tsv` 第一列。下载失败后重新运行相同命令即可续传。已有最终文件按完成处理；本脚本不提供官方没有发布的校验和。
