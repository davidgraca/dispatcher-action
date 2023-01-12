#!/bin/bash

repo_file_list='listRepos.csv'

fix_workflow_queue() {
	gh run list --workflow 'dispatcher' --json databaseId --jq '.[]| .databaseId' --limit 1
}

package_scan() {
	workflow_name='Package Scan'
	echo 'Analyzing packages...'
	gh workflow run packagescan.yml --field repo="$repo_slash_user" --field packagename="${username}_$reponame"
	last_workflow_run_id="$(gh run list --workflow "$workflow_name" --json databaseId --jq '.[]| .databaseId' --limit 1)"
	echo "Started workflow $last_workflow_run_id"
	echo 'Waiting for workflow to finish...'
	gh run watch --interval 1 --exit-status "$last_workflow_run_id" | grep 'a^'
	echo 'Workflow exited'
}

counter=1
number_of_lines=$(wc -l < "$repo_file_list")
while IFS="" read -r line || [ -n "$line" ]
do
	url="${line%/}" # Remove trailing slash
	reponame="${url##*/}"
	repo_slash_user="${url#*.*/}"
	username="${repo_slash_user%/*}"
	printf "Analyzing %s (%d/%d)...\n" "$repo_slash_user" "$counter" "$number_of_lines"
	package_scan
	counter=$((counter+1))
done < "$repo_file_list"