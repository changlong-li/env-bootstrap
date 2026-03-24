# env-bootstrap

A one-liner setup script that installs all the packages I need every time I start a new project.

## Quick Start

```bash
git clone https://github.com/<your-username>/env-bootstrap.git
cd env-bootstrap
bash python/setup_python.sh
```

## Repository Structure

- `python/setup_python.sh`: install project-level Python packages
- `python/packages.txt`: Python package list
- `system/setup_system.sh`: install system packages with online/offline modes
- `system/packages.txt`: system package list
- `system/prepare_offline_bundle.sh`: prepare offline bundle on a connected local machine
- `system/upload_offline_bundle.sh`: upload offline bundle to remote server
- `system/upload_config.example`: upload config template

## Package List

- Python: `huggingface_hub`, `hf_transfer`
- System: `git-lfs`, `tmux`

## Python Packages (Frequent)

```bash
bash python/setup_python.sh
```

## System Packages (Infrequent)

Online mode (server can access GitHub):

```bash
bash system/setup_system.sh
```

Offline mode (server cannot access GitHub):

1) Prepare offline bundle on local machine with internet

```bash
bash system/prepare_offline_bundle.sh
```

2) Create upload config (keep personal values local)

```bash
cp system/upload_config.example system/upload_config.local
```

Edit `system/upload_config.local` and fill at least `SSH_HOST_ALIAS` or `REMOTE_HOST`, and `REMOTE_DIR`.

3) Upload bundle to server

```bash
bash system/upload_offline_bundle.sh
```

4) Run offline installation on server

```bash
bash system/setup_system.sh --offline-bundle /path/to/offline_bundle --brew-prefix $HOME/.linuxbrew
```

## Adding New Packages

Python packages: edit `python/packages.txt`  
System packages: edit `system/packages.txt`

```text
your_new_package_name
```
