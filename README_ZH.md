# env-bootstrap

新项目环境一键初始化脚本，维护一份"每次开新项目都要装"的常用包清单。

## 快速使用

```bash
git clone https://github.com/<your-username>/env-bootstrap.git
cd env-bootstrap
bash setup.sh
```

## 当前包清单

| 包名 | 用途 |
|------|------|
| `huggingface-hub` | 从 Hugging Face Hub 下载/上传模型与数据集 |

## 添加新包

编辑 `setup.sh`，在注释 `── 在此处继续添加新的包 ──` 下方追加一行即可：

```bash
pip install -U <package> && info "<package> 安装成功" || error "<package> 安装失败"
```
