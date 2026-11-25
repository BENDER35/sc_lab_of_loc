#!/usr/bin/env bash
set -euo pipefail

# Creates/validates a VirtualBox host-only network for an isolated local lab.
# Defensive/educational use only.

usage() {
  cat <<'USAGE'
Usage: ./scripts/create_isolated_lab.sh --name <lab-name> --network <ipv4-cidr>

Options:
  --name      Lab name label (used for output only)
  --network   Host-only IPv4 network in CIDR form, e.g. 192.168.56.0/24
  -h, --help  Show this help

Notes:
  - This script configures a VirtualBox host-only interface.
  - Attach lab VMs to this host-only network only. Do NOT use bridged adapters.
  - For strict Internet isolation, do not add NAT adapters to lab VMs.
USAGE
}

NAME=""
NETWORK=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --name) NAME="${2:-}"; shift 2 ;;
    --network) NETWORK="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -z "$NAME" || -z "$NETWORK" ]]; then
  echo "Missing --name or --network" >&2
  usage
  exit 1
fi

if ! command -v VBoxManage >/dev/null 2>&1; then
  echo "VBoxManage not found. Install VirtualBox first." >&2
  exit 1
fi

if [[ ! "$NETWORK" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}/24$ ]]; then
  echo "Only /24 IPv4 CIDR is supported by this simple helper (e.g. 192.168.56.0/24)." >&2
  exit 1
fi

IFS='./' read -r o1 o2 o3 o4 _mask <<<"$NETWORK"
for octet in "$o1" "$o2" "$o3" "$o4"; do
  if ((octet < 0 || octet > 255)); then
    echo "Invalid IPv4 network: $NETWORK" >&2
    exit 1
  fi
done

HOST_IP="$o1.$o2.$o3.1"
NETMASK="255.255.255.0"
LOWER="$o1.$o2.$o3.100"
UPPER="$o1.$o2.$o3.200"

echo "[+] Lab: $NAME"
echo "[+] Host-only network: $NETWORK (host IP $HOST_IP)"

# Find existing hostonlyif matching the host IP
EXISTING_IF=""
while IFS= read -r line; do
  if [[ "$line" =~ ^Name:[[:space:]]+(.*)$ ]]; then
    current_if="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ ^IPAddress:[[:space:]]+(.*)$ ]]; then
    current_ip="${BASH_REMATCH[1]}"
    if [[ "$current_ip" == "$HOST_IP" ]]; then
      EXISTING_IF="$current_if"
    fi
  fi
done < <(VBoxManage list hostonlyifs)

if [[ -z "$EXISTING_IF" ]]; then
  echo "[+] Creating host-only interface..."
  CREATE_OUT=$(VBoxManage hostonlyif create)
  EXISTING_IF=$(echo "$CREATE_OUT" | sed -n "s/.*Interface '\([^']*\)'.*/\1/p")
  if [[ -z "$EXISTING_IF" ]]; then
    echo "Could not determine created host-only interface name" >&2
    echo "$CREATE_OUT" >&2
    exit 1
  fi
fi

echo "[+] Using host-only interface: $EXISTING_IF"
VBoxManage hostonlyif ipconfig "$EXISTING_IF" --ip "$HOST_IP" --netmask "$NETMASK"

# Configure DHCP server for convenience; VMs can also use static IPs.
if VBoxManage list dhcpservers | grep -q "NetworkName:.*HostInterfaceNetworking-$EXISTING_IF"; then
  VBoxManage dhcpserver modify --interface "$EXISTING_IF" --ip "$HOST_IP" --netmask "$NETMASK" --lowerip "$LOWER" --upperip "$UPPER" --enable || true
else
  VBoxManage dhcpserver add --interface "$EXISTING_IF" --ip "$HOST_IP" --netmask "$NETMASK" --lowerip "$LOWER" --upperip "$UPPER" --enable || true
fi

cat <<EOF

[OK] Host-only lab network ready.
Interface: $EXISTING_IF
Host IP:   $HOST_IP
DHCP:      $LOWER - $UPPER

Attach a VM (powered off):
  VBoxManage modifyvm "VM_NAME" --nic1 hostonly --hostonlyadapter1 "$EXISTING_IF"

Isolation checklist:
  - Use only host-only/internal adapters for lab exercises.
  - Do NOT attach bridged adapter.
  - Prefer no NAT adapter during suspicious sample analysis.
  - Take a VM snapshot before exercises.
EOF
