# twitter-search-and-save/download.ps1
# Version: 0.1
# License: MIT
# Website: https://github.com/JGuebert/twitter-search-and-save

# Configuration Variables

$bearertoken = # ADD YOUR BEARER TOKEN HERE
$queryparams = # ADD YOUR QUERY STRING HERE
$maxrequests = # SET THE MAXIMUM NUMBER OF REQUESTS TO MAKE



##### DO NOT MODIFY ANYTHING BELOW THIS LINE #####



# Initialize script variables
$count = 0
$nextquery = $queryparams

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
    $nextquery = $responsejson.search_metadata.next_results

} While (($responsejson.statuses.Count -gt 0) -and ($count -lt $maxrequests) -and ($nextquery))
