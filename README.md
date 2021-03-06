# twitter-search-and-save
PowerShell scripts that locally save the JSON responses returned from the Twitter Search API and can run local searches against them

### download.ps1
Run download.ps1 from the directory where you want the output JSON to be saved. The script creates a series of files named "tweets-(incrementing number)-(max_id from the response).json" in a directory containing the JSON output from the queries and also archives the output to a zip file.

**-BearerToken** (required): The access token returned from https://api.twitter.com/oauth2/token (see https://developer.twitter.com/en/docs/basics/authentication/guides/bearer-tokens)

**-QueryString** (required): Your query parameters for the initial query, starting with ?. For example, "?q=nasa&result_type=popular" (see https://developer.twitter.com/en/docs/tweets/search/api-reference/get-search-tweets.html)

**-MaxRequests** (required): The maximum number of times you want the script to call the API to get a batch of tweets. Subsequent calls after the first are made with the query parameters returned in the next_results field of search_metadata of the previous response

**-OutputName** (default: tweets): The name of the directory and zip file to store the downloaded tweets

### search.ps1
Run search.ps1 from either the directory where download.ps1 was run (containing an existing tweets directory) or provide a path to a previously generated zip file. The script will output to the console any tweets that contain text matching the string configured.

**-SearchString** (required): The string to search across all tweets for in either the full_text or text fields

**-ArchiveName** (optional): The path to a zip file that will be extracted and searched; otherwise, the existing tweets directory content will be used

**-OutputAsArray** (optional): To pipe the output of a search into sentiment.ps1, invoke with this switch

### sentiment.ps1
Run sentiment.ps1 from either a location containing an existing tweets directory to scan all tweets or pipe in the output from search.ps1 (using the -OutputAsArray switch) to display the sentiment scores of tweets.

In order to run sentiment.ps1, the server/app.js Node application must be running to return a sentiment score. 

**-MinSentiment** (required): The threshold for a tweet and its sentiment score to be displayed.

**-PositiveOnly** or **-NegativeOnly** (optional): Switches to indicate that only positive or negative sentiments should be displayed. If neither of these switches is set, both positive and negative will be output. 
