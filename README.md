# SC Lab of LOC — Local Cybersecurity Lab (Defensive)

> **Educational / defensive only.** This repository helps you build an **isolated local cybersecurity lab** to learn safely: network isolation, Office hardening, macro analysis, and detection. It does **not** contain malware, backdoors, remote-access tooling, or instructions for unauthorized access.

## What this project is

A starter kit for learning cybersecurity in your own local network **without touching third-party systems**:

- **Isolated lab**: VirtualBox internal/host-only networks so lab traffic never reaches the Internet or your real LAN.
- **Defensive Office focus**: hardening guidance for Microsoft Office macros (Protected View, MOTW, ASR rules, AMSI/ETW concepts).
- **Safe analysis**: inspect suspicious Office documents with static analysis tools (`oletools`) inside an isolated VM.
- **Detection**: example Sigma and YARA rules for learning detection engineering.
- **Bilingual+ guides**: Spanish, English, and Asturian/Bable.

## Repository layout

```text
.
├── README.md
├── LICENSE
├── docker/
│   ├── docker-compose.yml          # isolated internal-network analysis container
│   ├── README.md
│   └── analysis/Dockerfile
├── docs/
│   ├── GUIDE.es.md
│   ├── GUIDE.en.md
│   ├── GUIDE.ast.md
│   ├── ETHICS_AND_SAFETY.md
│   ├── MIRROR_SETUP.md
│   └── LAB_CHECKLIST.md
├── lab/
│   └── profiles/virtualbox-profile.md
├── scripts/
│   ├── create_isolated_lab.sh
│   ├── check_lab_isolation.sh
│   ├── analysis/
│   │   ├── analyze_sample.sh
│   │   └── generate_report.py
│   └── windows/
│       ├── office_hardening.ps1
│       ├── collect_office_audit.ps1
│       └── install_sysmon_lab.ps1
├── detection/
│   ├── sigma/                      # suspicious child process, macro policy drift, office network, ASR
│   ├── yara/                       # macro/OLE indicator rules
│   └── sysmon/sysmon-office.xml
├── templates/reports/lab-report-template.md
├── samples/                        # local-only, gitignored
├── reports/                        # local-only, gitignored
└── .github/workflows/
    ├── validate.yml
    ├── mirror-gitlab.yml
    └── release.yml
```

## Quick start

### 1) Prerequisites

- Linux host with VirtualBox (`VBoxManage`).
- At least 16 GB RAM recommended for two VMs.
- Windows evaluation VM **you own/control** and a Linux VM (e.g., REMnux/Ubuntu) for analysis.
- No bridged adapter for lab VMs unless you explicitly know why.

### 2) Create an isolated VirtualBox network

```bash
./scripts/create_isolated_lab.sh --name sc-lab --network 192.168.56.0/24
./scripts/check_lab_isolation.sh --vm "SC-Windows" --vm "SC-Linux"
```

The script creates/uses a host-only or internal network profile and prints VM attachment commands. **Do not attach lab VMs to bridged/NAT if you want strict isolation.**

### 3) Harden Office (inside your Windows lab VM)

Run PowerShell as Administrator in the Windows VM:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\windows\office_hardening.ps1 -AuditOnly
# After reviewing output:
.\scripts\windows\office_hardening.ps1
```

### 4) Analyze macros safely (Docker, isolated)

Only analyze samples you own or have explicit permission to test. The Docker profile uses an **internal** network (no external connectivity), read-only rootfs, and dropped capabilities.

```bash
mkdir -p samples reports
cp /path/to/authorized.docm samples/
./scripts/analysis/analyze_sample.sh --file samples/authorized.docm
python3 scripts/analysis/generate_report.py \
  --sample samples/authorized.docm \
  --analysis-dir reports/authorized \
  --out reports/authorized-report.md
```

Do **not** execute unknown macros. Do analysis in an isolated VM snapshot.

## Guides

- [Español](docs/GUIDE.es.md)
- [English](docs/GUIDE.en.md)
- [Asturianu / Bable](docs/GUIDE.ast.md)
- [Ethics and safety](docs/ETHICS_AND_SAFETY.md)

## Mirror (GitHub <-> GitLab)

This repo is designed to be mirrored between GitHub and GitLab.

- GitHub Actions workflow: `.github/workflows/mirror-gitlab.yml` pushes to GitLab.
- GitLab CI config: `.gitlab-ci.yml` pushes to GitHub.
- Both workflows include loop guards to avoid mirror ping-pong.

Required secrets/variables:

| Platform | Name | Value |
|---|---|---|
| GitHub secret | `GITLAB_MIRROR_TOKEN` | GitLab Personal/Project Access Token with write_repository |
| GitHub variable | `GITLAB_MIRROR_URL` | `https://oauth2:<token>@gitlab.com/<group>/<repo>.git` or use token in workflow; recommended as secret URL |
| GitLab CI variable | `GITHUB_MIRROR_URL` | `https://<user>:<token>@github.com/<owner>/<repo>.git` (masked/protected) |

See workflow files for exact names.

## Release

Releases are created from Git tags (`v*`). The release workflow packages the repository into a ZIP (excluding `.git` and build artifacts) and publishes it as a GitHub Release asset.

## Legal / Ethics

Use this project only on systems and networks you own or have explicit written permission to test. Unauthorized access to computer systems is illegal. This repository is for defensive education in isolated labs.
