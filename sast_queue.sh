#!/bin/bash
# Requires Checkmarx CLI (cx command) authenticated

QUEUE_SIZE=10
CX_BIN='cx'
list="$("$CX_BIN" scan list)"

# Count number of cx scan instances
count_scan_instances() {
    while IFS= read -r line; do
        counter=0

        # Check that we actually are on a line with a scan ID
        scan_id="$(echo "$line" | awk '{print $1}')"
        if [[ ${#scan_id} -ge 36 ]]; then
            counter=$((counter+1))
        fi
    done <<< "$list"
}


# Wait in queue
count_scan_instances
while [[ $counter -lt $QUEUE_SIZE ]]; do
    count_scan_instances
    echo 'Waiting ...'
    sleep 1
done

# Launch SAST workflow
# TODO: change following variables
echo "[*] - Starting SAST scan workflow on $repo_slash_user..."
gh workflow run '.github/workflows/sast.yml' --field repo="$repo_slash_user" --field packagename="${username}_$reponame"
last_workflow_run_id="$(gh run list --workflow '.github/workflows/sast.yml' --json databaseId --jq '.[]| .databaseId' --limit 1)"
echo '[*] - Waiting for SAST scan workflow to finish...'
gh run watch --interval 1 --exit-status "$last_workflow_run_id" | grep 'a^'
echo '[+] - SAST workflow exited'