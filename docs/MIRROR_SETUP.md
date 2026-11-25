# Mirror Setup (GitHub <-> GitLab)

This project includes two workflows for bidirectional mirroring:

- **GitHub -> GitLab**: `.github/workflows/mirror-gitlab.yml`
- **GitLab -> GitHub**: `.gitlab-ci.yml`

## 1) GitHub -> GitLab

Create a GitLab token with `write_repository` scope for the target project.

In GitHub repo settings, add secret:

- `GITLAB_MIRROR_URL`: `https://oauth2:<GITLAB_TOKEN>@gitlab.com/<group>/<repo>.git`

> Store the full authenticated URL as a secret; do not commit tokens.

## 2) GitLab -> GitHub

Create a GitHub fine-grained/classic token with repo write access to the target repo.

In GitLab CI/CD variables (masked, protected as appropriate), add:

- `GITHUB_MIRROR_URL`: `https://<github_user>:<GITHUB_TOKEN>@github.com/<owner>/<repo>.git`

## 3) Loop guard

- GitHub workflow skips actor `gitlab-mirror-bot` (adjust if you use a different bot account).
- GitLab job skips commits whose message contains `[skip-mirror]`.

For robust operation, use a dedicated bot account on each side and ensure its pushes are identifiable by the guard condition.

## 4) Verification

1. Push a commit to GitHub main -> confirm it appears on GitLab.
2. Push a commit to GitLab main -> confirm it appears on GitHub.
3. Confirm no infinite pipeline loop (check workflow/job runs).
4. Tag a release on GitHub (`v0.1.0`) and confirm tag mirrors.

## 5) Troubleshooting

- **403/401**: token scope/expiry or wrong URL.
- **Protected branch**: allow bot/token to push.
- **Looping**: tighten actor/message guards and use dedicated bot users.
