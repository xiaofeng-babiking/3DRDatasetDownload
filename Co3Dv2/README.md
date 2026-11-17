# CO3Dv2 下载

脚本读取 [官方 `co3d/links.json`](https://github.com/facebookresearch/co3d/blob/main/co3d/links.json)，下载 ZIP 与配套类别元数据。默认包含全部类别；可选单序列子集。只下载、不解压，不需要安装 PyTorch 或执行官方解压程序。

依赖 Bash、Python 3 标准库及 `wget` 或 `curl`。支持速度显示、`.part` 断点续传和跳过已有最终文件。执行前请阅读 [官方说明与许可证](https://github.com/facebookresearch/co3d)。来源核对日期：2026-11-17。

```bash
# 全部 CO3Dv2
bash Co3Dv2/download_co3dv2.sh --target_dir /path/to/Co3Dv2

# 只下载 apple、chair
bash Co3Dv2/download_co3dv2.sh --target_dir /path/to/Co3Dv2 --categories apple,chair

# 先查看单序列子集的文件清单（只获取小型链接 JSON）
bash Co3Dv2/download_co3dv2.sh --subset singlesequence --categories apple --list
```

输出到 `目标目录/full/` 或 `目标目录/singlesequence/`。每次运行默认获取最新官方清单，也可用 `--links_json FILE` 指定官方 JSON 的本地副本。已有最终文件按完成处理，不重新计算校验和。
