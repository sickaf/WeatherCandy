var express = require('express');
var app = express();
var request = require('request');
var convertCondition = require('./lib/utils/conditionConverter');
var buildWeatherQueryParams = require('./lib/utils/weatherQueryParamsBuilder');
var buildForecastList = require('./lib/utils/forecastListBuilder');
var picsUtil = require('./lib/utils/picsUtil');

var categories = require('./categories');

app.set('port', (process.env.PORT || 9000));
app.use(express.static(__dirname + '/public'));

app.get('/', function(req, res) {
  console.log("new request: "+JSON.stringify(req.query, undefined, 2));
  getWeatherCandyData(req, res);
});

app.listen(app.get('port'), function() {
  console.log("We're live fuckers!!! Peep port:" + app.get('port'))
});

// todo(marcus): move this somewhere
app.get('/api/categories', function(req, res) {
  res.status(200).json(categories);
});

function getWeatherCandyData(req, res) {

  var objForClient = new Object();
  var lat = req.query.lat;
  var lon = req.query.lon;
  var imageCategory = Number(req.query.imageCategory);
  console.log("imageCategory is "+imageCategory);
  var timezone = req.query.timezone;
  console.log('date without timezone adjustment: ' + req.query.date * 1000);
  var currentDate = new Date(req.query.date * 1000);
  var currentAdjustedDate = new Date(req.query.date * 1000 + (timezone * 1000));
  var cityName = req.query.cityName;
  var cityID = req.query.cityID;
  var weatherQueryString ="http://api.openweathermap.org/data/2.5/weather?appid=487b0d8cfa3d312ed2df471ce763f655&";
  var forecastQueryString ="http://api.openweathermap.org/data/2.5/forecast?appid=487b0d8cfa3d312ed2df471ce763f655&";
  var weatherQueryParams = null;
  // Adjust for timezone
  console.log('adjusted date is: ' + currentAdjustedDate);

  //build weatherQueryString with parameters the client sent us
  weatherQueryParams = buildWeatherQueryParams(cityID, lat, lon, cityName);

  if (weatherQueryParams) {
    weatherQueryString += weatherQueryParams;
    forecastQueryString += weatherQueryParams;
  } else {
    console.log("didnt get enough info in the call, weather going to fail.");
    return res.status(400).send("Grin not enough data in request.");
  }

  objForClient.IGPhotoSet = [];
  request(weatherQueryString, function (error, response, currentWeatherResponse) {

    if (error) { return res.status(500).end(); }

    var curWeather = JSON.parse(currentWeatherResponse);
    objForClient.currentWeather = {};
    objForClient.currentWeather.temperature = curWeather.main.temp;
    objForClient.currentWeather.condition = convertCondition(curWeather.weather[0].id);
    objForClient.currentWeather.dt = curWeather.dt;
    objForClient.currentWeather.sunrise = curWeather.sys.sunrise;
    objForClient.currentWeather.sunset  = curWeather.sys.sunset;
    objForClient.currentWeather.cityName = curWeather.name;

    request(forecastQueryString, function (error, response, forecastResponse) {
      if(error){ return res.status(500).end(); }

      var forecastResponse = JSON.parse(forecastResponse);

      console.log('current date ' + currentAdjustedDate.getTime() / 1000);

      objForClient.forecastList = buildForecastList(forecastResponse.list, currentDate);

      // todo(marcus): determine redditQueryString from categories and imageCategory
      var redditQueryString;
      console.log('THE IMAGE CATEGORY IS : ' + imageCategory);
      if(imageCategory === 0){ //girls
        console.log('got here yesterday!');
        redditQueryString = 'https://www.reddit.com/r/prettygirls';
      }
      else if(imageCategory === 1){ //guys
        redditQueryString = 'https://www.reddit.com/r/LadyBoners';
      }
      else if(imageCategory === 2){ //animals
        redditQueryString = 'https://www.reddit.com/r/aww';
      }

      redditQueryString+='/search.json?q=site%3Aimgur&restrict_sr=on&sort=top&t=day&type=link&limit=50';

      request(redditQueryString, function (error, response, redditResp) {

        if (error) { return res.status(500).end(); }

        var pics = JSON.parse(redditResp).data.children;

        var filteredPics = pics.filter(picsUtil.picUrlFilter);
        var pic = filteredPics[Math.floor(Math.random() * filteredPics.length)];
        var urlForClient = picsUtil.getPicUrlForClient(pic);

        console.log("the URL IS " + urlForClient);

        objForClient.IGPhotoSet.push({
              "PhotoNum": 1,
              "IGUsername":'devspinn',
              "IGUrl": urlForClient,
              "imageCategory": imageCategory
        });

        res.status(200).json({result: objForClient});
      });
    });
  });
}

module.exports = app;
