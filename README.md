# Octagonl Next.js Template

Production-ready Next.js template for Octagonl platform apps. Includes SSO via Microsoft Entra External ID, Azure deployment, Bicep infrastructure, and Copilot instructions.

## Features

- **SSO Authentication** — Pre-configured `next-auth` with Octagonl's centralized Entra External ID
- **Platform API Client** — Ready-to-use client for tenants, memberships, and user management
- **Azure Deployment** — CI/CD via GitHub Actions with OIDC federation (no long-lived secrets)
- **Bicep Infrastructure** — App Service, Key Vault, monitoring, optional PostgreSQL
- **Copilot Instructions** — AI assistant configured with Octagonl conventions
- **Brand Tokens** — Tailwind CSS with Octagonl's retro-futuristic color palette
- **DevContainer** — Ready for GitHub Codespaces

## Quick Start

1. Click **"Use this template"** on GitHub
2. Clone with submodules: `git clone --recurse-submodules <your-repo-url>`
3. `cp .env.example .env.local` and fill in your OIDC values
4. `npm install && npm run dev`

See [SETUP.md](SETUP.md) for complete post-creation setup.

## Project Structure

```
.github/             # CI/CD workflows, Copilot instructions, Dependabot
.devcontainer/       # Dev container config
docs/                # Platform docs (git submodule)
infra/               # Bicep IaC modules
shared/              # Brand tokens
src/app/             # Next.js App Router
src/components/      # Auth guard, providers
src/lib/             # Auth config, Platform API client
src/types/           # TypeScript type extensions
```

## Authentication

Users sign in at `login.octago.nl` via OIDC. The `oid` claim (not `sub`) is the stable user identifier across all Octagonl apps.

Key files: `src/lib/auth.ts`, `src/components/auth-guard.tsx`

## Platform Docs

Available in the git submodule. Update with: `git submodule update --remote`

## License

Private — Octagonl platform internal use.
