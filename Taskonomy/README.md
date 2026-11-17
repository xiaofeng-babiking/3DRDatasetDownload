# Taskonomy

[Taskonomy 官方下载说明](https://github.com/StanfordVL/taskonomy/tree/master/data)将下载入口指向 [Omnidata 下载工具](https://docs.omnidata.vision/starter_dataset_download.html)。本脚本只选择其中的 `taskonomy` 组件，默认全量 `fullplus` 和所有模态，不包含其他 Omnidata 组件。

先在自己的 Python 环境安装 `omnidata-tools`，并安装系统 `aria2c`。脚本不会安装依赖，也不会代答官方许可提示。

```bash
# 安装在你选定的 Python 环境；aria2 需另行通过系统包管理器安装
python -m pip install omnidata-tools

bash Taskonomy/download_taskonomy.sh --target_dir /path/to/Taskonomy
bash Taskonomy/download_taskonomy.sh --target_dir /path/to/Taskonomy \
  --subset tiny --split train --domains rgb,depth_zbuffer,point_info
bash Taskonomy/download_taskonomy.sh --subset debug --dry-run
```

固定传入 `--only_download True --keep_compressed True`，压缩包直接保存在目标目录，禁止进入官方工具的解压分支。该参数使用官方 `bool_arg` 类型（[源码](https://github.com/EPFL-VILAB/omnidata/blob/main/omnidata_tools/dataset/download.py)），不是无值开关。并发与连接数分别由 `--n_workers`、`--connections_total` 设置，默认均为 8；进度与重试由官方 aria2 下载器负责。

该发行版是 Taskonomy 官网推荐的 Omnidata 分发版本。数据可用性、模态名称及许可按官方工具为准。脚本与文档核验于 2026-11-17，未实际下载全量数据。
