# HOT3D

`download_hot3d.sh` 下载完整 VRS 版 HOT3D 的 Aria、Quest 和 Assets 三部分，只保留原始下载文件，不解压。默认 `--subset all`；也可单选 `aria`、`quest`、`assets`。这不是经过裁剪的 HOT3D-Clips 版本。

先在 [官方数据页](https://www.projectaria.com/datasets/hot3D/) 用邮箱申请访问并获取 `Hot3DAria_download_urls.json`、`Hot3DQuest_download_urls.json`、`Hot3DAssets_download_urls.json`，放入 `Aria/urls/`。链接会过期；失效时重新获取。获取方式见 [官方工具说明](https://github.com/facebookresearch/hot3d#step-2-sign-up-and-get-the-download-links-file)。脚本不会代替用户注册或接受许可。

```bash
bash HOT3D/download_hot3d.sh --target_dir /data/HOT3D
bash HOT3D/download_hot3d.sh --subset aria --url_json /path/Hot3DAria_download_urls.json --target_dir /data/HOT3D --n_workers 8
bash HOT3D/download_hot3d.sh --subset aria --max_sequences 1 --list
```

依赖 Bash、Python 3 标准库。复用仓库 Aria 下载器：`.part` 断点续传，SHA1/大小校验，跳过已验证文件，每 10 秒报告速度。`--sequence 'P0003_*'` 可筛选序列；筛选选项作用于每个选中的子集，下载 Assets 时通常不要传序列筛选。缺少任何需要的 JSON 会在下载前报错。默认输出 `./data/HOT3D/<subset>`。

来源核对日期：2026-11-17。
