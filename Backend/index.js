var express = require('express');
var app = express();
var request = require('request');
var convertCondition = require('./lib/utils/conditionConverter');

app.set('port', (process.env.PORT || 9000));
app.use(express.static(__dirname + '/public'));

app.get('/', function(req, res) {
  console.log("new request: "+JSON.stringify(req.query, undefined, 2));
  getWeatherCandyData(req, res);
});

app.listen(app.get('port'), function() {
  console.log("We're live fuckers!!! Peep port:" + app.get('port'))
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
  // Adjust for timezone
  console.log('adjusted date is: ' + currentAdjustedDate);

  //build weatherQueryString with parameters the client sent us
  if (cityID) { 
    console.log("got cityID="+cityID);
    weatherQueryString = weatherQueryString+"id="+cityID;
    forecastQueryString = forecastQueryString+"id="+cityID;
  } else if (lat && lon) { // TODO: use isNaN here instead
    console.log("got lat="+lat+" and lon="+lon);
    weatherQueryString = weatherQueryString+"lat="+lat+"&lon="+lon;
    forecastQueryString = forecastQueryString+"lat="+lat+"&lon="+lon;
  } else if (cityName) {
    console.log("got cityName="+cityName);
    weatherQueryString = weatherQueryString+"q="+cityName;
    forecastQueryString = forecastQueryString+"q="+cityName;
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

      objForClient.forecastList = [];

      forecastResponse.list.forEach(function(entry) {
        var dateOfForecast = new Date(entry["dt"]);
        if ((currentDate.getTime() / 1000) < dateOfForecast.getTime()) 
        {
          var forecastUnit = {};
          forecastUnit.dt = entry.dt;
          forecastUnit.temperature = entry.main.temp;
          forecastUnit.condition = convertCondition(entry.weather[0].id);
          objForClient.forecastList.push(forecastUnit);
        };
      });

      var redditQueryString;
      console.log('THE IMAGE CATEGORY IS : ' + imageCategory);
      if(imageCategory === 0){ //girls
        console.log('got here');
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

        var filteredPics = [];

        // Remove gallery links and gifs
        for (pic in pics) 
        {
          var picUrl = pics[pic].data.url;
          var endsWithGIF = picUrl.indexOf('.gif', picUrl.length - 4) !== -1 || picUrl.indexOf('.gifv', picUrl.length - 5) !== -1;

          if (picUrl.indexOf('gallery') == -1 && !endsWithGIF) 
            {
              filteredPics.push(pics[pic])
            }
        }

        var pic = filteredPics[Math.floor(Math.random()*filteredPics.length)];
        var picUrl = pic ? pic.data.url : '';

        var endsWithJpg = picUrl.indexOf('.jpg', picUrl.length - 4) !== -1;
        var endsWithPng = picUrl.indexOf('.png', picUrl.length - 4) !== -1;

        var url = '';
        if (endsWithJpg || endsWithPng) 
        {
          url = picUrl;
        }
        else if (picUrl.length > 0)
        {
          var slashIndex = picUrl.lastIndexOf('/');
          var imageId = picUrl.substring(slashIndex + 1);
          url = 'http://i.imgur.com/' + imageId + '.jpg';
        }

        console.log("the URL IS " + url);

        objForClient.IGPhotoSet.push({ 
              "PhotoNum": 1,
              "IGUsername":'devspinn',
              "IGUrl": url, 
              "imageCategory": imageCategory
        });

        res.status(200).json({result: objForClient});
      });
    });
  });
}
