# twitter-search-and-save/download.ps1
# Version: 0.2-interactive
# License: MIT
# Website: https://github.com/JGuebert/twitter-search-and-save

# Configuration Variables

$bearertoken = "" # ADD YOUR BEARER TOKEN HERE
$queryparams = "" # ADD YOUR QUERY STRING HERE
$maxrequests = 0 # SET THE MAXIMUM NUMBER OF REQUESTS TO MAKE
$extendedmode = $true # true = &tweet_mode=extended appended to query, needed because next_results will not include it otherwise



##### DO NOT MODIFY ANYTHING BELOW THIS LINE #####



# Prompt user for input if not set in script
if(!$bearertoken) { $bearertoken = Read-Host "Bearer token" }
if(!$queryparams) { $queryparams = Read-Host "Query string (starting with ?)" }
while($maxrequests -lt 1) { [int]$maxrequests = Read-Host "Max number of API requests" }


# Initialize script variables
$count = 0
$nextquery = If ($extendedmode) {$queryparams + "&tweet_mode=extended"} Else {$queryparams}


$bearerheader = "Bearer " + $bearertoken

Do
{
    
    # Get the data from the API
    $baseuri = "https://api.twitter.com/1.1/search/tweets.json"
    $requesturi = $baseuri + $nextquery
    $response = Invoke-WebRequest -Uri $requesturi -Headers @{Authorization=$bearerheader}
    
    # Write the content returned to a file
    $responsejson = $response.Content | ConvertFrom-Json
    $filepath = ".\tweets-" + $count + "-" + $responsejson.search_metadata.max_id + ".json"
    Out-File $filepath -InputObject $response.Content

    #Increment $count for the next time
    $count++

    # Figure out what the next query needs to be to get the next set of older tweets
    $nextquery = If ($extendedmode) {$responsejson.search_metadata.next_results + "&tweet_mode=extended"} Else {$responsejson.search_metadata.next_results}

} While (($responsejson.statuses.Count -gt 0) -and ($count -lt $maxrequests) -and ($nextquery))
