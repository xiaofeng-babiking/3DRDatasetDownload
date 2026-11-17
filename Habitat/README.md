# Habitat / HM3D

这里将清单中的 Habitat 具体落实为 **Habitat-Matterport 3D（HM3D）v0.2**。它提供场景网格与标注；RGB-D 轨迹需要之后用仿真器渲染，不在下载脚本中生成。

脚本使用 [Matterport 官方文件列表](https://github.com/matterport/habitat-matterport-3dresearch#-downloading-hm3d-v02) 和 [Habitat 官方配置](https://github.com/facebookresearch/habitat-sim/blob/main/src_python/habitat_sim/utils/datasets_download.py) 的地址，仅下载归档，不调用会自动解压的 Habitat 安装器。

先按 [HM3D 主页](https://aihabitat.org/datasets/hm3d/) 申请数据访问。将账户获得的 API token ID/secret 写入个人 netrc 文件（不要提交仓库）：

```text
machine api.matterport.com
  login YOUR_TOKEN_ID
  password YOUR_TOKEN_SECRET
```

```bash
chmod 600 /path/to/matterport.netrc
bash Habitat/download_habitat.sh --netrc /path/to/matterport.netrc --target_dir /data/HM3D
bash Habitat/download_habitat.sh --split val --format glb --netrc /path/to/matterport.netrc --target_dir /data/HM3D
# 无需凭据的官方示例
bash Habitat/download_habitat.sh --split example --target_dir /data/HM3D
```

默认下载 train/val/minival 的 BASIS 压缩网格、场景配置、语义标注与语义配置。`--format glb` 选择普通 GLB；`--format all` 下载两种网格；`--without_semantics` 跳过语义归档。`--list` 无需凭据，仅打印文件/URL。默认输出 `./data/Habitat/<split>`。

依赖 Bash、curl；显示速度、续传 `.part`、跳过已完成文件。HTTP 401/403 时检查账户审批及凭据，脚本不会绕过访问控制。凭据留在 netrc 文件，不放到命令行参数里。来源核对日期：2026-11-17。
