# VirtualBox Lab Profile

## VMs

| VM | OS | Role | Network |
|---|---|---|---|
| SC-Windows | Windows 10/11 Eval | Office test target, Sysmon, Defender | Host-only/Internal only |
| SC-Analysis | Ubuntu/REMnux | oletools, YARA, Sigma, logs | Host-only/Internal only |

## Suggested resources

- Windows: 4 vCPU, 8 GB RAM, 80 GB disk
- Analysis: 2 vCPU, 4 GB RAM, 40 GB disk

## Snapshot points

1. `clean-install` - OS installed, no exercises.
2. `hardened` - Office hardening applied.
3. `pre-exercise` - before each sample/analysis.

## Network policy

- No bridged adapter.
- No NAT during suspicious sample analysis.
- Disable shared clipboard/drag-drop for untrusted samples.
- Keep host shared folders read-only or disabled.
