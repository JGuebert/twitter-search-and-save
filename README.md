# twitter-search-and-save
PowerShell script that locally saves the JSON responses returned from the Twitter Search API

## Setup
After cloning the repository, open download.ps1 and fill in the Configuration Variables at the top of the script
- **$bearertoken**: The access token returned from https://api.twitter.com/oauth2/token (see https://developer.twitter.com/en/docs/basics/authentication/guides/bearer-tokens)
- **$queryparams**: Your query parameters for the initial query, starting with ?. For example, "?q=nasa&result_type=popular" (see https://developer.twitter.com/en/docs/tweets/search/api-reference/get-search-tweets.html)
- **$maxrequests**: The maximum number of times you want the script to call the API to get a batch of tweets. Subsequent calls are made with the query parameters returned in the next_results field of search_metadata of the previous response

## Usage
Run download.ps1 from the directory where you want the output JSON to be saved. The script creates a series of files named "tweets-(incrementing number)-(max_id from the response).json" each containing the JSON output from one query.
