# twitter-search-and-save/sentiment.ps1
# Version: 0.1-sentiment
# License: MIT
# Website: https://github.com/JGuebert/twitter-search-and-save

## Requires Node.js server running at localhost:3000/sentimentScore to return score back from 'sentiment' npm module

# Configuration Variables



##### DO NOT MODIFY ANYTHING BELOW THIS LINE #####



$tweetfiles = Get-ChildItem -Path ".\tweets\tweets-*.json"

foreach($file in $tweetfiles) {

    $content = Get-Content $file | ConvertFrom-Json
        
    # Iterate through each status in the file to see if it contains the text
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
        

            $baseuri = "http://localhost:3000/sentimentScore"
            $requesturi = $baseuri + "?tweet=" + $tweettext
            $response = Invoke-WebRequest -Uri $requesturi
            
            $sentiment = $response.Content | ConvertFrom-Json

            if($sentiment -lt -3) {
                "NEGATIVE Sentiment of " + $sentiment + ": " + $tweettext
            }

            if($sentiment -gt 3) {
                "POSITIVE Sentiment of " + $sentiment + ": " + $tweettext
            }
        }
    }

}