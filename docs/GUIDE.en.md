# Learning Guide (English)

## Goal

Learn defensive cybersecurity in an **isolated local network**, focusing on the Office document (macro) vector from the perspective of prevention, static analysis, and detection.

> **Important**: Do not use these techniques outside your lab. Do not access other people's systems without written authorization.

## 1. Lab design

### Recommended topology

- **Host**: your physical machine (Linux).
- **Windows VM**: test machine with Office (legitimate license/evaluation).
- **Linux analysis VM**: REMnux/Ubuntu with `oletools`, YARA, Sigma tools.
- **Network**: VirtualBox `Internal Network` or `Host-only`. No bridged adapter.

### Isolation rules

- No NAT/Bridged adapters on lab VMs during analysis exercises.
- Take snapshots before each exercise.
- Do not share host folders with unnecessary write permissions.
- Do not paste real credentials into the lab.

## 2. VirtualBox setup

```bash
# On the Linux host
./scripts/create_isolated_lab.sh --name sc-lab --network 192.168.56.0/24
```

Attach each VM to **a single** Host-only/Internal adapter connected to the lab network. Verify:

```bash
./scripts/check_lab_isolation.sh --vm "SC-Windows" --vm "SC-Linux"
```

Manual checks inside VMs:

- The IP must belong to the lab range.
- There should be no Internet route (or `ping 1.1.1.1` should fail if there is no NAT).
- Only lab VMs should be reachable.

## 3. Microsoft Office hardening (defensive)

The goal is to **reduce the attack surface** of macros and active content.

### Key controls

- **Macros**: disable macros except those signed by trusted publishers; block macros from the Internet (MOTW).
- **Protected View**: enable for files from the Internet, unsafe locations, and Outlook attachments.
- **ASR rules (Defender)**: block child process creation from Office, injection, executable content from email.
- **AMSI/ETW**: keep enabled for visibility and detection.
- **Updates**: keep Office and Windows up to date.

### Audit/hardening script

In the Windows VM, as Administrator:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\scripts\windows\office_hardening.ps1 -AuditOnly
.\scripts\windows\office_hardening.ps1
```

Review changes before applying them to real machines; in a lab you can apply them directly.

## 4. Safe static macro analysis

Never execute a suspicious document to "see what it does". Start with static analysis.

### Tools

- `oleid`: identifies risky characteristics.
- `olevba`: extracts and analyzes VBA macros.
- `mraptor`: detects suspicious macro behavior.

### Workflow

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install oletools

oleid document.docm
olevba --decode document.docm
mraptor document.docm
```

Work on a **copy** in a VM snapshot. If the document is not yours or you lack permission, do not analyze it outside an authorized environment.

## 5. Detection

`detection/` contains example rules:

- **Sigma**: suspicious child process launched by Office.
- **YARA**: typical suspicious macro keywords (educational example).

These rules are starting points; tune them to your telemetry and reduce false positives.

## 6. Suggested exercise

1. Create a **harmless** test document with a macro that only shows a `MsgBox`.
2. Analyze it with `olevba` and observe indicators.
3. Apply hardening and verify the macro is blocked by policy.
4. Review events/logs and compare with the Sigma rule.

## 7. What to learn next

- Networking: TCP/IP, DNS, HTTP, TLS.
- Windows internals and Sysmon.
- Linux, Bash, Python.
- MITRE ATT&CK (tactics/techniques) from the defensive side.
- Legal CTFs: TryHackMe, Hack The Box Academy, OverTheWire.
