# Docker Analysis Profile (Defensive)

This profile provides an **isolated static-analysis container** for authorized lab samples.

## Safety properties

- `internal: true` network: no external connectivity.
- `read_only` root filesystem, `tmpfs` for `/tmp`.
- `no-new-privileges`, all Linux capabilities dropped.
- `samples/` mounted read-only; `reports/` mounted read-write.

## Usage

```bash
mkdir -p samples reports
docker compose -f docker/docker-compose.yml build
docker compose -f docker/docker-compose.yml up -d
docker compose -f docker/docker-compose.yml exec analyzer "oleid /workspace/samples/file.docm"
docker compose -f docker/docker-compose.yml exec analyzer "olevba --decode /workspace/samples/file.docm > /workspace/reports/olevba.txt"
docker compose -f docker/docker-compose.yml exec analyzer "yara -r /workspace/detection/yara /workspace/samples"
docker compose -f docker/docker-compose.yml down
```

Only analyze files you own or have explicit permission to test.
