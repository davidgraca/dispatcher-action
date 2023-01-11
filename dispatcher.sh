#!/bin/bash

counter=1
repo_file_list='listRepos.csv'
number_of_lines=$(wc -l < "$repo_file_list")
while IFS="" read -r line || [ -n "$line" ]
do
	repo="$(basename "$line")"
	printf "Analyzing %s (%d/%d)...\n\n" "$repo" "$counter" "$number_of_lines"
	gh workflow run packagescan.yml --field repo="$repo" --field packagename="results-${repo}"
	echo 'done'
	#gh run watch
	counter=$((counter+1))
done < "$repo_file_list"
