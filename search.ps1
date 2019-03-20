# twitter-search-and-save/search.ps1
# Version: 0.4
# License: MIT
# Website: https://github.com/JGuebert/twitter-search-and-save

param (
    [switch]$OutputAsArray
);

# Configuration Variables

$search = "" # SET TO STRING TO SEARCH FOR IN TWEETS
$archive = "" # PATH TO ZIP ARCHIVE



##### DO NOT MODIFY ANYTHING BELOW THIS LINE #####

# Prompt user for input if not set in script
if(!$search) { $search = Read-Host "Text to search" }
if(!$archive) { $archive = Read-Host "Path to zip archive, or leave blank to use existing tweets directory" }

# Expand the zip archive if provided
if($archive) {
    Remove-Item -Path ".\tweets" -Recurse -ErrorAction Ignore
    Expand-Archive -Path $archive -DestinationPath ".\tweets"
}

# Load the files from the tweets directory
$tweetfiles = Get-ChildItem -Path ".\tweets\tweets-*.json"

foreach($file in $tweetfiles) {
    
    # Set the variable containing the text to search for
    $scanfor = $search
    
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
                else { "Tweet from " + $status.user.screen_name + ": " + $tweettext }
            }
        }

    }
}

if($OutputAsArray) { ,$outputarray }