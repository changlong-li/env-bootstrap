# env-bootstrap

A one-liner setup script that installs all the packages I need every time I start a new project.

## Quick Start

```bash
git clone https://github.com/<your-username>/env-bootstrap.git
cd env-bootstrap
bash setup.sh
```

## Package List

| Package | Purpose |
|---------|---------|
| `huggingface-hub` | Download / upload models and datasets from Hugging Face Hub |

## Adding a New Package

Edit `setup.sh` and append a line below the `── 在此处继续添加新的包 ──` comment:

```bash
pip install -U <package> && info "<package> installed" || error "<package> failed"
```
