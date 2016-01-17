var express = require('express');
var app = express();
var request = require('request');


app.set('port', (process.env.PORT || 9000));
app.use(express.static(__dirname + '/public'));

app.get('/', function(req, res) {
	console.log("new request: "+JSON.stringify(req.query, undefined, 2));
	getWeatherCandyData(req, res);
});


app.listen(app.get('port'), function() {
  console.log("We're live fuckers!!! Peep port:" + app.get('port'))
});


Date.prototype.yyyymmdd = function() {
  var yyyy = this.getFullYear().toString();
  var mm = (this.getMonth()+1).toString(); // getMonth() is zero-based
  var dd  = this.getDate().toString();
  return yyyy +"-"+ (mm[1]?mm:"0"+mm[0]) +"-"+ (dd[1]?dd:"0"+dd[0]); // padding
};
 
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

  var dateString = currentAdjustedDate.yyyymmdd();


  objForClient.IGPhotoSet = [];
 	request(weatherQueryString, function (error, response, currentWeatherResponse) {
 		if(error){ return res.status(500).end(); }

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
        redditQueryString = 'https://www.reddit.com/r/nsfw/search.json?q=site%3Aimgur&restrict_sr=on&sort=top&t=all';
      } 
      else if(imageCategory === 1){ //guys
        redditQueryString = 'https://www.reddit.com/r/LadyBoners/search.json?q=site%3Aimgur&restrict_sr=on&sort=top&t=all';
      }
      else if(imageCategory === 2){ //animals
        redditQueryString = 'https://www.reddit.com/r/aww/search.json?q=site%3Aimgur&restrict_sr=on&sort=top&t=all';
      }

			request(redditQueryString, function (error, response, redditResp) {
    		if(error){ return res.status(500).end(); }

        var children = JSON.parse(redditResp).data.children;
        var urls = [];
        var counter = 0;
        for(var i = 0; objForClient.IGPhotoSet.length < 3 && children.length > i; i++){
          if( children[i].data &&
              children[i].data.media &&
              children[i].data.media.oembed &&
              children[i].data.media.oembed.thumbnail_url){
            
            console.log("the URL IS "+children[i].data.media.oembed.thumbnail_url);

            objForClient.IGPhotoSet.push({ 
              "PhotoNum": counter,
              "IGUsername":'devspinn',
              "IGUrl": children[i].data.media.oembed.thumbnail_url, 
              "IGForDate": dateString,
              "imageCategory": imageCategory
            });
            counter++;
          }
        }
        res.status(200).json({result: objForClient});
      });
		});
	});


  function convertCondition(original) {
    var storm = [200, 201, 202, 210, 211, 212, 221, 230, 231, 232, 900, 901, 902, 957, 958, 959, 960, 961, 962,771, 781]; //0    
    var drizzle = [300, 301, 302, 310, 311, 312, 313, 314, 321, 701]; //1
    var rain = [500, 501,502,503, 504, 511, 520, 521, 522, 531, 906]; //2
    var snow = [600, 601, 602, 611, 612, 615, 616, 620, 621, 622]; //3
    var haze = [711, 721, 731, 741, 751, 761, 762]; //4
    var clear = [800, 903, 904, 905, 951, 952, 954, 954, 955, 956]; //5
    var partlyCloudy = [801, 802, 803]; //6
    var overcast = [804]; //7

    var conditions = [storm, drizzle, rain, snow, haze, clear, partlyCloudy, overcast];
    for (x = 0; x < conditions.length; x++)
    {
      var conditionSet = conditions[x];
      for (i = 0; i<conditionSet.length; i++) 
      {
        if(original == conditionSet[i]) 
        {
          return x;       
        }
      }
    }
    console.log("convertCondition couldnt find a match");
    return original;
  }
}
