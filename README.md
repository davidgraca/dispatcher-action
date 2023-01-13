# dispatcher-action

## Checkmarx

Export results:

```bash
# Get scan ID
cx scan list

# Export results
# Output formats: summaryHTML, summaryJSON, summaryConsole, sarif, json, sonar
cx results show --scan-id <scan-id> --output-name report --report-format json --output-path '.'
```

## Github Action

Clear previous runs:

```bash
gh api repos/davidgraca/dispatcher-action/actions/runs --paginate -q '.workflow_runs[] | select(.head_branch != "main") | "\(.id)"' | xargs -n1 -I % gh api repos/davidgraca/dispatcher-action/actions/runs/% -X DELETE
```
