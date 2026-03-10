# Security Policy

## Supported Versions

GHT follows a rolling release model. We recommend using the latest version of the toolkit from the **`main` branch**.

> [!IMPORTANT]
> The latest security patches are **exclusively** deployed to the `main` branch. Any other branch (e.g., development or feature branches) is not expected to contain the latest security updates.

## Security Best Practices

To ensure the secure operation of the GCP Hardening Toolkit, we recommend the following:

### 1. Hash Pinning (Supply Chain Security)
We strongly recommend pinning modules to a specific commit hash for production environments. This prevents unintended updates and protects against potential supply chain compromises.

```hcl
module "gcp_hardening" {
  source = "github.com/GoogleCloudPlatform/gcp-hardening-toolkit//modules/gcp-org-policies?ref=<COMMIT_HASH>"
}
```

### 2. Secret Management
Never commit credentials, API keys, or service account JSON keys to this repository. This project includes `pre-commit` hooks and `detect-secrets` logic. We recommend installing these hooks locally to prevent accidental leaks:

```bash
pip install pre-commit detect-secrets
pre-commit install
```

### 3. Least Privilege
Run the toolkit using a service account with the **minimum required IAM permissions** for the specific blueprint or module you are deploying. Avoid using `Owner` or `Editor` roles at the Organization level if a more granular role can be used.

### 4. Non-Production Testing
Always test the toolkit in a non-production or "sandbox" environment before applying changes to business-critical infrastructure.

## Reporting a Vulnerability

**Do not report security vulnerabilities via public GitHub issues.**

We use GitHub's Private Vulnerability Reporting to handle security issues securely and privately.

To report a vulnerability:
1. Go to the **Security** tab of this repository.
2. Select **Advisories** on the left sidebar.
3. Click **Report a vulnerability**.
4. Provide a clear description, reproduction steps, and potential impact.

Our operational team will triage the report and respond with an estimated timeline for remediation. Please allow us time to patch the issue before publicly disclosing it.
