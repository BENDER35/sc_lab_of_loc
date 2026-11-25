#!/usr/bin/env python3
"""Generate a markdown lab report from a template and analysis output directory."""
from __future__ import annotations
import argparse, datetime as dt, hashlib, pathlib

def sha256(path: pathlib.Path) -> str:
    h = hashlib.sha256()
    with path.open('rb') as f:
        for chunk in iter(lambda: f.read(65536), b''):
            h.update(chunk)
    return h.hexdigest()

def main() -> int:
    ap = argparse.ArgumentParser(description="Generate defensive lab report")
    ap.add_argument('--sample', required=True)
    ap.add_argument('--analysis-dir', required=True)
    ap.add_argument('--template', default='templates/reports/lab-report-template.md')
    ap.add_argument('--out', required=True)
    args = ap.parse_args()

    sample = pathlib.Path(args.sample)
    analysis = pathlib.Path(args.analysis_dir)
    tpl = pathlib.Path(args.template).read_text(encoding='utf-8')
    report = tpl
    report = report.replace('**Date:**', f"**Date:** {dt.date.today().isoformat()}", 1)
    report = report.replace('**Sample ID/hash:** (SHA256)', f"**Sample ID/hash:** {sha256(sample) if sample.exists() else 'N/A'}", 1)

    sections = []
    for name in ['oleid.txt','olevba.txt','mraptor.txt','yara.txt']:
        p = analysis / name
        if p.exists():
            content = p.read_text(encoding='utf-8', errors='replace').strip()
            content = content[:4000]
            sections.append(f"## {name}\n\n```\n{content}\n```")
    if sections:
        report += "\n\n" + "\n\n".join(sections) + "\n"

    out = pathlib.Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(report, encoding='utf-8')
    print(f"Wrote {out}")
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
