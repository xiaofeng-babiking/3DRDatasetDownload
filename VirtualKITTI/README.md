# Virtual KITTI 1.3.1

下载 [NAVER LABS 官方页面](https://europe.naverlabs.com/research/computer-vision/proxy-virtual-worlds-vkitti-1/) 列出的原始 v1.3.1 文件。来源核对日期：2026-11-17。

```bash
# 全部 6 个模态包，保留压缩包，不解压
bash VirtualKITTI/download_vkitti.sh --target_dir /path/to/VirtualKITTI

# 只下载图像、深度和相机外参
bash VirtualKITTI/download_vkitti.sh --target_dir /path/to/VirtualKITTI rgb depthgt extrinsicsgt
```

依赖 Bash 与 `wget` 或 `curl`。支持速度显示、`.part` 断点续传和跳过已完成文件；失败返回非零。相机内参见官网说明，官网没有独立的内参压缩包。

可选模态：`rgb`、`depthgt`、`extrinsicsgt`、`motgt`、`scenegt`、`flowgt`。脚本同时保存官方 MD5 清单；不默认读取全部大文件进行校验。

Virtual KITTI 2 是独立版本，使用 [../VirtualKITTI2/download_vkitti2.sh](../VirtualKITTI2/download_vkitti2.sh)。使用数据前请阅读官网条款；脚本不会代替用户填写申请或确认许可。
