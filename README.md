# twitter-search-and-save
PowerShell scripts that locally saves the JSON responses returned from the Twitter Search API and can run local searches against them

## Setup
### Tweet Downloads
After cloning the repository, open download.ps1 and fill in the Configuration Variables at the top of the script:
- **$bearertoken**: The access token returned from https://api.twitter.com/oauth2/token (see https://developer.twitter.com/en/docs/basics/authentication/guides/bearer-tokens)
- **$queryparams**: Your query parameters for the initial query, starting with ?. For example, "?q=nasa&result_type=popular" (see https://developer.twitter.com/en/docs/tweets/search/api-reference/get-search-tweets.html)
- **$maxrequests**: The maximum number of times you want the script to call the API to get a batch of tweets. Subsequent calls are made with the query parameters returned in the next_results field of search_metadata of the previous response
- **$extendedmode** (Added in 0.2): When set to true, appends "&tweet_mode=extended" to the end of queries. This is needed because the tweet_mode parameter is dropped from next_results

### Tweet Analysis
Open analyze.ps1 and fill in the Configuration Variables at the top of the script:
- **$search**: The string to search across all tweets for in either the full_text or text fields

## Usage
Run download.ps1 from the directory where you want the output JSON to be saved. The script creates a series of files named "tweets-(incrementing number)-(max_id from the response).json" each containing the JSON output from one query.

Run analyze.ps1 from the directory with the output of download.ps1. The script will output to the console any tweets that contain text matching the string configured.
