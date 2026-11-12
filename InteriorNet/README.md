# InteriorNet

来源：<https://interiornet.org/>、[interiornet_format.pdf](https://interiornet.org/items/interiornet_format.pdf)（抓取于 2026-11-12）

InteriorNet（BMVC 2018）是 Imperial College 与酷家乐（Kujiale.com）合作发布的超大规模照片级室内合成数据集：基于约 100 万个家具 CAD 模型和 2,200 万个专业设计师布局，渲染了约 **2,000 万张图像**，约 20,000 条轨迹（每条 1,000 帧，640×480）。渲染器 ViSim 模拟了真实相机与 IMU，并支持光照变化、移动物体、运动模糊等。提供 RGB、深度、表面法线、语义 / 实例分割（含 NYU40 映射）、2D 包围盒、IMU、相机位姿，以及鱼眼、全景、事件相机等变体。

## 下载 (Download)

**没有公开的下载链接**，流程如下：

1. 填写使用条款表单：<https://docs.google.com/forms/d/15sjV-CAud1ENBxK-hJSSrweE7IGc8VXWDbgZiq1trGc>
2. 维护者收到表单后会通过邮件发送完整图像数据集的链接；问题或请求请联系 interiornetdataset@gmail.com。
3. 家具模型、布局与场景资产的权利归 Kujiale.com 所有，如需使用或下载这些资产，请联系 Dr. Rui Tang（ati@qunhemail.com）。

拿到链接后，把它们按每行一个保存到文本文件（`#` 开头的行会被忽略），然后：

```bash
# 普通 HTTP(S) 链接用 wget -c 断点续传；Google Drive 链接用 gdown（pip install gdown）
./download_interiornet.sh -l interiornet_links.txt -o /path/to/InteriorNet -x
```

## 数据结构 (Dataset Overview)

以下根据官方格式文档整理。每条轨迹（序列）包含：

```
<sequence>/
├── rgb/                   # 0.png, 1.png, ...  (640x480)
├── mesh/                  # 0.png ...  16-bit 逐像素标签索引（对应 cocolabel.json 中的 label_id）
├── cocolabel.json         # COCO 风格标注：images / maskimages / categories / annotations(2D bbox)
├── cocolabel_NYUv2.json   # 同上，类别映射到 NYU40
├── cam0.info              # 相机内参
├── cam0.ccam              # 每帧内外参（ViSim 相机格式）
├── cam0_gt.visim          # 带时间戳的位姿真值
└── cam0.renderer          # 渲染参数（eye / lookat / up / framerate / shutter_speed）
```

`cam0.info` 示例（坐标系为右手系，Y 轴朝上）：

```
#Image Res.(w,h):
640 480
#focus lens:
600 600
#principal pt:
320 240
#Undist. coeff. :
0 0 0
#Coordinate Sys.:
RH_Y_UP
```

`cam0.ccam` 每行：`f cx cy dist0 dist1 dist2  qw qx qy qz  px py pz  width height`。

## 许可 (License)

官网没有给出具体许可名称：下载需同意表单中的使用条款，资产权利归 Kujiale.com 所有。

## 引用

论文：[interiornet_paper.pdf](https://interiornet.org/items/interiornet_paper.pdf)

```bibtex
@inproceedings{InteriorNet18,
  author    = {Wenbin Li and Sajad Saeedi and John McCormac and Ronald Clark and
               Dimos Tzoumanikas and Qing Ye and Yuzhong Huang and Rui Tang and
               Stefan Leutenegger},
  booktitle = {British Machine Vision Conference (BMVC)},
  title     = {InteriorNet: Mega-scale Multi-sensor Photo-realistic Indoor Scenes Dataset},
  year      = {2018}
}
```
