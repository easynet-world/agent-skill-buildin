# agent-skill-buildin

Built-in skill bundle for Easynet agents. This project packages `skills/` into a signed, versioned artifact and publishes it to GitHub Container Registry (GHCR).

## Structure

- `skills/`: source skill directories (`SKILL.md`, `scripts/`, `references/`, assets)
  - `skills/company-report/`: bundled from the `agent-runtime2/example` company-report workflow
- `scripts/package-skills.sh`: packages and signs `skills/` into `dist/skills.tgz`
- `.github/workflows/release-ghcr.yml`: publishes OCI artifact to GHCR

## Local build

`build` requires a PEM private key:

```bash
SIGNING_KEY_PATH=/path/to/private.pem npm run build
```

Outputs:

- `dist/skills.tgz`
- `dist/skills.tgz.sig`
- `dist/skills.tgz.sha256`

## Generate signing key (OpenSSL)

```bash
openssl genpkey -algorithm RSA -out private.pem -pkeyopt rsa_keygen_bits:4096
openssl rsa -in private.pem -pubout -out public.pem
```

## Verify signature

```bash
openssl dgst -sha256 -verify public.pem -signature dist/skills.tgz.sig dist/skills.tgz
```

## Release to GHCR

Push a tag like `v0.1.0`:

```bash
git tag v0.1.0
git push origin v0.1.0
```

Workflow publishes:

- `ghcr.io/<owner>/agent-skill-buildin:v0.1.0`
- `ghcr.io/<owner>/agent-skill-buildin:sha-<commit>`

Published files inside OCI artifact:

- `skills.tgz`
- `skills.tgz.sig`
- `skills.tgz.sha256`

OCI media type:

- `application/vnd.easynet.agent-skills.layer.v1.tar+gzip`

## Pull example

```bash
oras pull ghcr.io/<owner>/agent-skill-buildin:v0.1.0
tar -xzf skills.tgz
```

This downloads a signed skill bundle; unpacked content is the runtime `skills/` directory.
