#!/bin/bash

repo_file_list='listRepos.csv'

package_scan() {
	workflow_name='Package Scan'
	echo 'Analyzing packages...'
	gh workflow run packagescan.yml --field repo="$reponame/$username" --field packagename="${username}_$reponame"
	last_workflow_run_id="$(gh run list --workflow "$workflow_name" --json databaseId --jq '.[]| .databaseId' --limit 1)"
	gh run watch --interval 1 --exit-status "$last_workflow_run_id"
}

counter=1
number_of_lines=$(wc -l < "$repo_file_list")
while IFS="" read -r url || [ -n "$url" ]
do
	reponame="$(basename "${url%.*}")"
	username="$(basename "${url%.*%/"${reponame}"}")"
	printf "Analyzing %s/%s (%d/%d)...\n\n" "$username" "$reponame" "$counter" "$number_of_lines"
	package_scan
	counter=$((counter+1))
done < "$repo_file_list"
