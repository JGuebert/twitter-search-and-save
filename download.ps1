# twitter-search-and-save/download.ps1
# Version: 0.5-extended-assistant
# License: MIT
# Website: https://github.com/JGuebert/twitter-search-and-save

# Configuration Variables

$bearertoken = "" # ADD YOUR BEARER TOKEN HERE
$queryparams = "" # ADD YOUR QUERY STRING HERE
$maxrequests = 0 # SET THE MAXIMUM NUMBER OF REQUESTS TO MAKE



##### DO NOT MODIFY ANYTHING BELOW THIS LINE #####



# Prompt user for input if not set in script
if(!$bearertoken) { $bearertoken = Read-Host "Bearer token" }
if(!$queryparams) { $queryparams = Read-Host "Query string (starting with ?)" }

# If $queryparams does not include tweet_mode, prompt user for if tweet_mode=extended should be used (with default of yes)
If (!$queryparams.Contains("tweet_mode")) {
    $extendedanswer = ""
    Do {
        $extendedanswer = Read-Host "Do you want tweets returned in extended mode? (Y/n)"
        if(!$extendedanswer) { $extendedanswer = "Y"}
    } While (!($extendedanswer.Equals("Y") -or $extendedanswer.Equals("n")))

}

while($maxrequests -lt 1) { [int]$maxrequests = Read-Host "Max number of API requests" }


# Initialize script variables
$count = 0
$nextquery = $queryparams
$extendedmode = If ($queryparams.Contains("tweet_mode=extended") -or $extendedanswer.Equals("Y")) {$true} Else {$false}

$bearerheader = "Bearer " + $bearertoken

# Create directory for output JSON to be stored in, direct output to $null so it doesn't appear in console
New-Item -ItemType Directory -Force -Path ".\tweets" > $null

Do
{
    
    # Get the data from the API
    $baseuri = "https://api.twitter.com/1.1/search/tweets.json"
    $requesturi = $baseuri + $nextquery
    $response = Invoke-WebRequest -Uri $requesturi -Headers @{Authorization=$bearerheader}
    
    # Write the content returned to a file
    $responsejson = $response.Content | ConvertFrom-Json
    $filepath = ".\tweets\tweets-" + $count + "-" + $responsejson.search_metadata.max_id + ".json"
    Out-File $filepath -InputObject $response.Content

    #Increment $count for the next time
    $count++

    # Figure out what the next query needs to be to get the next set of older tweets
    $nextquery = If ($extendedmode) {$responsejson.search_metadata.next_results + "&tweet_mode=extended"} Else {$responsejson.search_metadata.next_results}

} While (($responsejson.statuses.Count -gt 0) -and ($count -lt $maxrequests) -and ($nextquery))

Compress-Archive -Path ".\tweets\*" -DestinationPath ".\output.zip"
