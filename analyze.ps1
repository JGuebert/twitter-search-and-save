# twitter-search-and-save/analyze.ps1
# Version: 0.1-interactive
# License: MIT
# Website: https://github.com/JGuebert/twitter-search-and-save

# Configuration Variables

$search = "" # SET TO STRING TO SEARCH FOR IN TWEETS



##### DO NOT MODIFY ANYTHING BELOW THIS LINE #####



# Prompt user for input if not set in script
if(!$search) { $search = Read-Host "Text to search" }

# Load the tweet files from the current directory
$tweetfiles = Get-ChildItem -Path tweets-*.json

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
                if($status.full_text.Contains($scanfor)) {$tweettext = $status.full_text}
            }
            # Otherwise we just need to look at the text field
            else {
                if($status.text.Contains($scanfor)) {$tweettext = $status.text}
            }

            if($tweettext) {"Tweet from " + $status.user.screen_name + ": " + $tweettext}
        }

    }
}