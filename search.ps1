# twitter-search-and-save/search.ps1
# Version: 0.6-search-urls
# License: MIT
# Website: https://github.com/JGuebert/twitter-search-and-save

param (
    [parameter(Mandatory=$true)]    
    [string]
    $SearchString,
    
    [string]$ArchiveName,
    
    [switch]$OutputAsArray
);

##### DO NOT MODIFY ANYTHING BELOW THIS LINE #####

# Prompt user for input if not set in script
if(!$ArchiveName) { $ArchiveName = Read-Host "Path to zip archive, or leave blank to use existing tweets directory" }

# Expand the zip archive if provided
if($ArchiveName) {
    Remove-Item -Path ".\tweets" -Recurse -ErrorAction Ignore
    Expand-Archive -Path $ArchiveName -DestinationPath ".\tweets"
}

# Load the files from the tweets directory
$tweetfiles = Get-ChildItem -Path ".\tweets\tweets-*.json"

foreach($file in $tweetfiles) {
    
    # Set the variable containing the text to search for
    $scanfor = $SearchString
    
    # Load the content of the file
    $content = Get-Content $file | ConvertFrom-Json
    
    # Iterate through each status in the file to see if it contains the text
    foreach($status in $content.statuses) {
        $tweettext = ""
        
        # Ignore retweets
        if(!($status.retweeted_status)) {
        
            # See if full_text exists (tweets returned in extended mode)
            if($status.full_text) {
                if($status.full_text.ToLower().Contains($scanfor.ToLower())) {$tweettext = $status.full_text}
            }
            # Otherwise we just need to look at the text field
            else {
                if($status.text.ToLower().Contains($scanfor.ToLower())) {$tweettext = $status.text}
            }

            if($tweettext) {
                if($OutputAsArray) { $outputarray += ,$tweettext }    
                else { 
                    # Twitter URL is constructed as <username>/status/<tweet ID>
                    $tweet_url = "https://twitter.com/" + $status.user.screen_name + "/status/" + $status.id_str
                    "Tweet from " + $status.user.screen_name + ": " + $tweettext
                    $tweet_url
                    ""
                }
            }
        }

    }
}

if($OutputAsArray) { ,$outputarray }