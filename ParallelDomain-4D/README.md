# ParallelDomain-4D

来源：<https://gcd.cs.columbia.edu/>（抓取于 2026-11-12）

ParallelDomain-4D 是 GCD（Generative Camera Dolly，ECCV 2024）论文发布的合成动态驾驶场景数据集，由 Parallel Domain 仿真平台生成，约 1,500 个场景（train + val + test），每个场景由多个同步的虚拟相机环绕拍摄，提供多视角 RGB、深度、语义分割、光流、LiDAR 和相机位姿，用于单目动态新视角合成。同一页面还提供 Kubric-4D（基于 Kubric 的多物体动态场景，3,000 个场景）。

## 下载 (Download)

```bash
# ParallelDomain-4D 基础模态（2.3 TB）
./download_paralleldomain4d.sh

# 基础 + 附加模态（共约 5.5 TB），并解压到同一目录
./download_paralleldomain4d.sh -o /path/to/PD4D -x pd4d pd4d_other

# Kubric-4D 的 tiny / val / test 子集
./download_paralleldomain4d.sh kubric_tiny kubric_val kubric_test
```

### ParallelDomain-4D

| 内容 | 大小 | 链接 |
|---|---:|---|
| 完整数据集，基础模态（约 1,500 场景） | 2.3 TB（解压后 2.4 TB） | <https://tri-ml-public.s3.amazonaws.com/datasets/ParallelDomain-4D.tar> |
| 完整数据集，附加模态（需与上面合并） | 3.2 TB | <https://s3.us-east-1.amazonaws.com/tri-ml-public.s3.amazonaws.com/urp/datasets/tcow/ParallelDomain-4D-OtherModalities.tar> |

> 官方说明：部分场景文件夹不存在，部分场景缺少少量帧。

### Kubric-4D

| 内容 | 大小 | 链接 |
|---|---:|---|
| 训练集（2,800 场景，18 个分卷） | 6.5 TB | 官方脚本 [gcd_kubric4d_train_dl.sh](https://gcd.cs.columbia.edu/gcd_kubric4d_train_dl.sh) |
| 验证集（100 场景） | 239 GB | [gcd_kubric4d_val.tar.gz](https://s3.us-east-1.amazonaws.com/tri-ml-public.s3.amazonaws.com/urp/datasets/tcow/gcd_kubric4d_val.tar.gz) |
| 测试集（100 场景） | 237 GB | [gcd_kubric4d_test.tar.gz](https://s3.us-east-1.amazonaws.com/tri-ml-public.s3.amazonaws.com/urp/datasets/tcow/gcd_kubric4d_test.tar.gz) |
| 迷你训练子集（20 场景） | 48 GB | [gcd_kubric4d_tiny.tar.gz](https://s3.us-east-1.amazonaws.com/tri-ml-public.s3.amazonaws.com/urp/datasets/tcow/gcd_kubric4d_tiny.tar.gz) |

训练集下载完后合并解压：`cat gcd_kubric4d_train.tar.gz.* | tar xvfz -`（压缩 7.0 TB，解压后 7.8 TB）。

## 数据结构 (Dataset Overview)

数据加载与预处理代码见 [basilevh/gcd](https://github.com/basilevh/gcd)（`data/` 目录下的 ParallelDomain-4D / Kubric-4D 数据集类）。自行生成数据请参考仓库的 [Dataset Generation](https://github.com/basilevh/gcd#dataset-generation) 部分。

## 许可 (License)

项目页面未声明数据许可，请参考 [GCD 仓库](https://github.com/basilevh/gcd) 与 Parallel Domain 的使用条款。

## 引用

```bibtex
@inproceedings{vanhoorick2024gcd,
  title   = {Generative Camera Dolly: Extreme Monocular Dynamic Novel View Synthesis},
  author  = {Van Hoorick, Basile and Wu, Rundi and Ozguroglu, Ege and Sargent, Kyle and Liu, Ruoshi and Tokmakov, Pavel and Dave, Achal and Zheng, Changxi and Vondrick, Carl},
  journal = {European Conference on Computer Vision (ECCV)},
  year    = {2024}
}
```
