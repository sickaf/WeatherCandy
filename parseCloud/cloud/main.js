// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world! Weather app checking in!");
});
 
Parse.Cloud.define("getStaticInstagramURL", function(request, response) {
  response.success("http://photos-c.ak.instagram.com/hphotos-ak-xaf1/10624164_1512601182319290_958640297_n.jpg");
});
 
Parse.Cloud.define("getWeatherCandyData", function(request, response) {
  getWeatherCandyData(request, response);
});

Date.prototype.yyyymmdd = function() {
   var yyyy = this.getFullYear().toString();
   var mm = (this.getMonth()+1).toString(); // getMonth() is zero-based
   var dd  = this.getDate().toString();
   return yyyy +"-"+ (mm[1]?mm:"0"+mm[0]) +"-"+ (dd[1]?dd:"0"+dd[0]); // padding
  };


 
function getWeatherCandyData(request, response) {
 
  var objForClient = new Object();
  var lat = request.params.lat;
  var lon = request.params.lon;
  var imageCategory = request.params.imageCategory;
  console.log("imageCategory is "+imageCategory);
  var currentDate = request.params.date;
  var cityName = request.params.cityName;
  var cityID = request.params.cityID;
  var weatherQueryString ="api.openweathermap.org/data/2.5/weather?";
  var forecastQueryString ="api.openweathermap.org/data/2.5/forecast?";
  
  //build weatherQueryString with parameters the client sent us
  if (cityID !== undefined ) { 
    console.log("got cityID="+cityID);
    weatherQueryString = weatherQueryString+"id="+cityID;
    forecastQueryString = forecastQueryString+"id="+cityID;
  } else if ( (lat !== undefined) && (lon !== undefined) ) { // TODO: use isNaN here instead
    console.log("got lat="+lat+" and lon="+lon);
    weatherQueryString = weatherQueryString+"lat="+lat+"&lon="+lon;
    forecastQueryString = forecastQueryString+"lat="+lat+"&lon="+lon;
  } else if (cityName!==undefined) {
    console.log("got cityName="+cityName);
    weatherQueryString = weatherQueryString+"q="+cityName;
    forecastQueryString = forecastQueryString+"q="+cityName;
  } else {
    console.log("didnt get enough info in the call, weather going to fail.");
  }

  var dateString = currentDate.yyyymmdd();
  var IGPhotoQuery = new Parse.Query("IGPhoto");
  IGPhotoQuery.equalTo("forDate", dateString);
  if (imageCategory !== undefined) {
    console.log("imageCategory is: "+imageCategory);
    IGPhotoQuery.equalTo("imageCategory", imageCategory);
  }

  return IGPhotoQuery.find().then(function(results) //process the results
  {
    var myIGPhotoSet = [];
        for (i = 0; i < results.length; i++) {
          myIGPhotoSet.push({ "PhotoNum":results[i].get("PhotoNum"),
                              "IGUsername":results[i].get("IGUsername"),
                              "IGUrl":results[i].get("URL"), 
                              "IGForDate":results[i].get("forDate"),
                              "imageCategory":results[i].get("imageCategory")});
    }
    objForClient.IGPhotoSet = myIGPhotoSet;
 
    Parse.Cloud.httpRequest({
      url: weatherQueryString,
      success: function(currentWeatherResponse) //add the weather data 
      { 
        var curWeather = JSON.parse(currentWeatherResponse.text);
        objForClient.currentWeather = {};
        objForClient.currentWeather.temperature = curWeather.main.temp;
        objForClient.currentWeather.condition = convertCondition(curWeather.weather[0].id);
        objForClient.currentWeather.dt = curWeather.dt;
        objForClient.currentWeather.sunrise = curWeather.sys.sunrise;
        objForClient.currentWeather.sunset  = curWeather.sys.sunset;
        objForClient.currentWeather.cityName = curWeather.name;

        Parse.Cloud.httpRequest({
          url:forecastQueryString,
          success: function(forecastResponse)  //add the forecast data
          {
            var forecastResponse = JSON.parse(forecastResponse.text);

            console.log('current date ' + currentDate.getTime() / 1000);

            objForClient.forecastList = [];

            forecastResponse.list.forEach(function(entry) 
            {
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
            console.log('total number of hourly forecasts retrieved: ' + forecastResponse.list.length);
            console.log('total number of hourly forecasts passed to the client: ' + objForClient.forecastList.length);
 
            console.log(JSON.stringify(objForClient, undefined, 2) );
            response.success(objForClient);
          },
          error: function(forecastResponse) 
          {
            response.error("Forecast request failed with response code " + forecastResponse.status);
          }
        });
      },
      error: function(currentWeatherResponse) 
      {
        response.error("Current weather request failed with response code " + currentWeatherResponse.status);
      }
    });
  });

  function convertCondition(original) 
  {
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
