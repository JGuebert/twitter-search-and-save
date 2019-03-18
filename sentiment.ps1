# twitter-search-and-save/sentiment.ps1
# Version: 0.1-sentiment
# License: MIT
# Website: https://github.com/JGuebert/twitter-search-and-save

## Requires server/app.js running to return score back from 'sentiment' npm module

Param(
    [parameter(ValueFromPipeline=$true)]
    [String[]]
    $Tweets
)

# Configuration Variables

##### DO NOT MODIFY ANYTHING BELOW THIS LINE #####

function Get-Sentiment {
    Param($tweettext)

    # Make web call to get the sentiment score for the text
    $baseuri = "http://localhost:3000/sentimentScore"
    $requesturi = $baseuri + "?tweet=" + $tweettext
    $response = Invoke-WebRequest -Uri $requesturi
    
    $sentiment = $response.Content | ConvertFrom-Json

    # Only display output if it is above 3 (for positive) or below -3 (for negative) as a way to handle strong signal
    if($sentiment -lt -3) {
        "NEGATIVE Sentiment of " + $sentiment + ": " + $tweettext
    }

    if($sentiment -gt 3) {
        "POSITIVE Sentiment of " + $sentiment + ": " + $tweettext
    }
}

# Use the passed in tweets if given
if($Tweets)
{
    foreach($tweettext in $Tweets) {
        Get-Sentiment $tweettext
    }
}
# Otherwise look at all of the previously saved tweets
else {
    # Load the tweets that are present in the /tweets directory
    $tweetfiles = Get-ChildItem -Path ".\tweets\tweets-*.json"

    foreach($file in $tweetfiles) {

        $content = Get-Content $file | ConvertFrom-Json
            
        # Loop through all of the tweets
        foreach($status in $content.statuses) {
            $tweettext = ""
            
            # Ignore retweets
            if(!($status.retweeted_status)) {
            
                # See if full_text exists (tweets returned in extended mode)
                if($status.full_text) {
                    $tweettext = $status.full_text
                }
                # Otherwise we just need to look at the text field
                else {
                    $tweettext = $status.text
                }
                Get-Sentiment $tweettext
            }
        }

    }
}