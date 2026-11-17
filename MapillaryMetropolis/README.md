# Mapillary Metropolis

[官方入口](https://www.mapillary.com/dataset/metropolis)。2026-11-17 核验时，未登录页面要求先登录，未能取得可公开枚举的官方文件清单。因此这里提供**授权链接下载脚本**，不声称无需登录即可一键下载全量数据。

先登录官方页面，按其要求取得访问权限，复制真实的文件下载 URL（如带时效签名的直链）。然后手动建立本地 TSV 清单：每行是 `相对保存路径<Tab>HTTP(S)下载URL`，没有表头；Tab 是真实制表符，不是两个字符 `\\t`。允许空行和 `#` 注释。

```bash
bash MapillaryMetropolis/download_mapillary_metropolis.sh --target_dir /path/to/MapillaryMetropolis --manifest /path/to/files.tsv
# 下载单个授权文件；先将 AUTHORIZED_URL 设置为官方给出的真实直链
bash MapillaryMetropolis/download_mapillary_metropolis.sh --target_dir /path/to/MapillaryMetropolis \
  --url "$AUTHORIZED_URL" --filename archive.zip
```

依赖 Bash 和 wget 或 curl；仅下载，显示速度、跳过已完成文件，未完成内容保存在 `.part` 以便重跑续传。不会登录、接受条款、寻找私人凭证、枚举账号内文件或解压。网页登录页/数据集介绍页不能作为文件 URL。签名过期时需从官方获取新链接；不要将私人签名 URL 提交到 Git。
