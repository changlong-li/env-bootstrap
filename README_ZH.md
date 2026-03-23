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

直接编辑 `packages.txt` 文件，将需要安装的包名换行追加到文件中即可。支持添加注释（以 `#` 开头）：

```text
# 这里写注释
your_new_package_name
```
