# twitter-search-and-save/download.ps1
# Version: 0.5.2
# License: MIT
# Website: https://github.com/JGuebert/twitter-search-and-save

param (
    [parameter(Mandatory=$true)]    
    [string]
    $BearerToken,
    
    [parameter(Mandatory=$true)]   
    [string]
    $QueryString,
    
    [parameter(Mandatory=$true)]
    [int]
    $MaxRequests
);


# If $QueryString does not include tweet_mode, prompt user for if tweet_mode=extended should be used (with default of yes)
If (!$QueryString.Contains("tweet_mode")) {
    $extendedanswer = ""
    Do {
        $extendedanswer = Read-Host "Do you want tweets returned in extended mode? (Y/n)"
        if(!$extendedanswer -or $extendedanswer.Equals("y")) { $extendedanswer = "Y" }
    } While (!($extendedanswer.Equals("Y") -or $extendedanswer.Equals("N") -or $extendedanswer.Equals("n")))

    # If user answered yes, add tweet_mode=extended to the query
    If($extendedanswer.Equals("Y")) { $QueryString = $QueryString + "&tweet_mode=extended" }
}

while($MaxRequests -lt 1) { [int]$MaxRequests = Read-Host "Max number of API requests" }


# Initialize script variables
$count = 0
$nextquery = $QueryString
$extendedmode = If ($QueryString.Contains("tweet_mode=extended")) {$true} Else {$false}

$bearerheader = "Bearer " + $BearerToken

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

    # Increment $count for the next time
    $count++

    # Figure out what the next query needs to be to get the next set of older tweets
    $nextquery = If ($extendedmode) {$responsejson.search_metadata.next_results + "&tweet_mode=extended"} Else {$responsejson.search_metadata.next_results}

} While (($responsejson.statuses.Count -gt 0) -and ($count -lt $MaxRequests) -and ($nextquery))

# Save the query parameters used to a query.txt file
Out-File ".\tweets\query.txt" -InputObject $QueryString

Compress-Archive -Path ".\tweets\*" -DestinationPath ".\output.zip"
