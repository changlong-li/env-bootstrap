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
bash system/prepare_offline_bundle.sh /tmp/offline_bundle
```

2) Upload bundle to server

```bash
scp -r /tmp/offline_bundle <user>@<host>:/path/to/offline_bundle
```

3) Run offline installation on server

```bash
bash system/setup_system.sh --offline-bundle /path/to/offline_bundle --brew-prefix $HOME/.linuxbrew
```

## Adding New Packages

Python packages: edit `python/packages.txt`  
System packages: edit `system/packages.txt`

```text
your_new_package_name
```
