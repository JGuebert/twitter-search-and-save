$bearertoken = "AAAAAAAAAAAAAAAAAAAAAPV09QAAAAAA0eIL7iRNDVLK4Ivnpq2Z4sG1ydA%3DkN5GNtzZK5hvkmSx0XPUWttbxiRh8qCDYzPam63S7nGNd6w1kM"
$querystring = "?q=nasa"

.\download.ps1 -BearerToken $bearertoken -QueryString $querystring -ExtendedMode -OutputName 2021-nasa -MaxRequests 5