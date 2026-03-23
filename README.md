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

Simply edit the `packages.txt` file and append the names of the packages you want to install, one per line. Comments starting with `#` are also supported:

```text
# Your comment here
your_new_package_name
```
