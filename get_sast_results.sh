#!/bin/bash
# Requires Checkmarx CLI (cx command) authenticated

CX_BIN='cx'
list="$("$CX_BIN" scan list)"

while IFS= read -r line; do

    # Check that we actually are on a line with a scan ID
    scan_id="$(echo "$line" | awk '{print $1}')"
    if [[ ${#scan_id} -ge 36 ]]; then
        project_name="$(echo "$line" | awk '{print $3}')"
        status="$(echo "$line" | awk '{print $4}')"
        creation_date="$(echo "$line" | awk '{print $5}')"

        if [[ "$status" = 'Completed' ]] || [[ "$status" = 'Partial' ]]; then
            # Name like: user-repo_date_status
            result_file_name="$(echo "$project_name" | tr '/' '-')_${creation_date//[-]/}_${status}"
            echo "Downloading $project_name as $result_file_name..."$
            "$CX_BIN" results show --scan-id "$scan_id" --output-name "$result_file_name" --report-format json --output-path '.'
        fi
    fi
done <<< "$list"