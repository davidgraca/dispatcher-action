# You need to have CX auth login done before executing this script. Using Checkmarx CLI Client
$json = cx scan list --format json --filter limit=2 | ConvertFrom-Json
$scanids = $json.ID
$repos= $json.ProjectName
$count =  $scanids.count


for (($i = 0); $i -lt $count; $i++)
{
    Write-Output "Count of Packages = $($i)"
    Write-Output "Repo = $($repos[$i])"
    Write-Output "ScanId = $($scanids[$i])"
    $properreponame= $repos[$i].Replace("/","_")

    $current = $scanids[$i]

    cx results show --scan-id $current --output-name $properreponame  --report-format json --output-path results

}
