FROM python:3.12-slim

LABEL org.opencontainers.image.title="sc-lab-of-loc analyzer"
LABEL org.opencontainers.image.description="Defensive static analysis container for authorized lab use only"

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PYTHONDONTWRITEBYTECODE=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    file \
    yara \
    unzip \
    p7zip-full \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --upgrade pip && \
    pip install oletools==0.60.2 yara-python==4.5.4

RUN useradd -m -u 10001 analyst
USER analyst
WORKDIR /workspace

ENTRYPOINT ["/bin/bash", "-lc"]
CMD ["sleep infinity"]
