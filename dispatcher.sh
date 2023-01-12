#!/bin/bash

repo_file_list='listRepos.csv'

package_scan() {
	echo "[*] - Starting package scan workflow on $repo_slash_user..."
	gh workflow run packagescan.yml --field repo="$repo_slash_user" --field packagename="${username}_$reponame"
	last_workflow_run_id="$(gh run list --workflow 'Package Scan' --json databaseId --jq '.[]| .databaseId' --limit 1)"
	echo '[*] - Waiting for package scan workflow to finish...'
	gh run watch --interval 1 --exit-status "$last_workflow_run_id" | grep 'a^'
	echo '[+] - Package scan workflow exited'
}

secret_scan() {
	echo "[*] - Starting secret scan workflow on $repo_slash_user..."
	gh workflow run packagescan.yml --field repo="$repo_slash_user" --field packagename="${username}_$reponame"
	last_workflow_run_id="$(gh run list --workflow 'Secret Scan' --json databaseId --jq '.[]| .databaseId' --limit 1)"
	echo '[*] - Waiting for secret scan workflow to finish...'
	gh run watch --interval 1 --exit-status "$last_workflow_run_id" | grep 'a^'
	echo '[+] - Secret scan workflow exited'
}

# Fix for workflow queue
gh run list --workflow 'dispatcher' --json databaseId --jq '.[]| .databaseId' --limit 1 | grep 'a^'

counter=1
number_of_lines="$(sed '/^\s*#/d;/^\s*$/d' $repo_file_list | wc -l)"
real_number_of_lines=$((number_of_lines+1))
while IFS="" read -r line || [ -n "$line" ]
do
	url="${line%/}" # Remove trailing slash
	reponame="${url##*/}"
	repo_slash_user="${url#*.*/}"
	username="${repo_slash_user%/*}"
	echo
	echo "----- $repo_slash_user ($counter/$real_number_of_lines) -----"
	package_scan
	secret_scan
	counter=$((counter+1))
done < "$repo_file_list"
echo '[+] - Done!'