#!/bin/bash

repo_file_list='listRepos.csv'

# Fix for workflow queue
gh run list --workflow 'dispatcher' --json databaseId --jq '.[]| .databaseId' --limit 1 | grep 'a^'

counter=1
number_of_lines=$(wc -l < "$repo_file_list")
while IFS="" read -r line || [ -n "$line" ]
do
	url="${line%/}" # Remove trailing slash
	reponame="${url##*/}"
	repo_slash_user="${url#*.*/}"
	username="${repo_slash_user%/*}"
	echo
	echo "----- $repo_slash_user ($counter/$number_of_lines) -----"

	echo "[*] - Starting package scan workflow on $repo_slash_user..."
	gh workflow run packagescan.yml --field repo="$repo_slash_user" --field packagename="${username}_$reponame"
	last_workflow_run_id="$(gh run list --workflow 'Package Scan' --json databaseId --jq '.[]| .databaseId' --limit 1)"
	echo '[*] - Waiting for package scan workflow to finish...'
	gh run watch --interval 1 --exit-status "$last_workflow_run_id" | grep 'a^'
	echo '[+] - Package scan workflow exited'

	counter=$((counter+1))
done < "$repo_file_list"