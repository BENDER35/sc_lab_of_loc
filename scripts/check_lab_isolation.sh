#!/usr/bin/env bash
set -euo pipefail

# Checks basic VirtualBox VM network attachment for obvious isolation mistakes.
# This is a helper, not a full security guarantee.

usage() {
  cat <<'USAGE'
Usage: ./scripts/check_lab_isolation.sh --vm "VM Name" [--vm "Other VM"]

Checks:
  - warns if any NIC is bridged or NAT
  - reports host-only/internal adapters

Exit code:
  0 if no bridged/NAT adapters found on provided VMs
  2 if risky adapters found
  1 on usage/error
USAGE
}

VMS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --vm) VMS+=("${2:-}"); shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ ${#VMS[@]} -eq 0 ]]; then
  usage
  exit 1
fi
if ! command -v VBoxManage >/dev/null 2>&1; then
  echo "VBoxManage not found." >&2
  exit 1
fi

risky=0
for vm in "${VMS[@]}"; do
  echo "== VM: $vm =="
  if ! info=$(VBoxManage showvminfo "$vm" --machinereadable 2>&1); then
    echo "  ERROR: cannot read VM info" >&2
    echo "$info" >&2
    risky=1
    continue
  fi
  found=0
  while IFS='=' read -r key val; do
    if [[ "$key" =~ ^nic([0-9]+)$ ]]; then
      idx="${BASH_REMATCH[1]}"
      val="${val//\"/}"
      [[ "$val" == "none" ]] && continue
      found=1
      echo "  NIC$idx: $val"
      case "$val" in
        bridged|nat|natnetwork)
          echo "  WARNING: NIC$idx uses $val - risky for strict isolation"
          risky=1
          ;;
        hostonly|intnet)
          echo "  OK: NIC$idx appears isolated ($val)"
          ;;
        *)
          echo "  NOTE: review NIC$idx type manually"
          ;;
      esac
    fi
  done <<< "$info"
  if [[ $found -eq 0 ]]; then
    echo "  NOTE: no enabled NICs found"
  fi
done

if [[ $risky -eq 0 ]]; then
  printf '\n[PASS] No bridged/NAT adapters detected on selected VMs.\n'
  exit 0
fi

printf '\n[WARN] Risky adapter configuration detected. Review before running lab exercises.\n' >&2
exit 2
