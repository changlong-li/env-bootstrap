# env-bootstrap

新项目环境一键初始化脚本，维护一份"每次开新项目都要装"的常用包清单。

## 快速使用

```bash
git clone https://github.com/<your-username>/env-bootstrap.git
cd env-bootstrap
bash python/setup_python.sh
```

## 仓库结构

- `python/setup_python.sh`：安装项目级 Python 包
- `python/packages.txt`：Python 包清单
- `system/setup_system.sh`：安装系统级包（在线/离线双模式）
- `system/packages.txt`：系统包清单
- `system/prepare_offline_bundle.sh`：在联网本地机准备离线安装包

## 当前包清单

- Python 包：`huggingface_hub`、`hf_transfer`
- 系统包：`git-lfs`、`tmux`

## Python 包安装（高频）

```bash
bash python/setup_python.sh
```

## 系统包安装（低频）

在线模式（服务器可访问 GitHub）：

```bash
bash system/setup_system.sh
```

离线模式（服务器不可访问 GitHub）：

1) 在本地联网机器准备离线包

```bash
bash system/prepare_offline_bundle.sh /tmp/offline_bundle
```

2) 上传到服务器指定目录

```bash
scp -r /tmp/offline_bundle <user>@<host>:/path/to/offline_bundle
```

3) 在服务器执行离线安装

```bash
bash system/setup_system.sh --offline-bundle /path/to/offline_bundle --brew-prefix $HOME/.linuxbrew
```

## 添加新包

Python 包：编辑 `python/packages.txt`，每行一个包名  
系统包：编辑 `system/packages.txt`，每行一个包名

```text
your_new_package_name
```
