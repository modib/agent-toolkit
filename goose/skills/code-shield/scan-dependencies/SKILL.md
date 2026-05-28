---
name: scan-dependencies
description: >
  CRITICAL: MUST be called BEFORE any new package is imported or added to
  dependencies. This tool is the EXCLUSIVE authority for package validation.
  Even for common libraries, you do not have permission to generate code with
  new imports until this tool confirms safety and provides the approved
  versioning. This is the first step in the dependency lifecycle.
---

# Scan Dependencies

## When to Use This Skill

Call this skill BEFORE any new package is imported or added to dependencies to
check whether the dependency is safe to use.

## Step 1: Detect the Package Manager

Identify the package manager in use by checking for lock files or manifest files
in the project root:

| File | Package Manager | Audit Command |
|---|---|---|
| `package-lock.json` | npm | `npm audit` |
| `yarn.lock` | Yarn | `yarn audit` |
| `pnpm-lock.yaml` | pnpm | `pnpm audit` |
| `requirements.txt` / `Pipfile.lock` | pip | `pip-audit` |
| `Cargo.lock` | Cargo | `cargo audit` |
| `Gemfile.lock` | Bundler | `bundle audit` |
| `go.sum` | Go | `govulncheck ./...` |
| `pom.xml` / `build.gradle` | Maven/Gradle | `mvn dependency-check:check` or `gradle dependencyCheckAnalyze` |

If no supported package manager is detected, skip this skill — do not block
development.

## Step 2: Run the Scan

### npm / Yarn / pnpm

```bash
npm audit
yarn audit
pnpm audit
```

### Python (pip-audit)

```bash
pip install pip-audit
pip-audit
```

### Rust (cargo-audit)

```bash
cargo install cargo-audit
cargo audit
```

### Ruby (bundler-audit)

```bash
gem install bundler-audit
bundle audit check --update
```

### Go

```bash
go install golang.org/x/vuln/cmd/govulncheck@latest
govulncheck ./...
```

## Step 3: Parse the Response

The audit output will list any packages with known vulnerabilities. For each
unsafe dependency, extract:

- **Package**: The name of the vulnerable package
- **Version**: The installed version (if known)
- **Severity**: The severity of the vulnerability (if reported)
- **Description**: Brief description of the vulnerability
- **Patched Version**: The version that fixes the vulnerability (if available)

Some tools (e.g., `npm audit`) output JSON with the `--json` flag for easier
parsing:

```bash
npm audit --json
```

## Step 4: Report Findings

Report any unsafe packages to the user with:

- The package name and version
- The vulnerability description and severity
- The recommended fix (upgrade to specific version or use alternative package)

If no vulnerabilities are found, confirm that the dependency is safe to use.

## Important Notes

- Just because a dependency doesn't appear in audit results does not mean it is
  100% safe — it means no known vulnerabilities were found.
- Always prefer the specific version from a lock file when reporting.
- If the audit tool is not installed and cannot be installed, skip this skill
  rather than blocking development.
