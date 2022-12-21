# twitter-search-and-save/sentiment.ps1
# Version: 0.2-docker-sentiment
# License: MIT
# Website: https://github.com/JGuebert/twitter-search-and-save

## Requires server/app.js running to return score back from 'sentiment' npm module

[CmdletBinding(DefaultParameterSetName="default")]
Param(
    [parameter(ValueFromPipeline=$true)]
    [String[]]
    $Tweets,

    [string]
    $TweetPath,

    [parameter(Mandatory=$true)]
    [int]
    $MinSentiment,

    [switch]
    $ShowSummary,

    [parameter(Mandatory=$false,ParameterSetName="positive")]
    [switch]
    $PositiveOnly,

    [parameter(Mandatory=$false,ParameterSetName="negative")]
    [switch]
    $NegativeOnly
)

function Get-Sentiment {
    Param($tweettext)

    # Make web call to get the sentiment score for the text
    $baseuri = "http://localhost:3000/sentimentScore"
    $requesturi = $baseuri + "?tweet=" + $tweettext
    $response = Invoke-WebRequest -Uri $requesturi
    
    $sentiment = $response.Content | ConvertFrom-Json

    # Only display output if it is above (for positive) or below (for negative) the $MinSentiment value
    if(($sentiment -le -$MinSentiment) -and !($PositiveOnly)) {
        Write-Host "NEGATIVE Sentiment of $sentiment : $tweettext"
    }

    if($sentiment -ge $MinSentiment -and !($NegativeOnly)) {
        Write-Host "POSITIVE Sentiment of $sentiment : $tweettext"
    }

    $sentiment
}

$sentimentsummary = @{}

# Use the passed in tweets if given
if($Tweets)
{
    foreach($tweettext in $Tweets) {
        $sentiment = Get-Sentiment $tweettext
        if($sentimentsummary.ContainsKey($sentiment)) { $sentimentsummary.$sentiment = $sentimentsummary.$sentiment + 1 } else { $sentimentsummary.$sentiment = 1 }
    }
}
# Otherwise look at all of the previously saved tweets
else {
    if($TweetPath) {
        $tweetfiles = Get-ChildItem -Path "$TweetPath\tweets-*.json"
    }
    # Load the tweets that are present in the /tweets directory
    else {
        $tweetfiles = Get-ChildItem -Path ".\tweets\tweets-*.json"
    }

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
                $sentiment = Get-Sentiment $tweettext
                if($sentimentsummary.ContainsKey($sentiment)) { $sentimentsummary.$sentiment = $sentimentsummary.$sentiment + 1 } else { $sentimentsummary.$sentiment = 1 }
            }
        }

    }
}

if($ShowSummary) { 
    $sentimentscores = $sentimentsummary.Keys | Sort-Object

    $sentimentbuckets = @{}
    # Sentiment buckets:
    $sentimentbuckets.strongneg = 0 # Strong negative: -6 or less
    $sentimentbuckets.weakneg = 0 # Weak negative: -5 <-> -3 
    $sentimentbuckets.neutral = 0 # Netural: -2 <-> 2
    $sentimentbuckets.weakpos = 0 # Weak positive: 3 <-> 5
    $sentimentbuckets.strongpos = 0 # Strong positive: 6 or more

    foreach($score in $sentimentscores) {
        if($score -le -6) { $sentimentbuckets.strongneg += $sentimentsummary.$score }
        elseif($score -ge -5 -and $score -le -3) { $sentimentbuckets.weakneg += $sentimentsummary.$score }
        elseif($score -ge -2 -and $score -le 2) { $sentimentbuckets.neutral += $sentimentsummary.$score }
        elseif($score -ge 3 -and $score -le 5) { $sentimentbuckets.weakpos += $sentimentsummary.$score }
        else { $sentimentbuckets.strongpos += $sentimentsummary.$score }
    }

    $sentimentbuckets
}