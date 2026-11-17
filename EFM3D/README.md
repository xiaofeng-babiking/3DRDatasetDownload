# EFM3D

EFM3D 是基于 ASE、ADT、AEO 的基准；不是另一个统一 RGB-D 数据包。`download_efm3d.sh` 按 [官方数据说明](https://github.com/facebookresearch/efm3d/blob/main/data/README.md) 下载以下子集，保留 ZIP/TAR/VRS 原始文件，不运行解压或训练：

| `--subset` | 范围 | 所需 CDN JSON |
|---|---|---|
| `ase-train` | ASE ATEK `efm` 配置全部分片 | `AriaSyntheticEnvironment_ATEK_download_urls.json` |
| `ase-eval` | ASE ATEK `efm_eval` 配置全部分片 | 同上 |
| `ase-mesh` | ASE 评估 mesh ZIP | `ase_mesh_download_urls.json` |
| `adt` | 官方列出的 6 条 ADT 评估序列，保留其所有数据组 | `ADT_download_urls.json` |
| `adt-mesh` | 官方发布的 `adt_mesh.zip` | 无，公开 GitHub release |
| `aeo` | AEO 全部序列/数据组 | `AEO_download_urls.json` |
| `all`（默认） | 上述全部 | 上述全部 JSON |

从 [Project Aria](https://www.projectaria.com/datasets/) 对应数据集页面获取个人 CDN JSON，默认放在 `Aria/urls/`。也可传 `--urls_dir DIR`，单个子集可传 `--url_json FILE`。个人链接过期时重新获取；缺失 JSON 会在开始下载前报错。

```bash
bash EFM3D/download_efm3d.sh --target_dir /data/EFM3D
bash EFM3D/download_efm3d.sh --subset ase-eval --max_sequences 1 --target_dir /data/EFM3D
bash EFM3D/download_efm3d.sh --subset adt-mesh --target_dir /data/EFM3D
```

依赖 Bash、Python 3；公开 ZIP 另外使用 wget 或 curl。复用 Aria 下载器实现断点续传、速度显示、SHA1 校验。`--list` 仅列文件。输出在 `<target_dir>/<subset>/`，ATEK 分片再按配置/序列分层保存；本脚本不生成训练用 YAML，不重排分片，也不下载模型权重。默认输出 `./data/EFM3D`。

ADT mesh 的直接来源：[官方下载脚本](https://github.com/facebookresearch/efm3d/blob/main/data/download_adt_mesh.sh)。来源核对日期：2026-11-17。
