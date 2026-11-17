# Replica

`download_replica.sh` 下载原始 Replica v1.0 场景资产的 17 个分卷（`partaa` 至 `partaq`）及附加 Habitat 配置 ZIP，不合并、不解压。这是原始网格数据，不是第三方渲染的 SLAM 图像序列。

地址来自 [官方脚本](https://github.com/facebookresearch/Replica-Dataset/blob/main/download.sh) 和 [官方 v1.0 release](https://github.com/facebookresearch/Replica-Dataset/releases/tag/v1.0)。使用前阅读项目的数据许可。

```bash
bash Replica/download_replica.sh --target_dir /data/Replica
bash Replica/download_replica.sh --target_dir /data/Replica --without_configs
bash Replica/download_replica.sh --list
```

依赖 Bash、wget 或 curl；支持 `.part` 续传、显示速度、跳过已完成文件。默认输出 `./data/Replica`。配置 ZIP 托管于 Meta CDN，如果该 CDN 暂时不可达，可用 `--without_configs` 先获取全部场景分卷。脚本失败会非零退出，不会把未完成文件标记为成功。

来源核对日期：2026-11-17。
