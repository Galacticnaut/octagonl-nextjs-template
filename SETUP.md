# Setup Guide

## Prerequisites

- Node.js 20+, npm, Azure CLI, GitHub CLI
- Access to the Octagonl platform

## Step 1: Update App Name

Search and replace `APPNAME` in:
- `.github/workflows/deploy-dev.yml` — `APP_SERVICE` and `RESOURCE_GROUP`
- `.github/workflows/deploy-prod.yml` — `APP_SERVICE` and `RESOURCE_GROUP`

## Step 2: Request App Registration

Contact the Platform Team with:
1. App name (e.g., `octagonl-vibedeck-dev`)
2. Redirect URIs: `https://<app>.octago.nl/api/auth/callback/azure-ad`, `http://localhost:3000/api/auth/callback/azure-ad`

You'll receive: `OIDC_ISSUER`, `OIDC_CLIENT_ID`, `OIDC_CLIENT_SECRET`

## Step 3: Local Environment

```bash
cp .env.example .env.local
# Fill in OIDC values from Step 2
# Generate NEXTAUTH_SECRET: openssl rand -base64 32
npm install && npm run dev
```

## Step 4: GitHub Environments

Create two environments in repository settings:

### `app-azure-dev`
| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | OIDC service principal client ID |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |
| `PLATFORM_API_BASE_URL` | Dev API URL |
| `NEXTAUTH_URL` | `https://<app>-dev.octago.nl` |
| `NEXTAUTH_SECRET` | Generated secret |
| `OIDC_ISSUER` | Entra issuer URL |
| `OIDC_CLIENT_ID` | App registration client ID |
| `OIDC_CLIENT_SECRET` | From Azure Key Vault |

### `app-azure-prod`
Same secrets with production values. Enable required reviewers.

## Step 5: Deploy Infrastructure

```bash
az group create --name rg-octagonl-APPNAME-dev --location westeurope
az deployment group create -g rg-octagonl-APPNAME-dev -f infra/main.bicep -p appName=APPNAME postgresAdminPassword=<pw>
```

## Step 6: First Deployment

```bash
git push origin main  # Triggers deploy-dev workflow
```

## Checklist
- [ ] App builds locally
- [ ] Auth redirect works
- [ ] CI passes on PR
- [ ] Infrastructure deploys
- [ ] App accessible at custom domain
