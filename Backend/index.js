var http = require('http');
var express = require('express');
var request = require('request');
 
var app = express();
app.set('port', process.env.PORT || 3000); 
 
http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});

app.get('/api/reddit', function (req, res) {
	// res.setHeader('Content-Type', 'application/json');
	findRedditPhoto(0, function(url) 
	{
		res.send(JSON.stringify({ imageUrl: url }));
	});
});

function findRedditPhoto(category, success, error)
  {
    var subreddit = ""
    switch (category) {
    case 0:
        subreddit = "nsfw"
        break;
    case 1:
        subreddit = "ladyboners"
        break;
    case 2:
        subreddit = "aww"
        break;
    }

    var queryString = 'https://www.reddit.com/r/' + subreddit + '/search.json?q=site%3Aimgur&restrict_sr=on&sort=top&t=day&type=link&limit=50'

    request(queryString, function (error, response, body) {
  		if (!error && response.statusCode == 200) {

  			var pics = JSON.parse(body).data.children;

            // Remove gallery links and gifs
            for (pic in pics) 
            {
              var picUrl = pics[pic].data.url;

              var endsWithGIF = picUrl.indexOf('.gif', picUrl.length - 4) !== -1;

              if (picUrl.indexOf('gallery') == -1 || endsWithGIF) 
              {
                pics.splice(pic,1);
              }
            }

            var pic = pics[Math.floor(Math.random()*pics.length)];
            var picUrl = pic.data.url;

            var endsWithJpg = picUrl.indexOf('.jpg', picUrl.length - 4) !== -1;
            var endsWithPng = picUrl.indexOf('.png', picUrl.length - 4) !== -1;

            if (endsWithJpg || endsWithPng) 
            {
              success(picUrl)
            }
            else 
            {
              var slashIndex = picUrl.lastIndexOf('/');
              var imageId = picUrl.substring(slashIndex + 1);
              var url = 'http://i.imgur.com/' + imageId + '.jpg';
              success(url)
            }
  		}
  		else
  		{
  			error(error)
  		}
	});
  }

  // function weatherData(request, success, error)
  // {
  // 	var lat = request.params.lat;
  // 	var lon = request.params.lon;
  // 	var imageCategory = Number(request.params.imageCategory);
  // 	console.log("imageCategory is " + imageCategory);
  // 	var cityName = request.params.cityName;
  // 	var cityID = request.params.cityID;
  // 	var weatherQueryString ="api.openweathermap.org/data/2.5/weather?";
  // 	var forecastQueryString ="api.openweathermap.org/data/2.5/forecast?";

  // 	//build weatherQueryString with parameters the client sent us
  // 	if (cityID !== undefined ) 
  // 	{ 
  //   	console.log("got cityID="+cityID);
  //   	weatherQueryString = weatherQueryString+"id="+cityID;
  //   	forecastQueryString = forecastQueryString+"id="+cityID;
  // 	} 
  // 	else if ( (lat !== undefined) && (lon !== undefined) ) 
  // 	{ 
  //   	console.log("got lat="+lat+" and lon="+lon);
  //   	weatherQueryString = weatherQueryString+"lat="+lat+"&lon="+lon;
  //   	forecastQueryString = forecastQueryString+"lat="+lat+"&lon="+lon;
  // 	} 
  // 	else if (cityName!==undefined) 
  // 	{
  //   	console.log("got cityName="+cityName);
  //   	weatherQueryString = weatherQueryString+"q="+cityName;
  //   	forecastQueryString = forecastQueryString+"q="+cityName;
  // 	} 
  // 	else 
  // 	{
  //   	console.log("didnt get enough info in the call, weather going to fail.");
  // 	}
  // }

