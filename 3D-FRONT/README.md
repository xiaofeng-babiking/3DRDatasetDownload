# 3D-FRONT

来源：<https://pages.tmall.com/wow/cab/tianchi/promotion/alibaba-3d-scene-dataset>、<https://tianchi.aliyun.com/dataset/dataDetail?dataId=65347>（抓取于 2026-11-12）

3D-FRONT（3D Furnished Rooms with layOuts and semaNTics，ICCV 2021）是阿里巴巴淘系技术部与躺平设计家（Topping Homestyler）发布的大规模合成室内场景数据集：由专业设计师布置的 **6,813 套户型、18,797 个房间**（论文初版为 18,968 个），房间内摆放来自配套数据集 **3D-FUTURE** 的带高质量纹理的家具模型（7,302 个；论文为 13,151 个）。提供房屋布局（墙、地板、门窗等结构网格）、家具实例的位置与语义、材质与纹理。它本身是静态 3D 资产，不含固定帧序列，常用于室内场景生成（ATISS、DiffuScene 等）以及用 BlenderProc 等工具渲染 RGB-D 训练数据。

> 原 Tianchi 专题页 `tianchi.aliyun.com/specials/promotion/alibaba-3d-scene-dataset` 在 2026-11-12 已返回"页面无法访问"，现可通过上面的 tmall 镜像页查看。

## 下载 (Download)

**没有公开下载链接**（必须同意使用条款），流程如下：

1. 阅读 [3D-FRONT Terms of Use](https://pages.tmall.com/wow/cab/tianchi/promotion/alibaba-3d-scene-dataset)（页面上的 PDF）。
2. 在天池 TC Lab 的数据集页面申请：<https://tianchi.aliyun.com/dataset/dataDetail?dataId=65347>（需登录阿里云 / 天池账号）。
3. 审批通过后会得到三个数据包的下载链接：房屋布局（3D-FRONT）、家具模型（3D-FUTURE-model）、纹理（3D-FRONT-texture）。
4. 问题请联系 tianchi_bigdata@member.alibaba.com。

> BlenderProc 文档记录的旧流程是签署使用条款 PDF 后发邮件到 3dfront@list.alibaba-inc.com，以天池页面的说明为准。

把拿到的链接按每行一个保存到文本文件，然后：

```bash
./download_3d_front.sh -l 3dfront_links.txt -o /path/to/3D-FRONT -x
```

脚本会用 `wget -c` 断点续传，自动合并分卷 zip（`*.zip` + `*.z01` …），解压到工具链通用的目录结构，并检查三个目录是否齐全。

## 数据结构 (Dataset Overview)

```
3D-FRONT/                  # 2022-01 版本
├── 3D-FRONT/
│   └── <house_id>.json    # 一套户型：结构网格、房间、家具实例（引用 3D-FUTURE 的 model jid）、材质
├── 3D-FUTURE-model/       # 2021-04 版本
│   ├── model_info.json    # 每个模型的类别、风格、材质等
│   └── <model_id>/
│       ├── raw_model.obj
│       ├── model.mtl
│       └── texture.png
└── 3D-FRONT-texture/      # 可选：墙面 / 地板纹理
    └── <material_id>/texture.png
```

- 房屋 JSON 通过 `jid` 引用 `3D-FUTURE-model/` 中的家具，所以两者需要一起下载。
- 没有 `3D-FRONT-texture/` 时，墙面和地板使用 JSON 中的纯色。
- 常用工具：官方 [3D-FRONT-ToolBox](https://github.com/3D-FRONT-FUTURE/3D-FRONT-ToolBox)、[BlenderProc front_3d 示例](https://dlr-rm.github.io/BlenderProc/examples/datasets/front_3d/README.html)、[ATISS](https://github.com/nv-tlabs/ATISS) 预处理脚本。

## 注意事项

不同户型之间大量复用 3D-FUTURE 中的同一批家具模型，按户型随机划分训练 / 测试集时仍可能出现几何特征泄漏。

## 许可 (License)

遵循 3D-FRONT Terms of Use（仅限研究用途，须经申请批准）。

## 引用

```bibtex
@inproceedings{fu20213d,
  title     = {3d-front: 3d furnished rooms with layouts and semantics},
  author    = {Fu, Huan and Cai, Bowen and Gao, Lin and Zhang, Ling-Xiao and Wang, Jiaming and Li, Cao and Zeng, Qixun and Sun, Chengyue and Jia, Rongfei and Zhao, Binqiang and others},
  booktitle = {Proceedings of the IEEE/CVF International Conference on Computer Vision},
  pages     = {10933--10942},
  year      = {2021}
}

@article{fu20213dfuture,
  title     = {3d-future: 3d furniture shape with texture},
  author    = {Fu, Huan and Jia, Rongfei and Gao, Lin and Gong, Mingming and Zhao, Binqiang and Maybank, Steve and Tao, Dacheng},
  journal   = {International Journal of Computer Vision},
  pages     = {1--25},
  year      = {2021},
  publisher = {Springer}
}
```
