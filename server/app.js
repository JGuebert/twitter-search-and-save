/*
twitter-search-and-save/server/app.js
Version: 0.1
License: MIT
Website: https://github.com/JGuebert/twitter-search-and-save
*/

const express = require("express");
const Sentiment = require("sentiment");
const app = express();

app.get('/sentimentScore', function (req, res) {
    var tweet = req.query.tweet;

    var sentiment = new Sentiment();
    var result = sentiment.analyze(tweet, function (err, result) {
        response = result.score;
        console.log(tweet + ": " + response);
        res.send(JSON.stringify(response));
    });
});

app.listen(3000);
console.log("Server listening on port 3000");
