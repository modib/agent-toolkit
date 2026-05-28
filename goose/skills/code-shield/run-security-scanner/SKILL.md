---
name: run-security-scanner
description: >
  Run the security scanner on source files to detect vulnerabilities. Use this
  skill to scan files for common security issues like XSS, SQL injection,
  hardcoded secrets, and other CWE-classified vulnerabilities.
---

# Run Security Scanner

This skill runs **semgrep** to scan source files for security vulnerabilities.
Semgrep is a static analysis tool that finds security issues across many
languages using community-contributed rules.

## Prerequisites

Semgrep must be installed:
```bash
pip install semgrep
```

## Step 1: Run the Scan

```bash
semgrep scan --config=auto --json <path>
```

Replace `<path>` with the file or directory to scan (e.g. `src/` or
`path/to/file.js`).

The `--config=auto` flag uses semgrep's curated rule packs including:
- `p/default` — community rules for security, correctness, and best practices
- `p/security-audit` — focused security rules
- Language-specific rules based on detected languages

### Scan a single file

```bash
semgrep scan --config=auto --json /absolute/path/to/file.js
```

### Scan a directory

```bash
semgrep scan --config=auto --json /absolute/path/to/project/src/
```

## Step 2: Parse the Response

Semgrep outputs JSON to stdout with the following structure:

```json
{
  "results": [
    {
      "check_id": "rule.pack.rule-id",
      "path": "/absolute/path/to/file.js",
      "start": {"line": 42, "col": 4},
      "end": {"line": 42, "col": 30},
      "extra": {
        "message": "A human-readable description of the vulnerability",
        "severity": "WARNING",
        "metadata": {
          "cwe": ["CWE-79"],
          "technology": ["javascript"],
          "category": "security",
          "confidence": "MEDIUM"
        },
        "lines": "  const x = userInput;\n"
      }
    }
  ],
  "errors": [],
  "paths": {"scanned": ["/path/to/file.js"]}
}
```

Key fields:

| Field | Description |
|---|---|
| `check_id` | Rule identifier |
| `path` | Absolute path to the affected file |
| `start.line` / `end.line` | Line numbers (1-indexed) |
| `extra.message` | Human-readable description |
| `extra.severity` | `ERROR`, `WARNING`, or `INFO` |
| `extra.metadata.cwe` | Array of CWE identifiers (e.g. `["CWE-79"]`) |

## Step 3: Report Findings

For each finding, report:

```
**[SEVERITY] [vulnerability_class]**
File: <path>, Lines: <start_line>-<end_line>
CWE: <cwe>
Description: <message>
```

Derive `vulnerability_class` from the rule metadata or message (e.g., XSS, SQL
Injection, Path Traversal). Do not include raw rule IDs in the report — focus on
the finding itself.

After listing all findings, provide a summary: total number of findings,
breakdown by severity, and list of distinct CWE categories.

- If `results` is empty and `errors` is empty → report scan completed with no
  vulnerabilities detected.
- If `errors` is non-empty → report the errors and note that the scan may be
  incomplete.

## Step 4: Ignore a Finding (Programmatic Suppression)

If a finding is a **false positive** or has been **accepted** by the user,
suppress it by adding a `nosemgrep` comment to the flagged line:

```javascript
// nosemgrep:rule.id  — False Positive: input is sanitized upstream
const x = userInput;
```

Alternatively, use an inline comment on the same line:

```javascript
const x = userInput; // nosemgrep
```

For multi-line suppressions, use `nosemgrep` on the first line:

```javascript
// nosemgrep
const x = userInput;
```

Always include a brief reason in the comment so the suppression is documented
for future readers.

## Troubleshooting

| Problem | Solution |
|---|---|
| `semgrep: command not found` | Install semgrep: `pip install semgrep` |
| No results for a known vulnerable file | Try additional rule packs: `--config p/r2c-security-audit` |
| Scan is too slow | Narrow the scan to specific files or directories |
| False positives | Add `nosemgrep` comment and document the reason |

## Severity Mapping

| Semgrep Severity | Reported Severity |
|---|---|
| `ERROR` | High |
| `WARNING` | Medium |
| `INFO` | Low |
