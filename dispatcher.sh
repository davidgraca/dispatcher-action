#!/bin/bash

counter=1
repo_file_list='listRepos.csv'
number_of_lines=$(wc -l < "$repo_file_list")
while IFS="" read -r line || [ -n "$line" ]
do
	reponame="$(basename "${url%.*}")"
	username="$(basename "${url%.*%/"${reponame}"}")"
	printf "Analyzing %s packages (%d/%d)...\n\n" "$reponame" "$counter" "$number_of_lines"
	gh workflow run packagescan.yml --field repo="$reponame/$username" --field packagename="${username}_$reponame"
	gh run watch
	counter=$((counter+1))
done < "$repo_file_list"
