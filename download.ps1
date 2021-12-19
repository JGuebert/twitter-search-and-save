# twitter-search-and-save/download.ps1
# Version: 0.7-merge
# License: MIT
# Website: https://github.com/JGuebert/twitter-search-and-save

param (
    [parameter(Mandatory=$true)]    
    [string]
    $BearerToken,
    
    [parameter(Mandatory=$true)]   
    [string]
    $QueryString,

    [switch]$ExtendedMode,

    [string]$OutputName,
    
    [parameter(Mandatory=$true)]
    [int]
    $MaxRequests
);

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Set $ExtendedMode switch if user included tweet_mode=extended in query but did not set use switch when calling script
If ($QueryString.Contains("tweet_mode=extended")) { $ExtendedMode = $true }

# If $QueryString does not include tweet_mode and $ExtendedMode switch is not set, prompt user for if tweet_mode=extended should be used (with default of yes)
If (!$QueryString.Contains("tweet_mode")) {
    # If $ExtendedMode switch is set, add to query string
    If ($ExtendedMode) { $QueryString = $QueryString + "&tweet_mode=extended" }
    # Otherwise need to ask user
    Else {
        $extendedanswer = ""
        Do {
            $extendedanswer = Read-Host "Do you want tweets returned in extended mode? (Y/n)"
            if(!$extendedanswer -or $extendedanswer.Equals("y")) { $extendedanswer = "Y" }
        } While (!($extendedanswer.Equals("Y") -or $extendedanswer.Equals("N") -or $extendedanswer.Equals("n")))

        # If user answered yes, add tweet_mode=extended to the query
        If($extendedanswer.Equals("Y")) { 
            $QueryString = $QueryString + "&tweet_mode=extended"
            $ExtendedMode = $true
        }
    }
}


# Initialize script variables
$count = 0
$outputcount = 0
$since_id = ""

$bearerheader = "Bearer " + $BearerToken

If (!$OutputName) { $OutputName = "tweets" }
$outputpath = ".\" + $OutputName

# Create directory for output JSON to be stored in, direct output to $null so it doesn't appear in console
New-Item -ItemType Directory -Force -Path $outputpath > $null

# If directory already has content in it, figure out where we need to start $outputcount from
$existingcontent = Get-ChildItem -Path $outputpath -Name -Include tweets-*.json
If ($existingcontent) {
    Write-Host "Found existing content in directory, refreshing previous query"
    $outputcount = [int]( $existingcontent | Select-String -Pattern "tweets-(\d+)-" | Foreach-Object { $_.Matches[0].Groups[1].Value } | Sort-Object {[int]$_})[-1] + 1 
    $maxid = ($existingcontent | Select-String -Pattern "tweets-\d+-(\d+)" | Foreach-Object { $_.Matches[0].Groups[1].Value } | Sort-Object {[int64]$_})[-1]
    $since_id = "&since_id=" + $maxid
    $QueryString = $QueryString + $since_id
    Write-Host "Getting tweets newer than $maxid"
    #$lastoutput = Get-Item -Path $outputpath -Include "tweets-$outputcount*" | ConvertFrom-Json
    #$nextquery = If ($ExtendedMode) {$lastoutput.search_metadata.next_results + "&tweet_mode=extended"} Else {$lastoutput.search_metadata.next_results}
}

$nextquery = $QueryString

Do
{
    
    # Get the data from the API
    $baseuri = "https://api.twitter.com/1.1/search/tweets.json"
    $requesturi = $baseuri + $nextquery
    $response = Invoke-WebRequest -Uri $requesturi -Headers @{Authorization=$bearerheader} -UseBasicParsing
    
    # Write the content returned to a file
    $responsejson = $response.Content | ConvertFrom-Json
    $filepath = $outputpath + "\tweets-" + $outputcount + "-" + $responsejson.search_metadata.max_id + ".json"
    Out-File $filepath -InputObject $response.Content -Encoding UTF8

    # Increment $count and $outputcount for the next time
    $count++
    $outputcount++

    # Figure out what the next query needs to be to get the next set of older tweets
    $nextquery = If ($ExtendedMode) {$responsejson.search_metadata.next_results + "&tweet_mode=extended" + $since_id} Else {$responsejson.search_metadata.next_results  + $since_id}

} While (($responsejson.statuses.Count -gt 0) -and ($count -lt $MaxRequests) -and ($nextquery))

# Save the query parameters used to a query.txt file
Out-File "$outputpath\query.txt" -InputObject $QueryString -Encoding UTF8

Compress-Archive -Path "$outputpath\*" -DestinationPath ".\$OutputName.zip" -Update
