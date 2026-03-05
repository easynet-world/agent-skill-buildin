# agent-skill-buildin

Built-in skill bundle for Easynet agents. This project packages `skills/` into a versioned OCI artifact and publishes it to GitHub Container Registry (GHCR).

## Structure

- `skills/`: source skill directories (`SKILL.md`, `scripts/`, `references/`, assets)
- `scripts/package-skills.sh`: packages `skills/` into `dist/skills.tgz`
- `.github/workflows/release-ghcr.yml`: publishes OCI artifact to GHCR

## Local build

```bash
npm run build
```

Outputs:

- `dist/skills.tgz`
- `dist/skills.tgz.sha256`

## Release to GHCR

Push a tag like `v0.1.0`:

```bash
git tag v0.1.0
git push origin v0.1.0
```

Workflow publishes:

- `ghcr.io/<owner>/agent-skill-buildin:v0.1.0`
- `ghcr.io/<owner>/agent-skill-buildin:sha-<commit>`

OCI media type:

- `application/vnd.easynet.agent-skills.layer.v1.tar+gzip`

## Pull example

```bash
oras pull ghcr.io/<owner>/agent-skill-buildin:v0.1.0
```

This downloads `skills.tgz`; unpack to a runtime skill directory.
