# Map-free Relocalization

[官方数据与许可页面](https://nianticspatial.com/research/map-free/dataset)；[官方代码](https://github.com/nianticlabs/map-free-reloc)。链接核验日期：2026-11-17。

`download_mapfree.sh` 下载官方 ZIP 文件，默认包含 train、val、test 和训练场景 COLMAP 模型；sample 是重复的小样本，需单独选择。不解压。依赖 Bash 和 wget 或 curl，支持显示速度、跳过完成文件和从 `.part` 续传。

```bash
bash Mapfree/download_mapfree.sh --list
bash Mapfree/download_mapfree.sh --target_dir /path/to/Mapfree
bash Mapfree/download_mapfree.sh --target_dir /path/to/Mapfree --split val
bash Mapfree/download_mapfree.sh --target_dir /path/to/Mapfree --split train,colmap
```

文件分别是 `train.zip`、`val.zip`、`test.zip`、`colmap.zip`、`sample.zip`。下载前阅读官网许可；脚本使用官网列出的 Google Cloud Storage 对象，不访问第三方镜像。
