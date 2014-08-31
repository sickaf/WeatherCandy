
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

//api.openweathermap.org/data/2.5/weather?lat=35&lon=139
// -84.398277, 39.51506 ]

function getWeatherCandyData(request, response) {

  var lat = request.params.lat;
  var lon = request.params.lon;
  var date = request.params.date;
  var cityName = request.params.cityName;
  var cityID = request.params.cityID;
  var WeatherQueryString ='api.openweathermap.org/data/2.5/weather?';

  var IGPhotoQuery = new Parse.Query("IGPhoto");


  //build WeatherQueryString with parameters the client sent us
  if ( (lat !== undefined) && (lon !== undefined) ) { //TODO: use isNaN here instead
    console.log('got lat='+lat+' and lon='+lon);
    WeatherQueryString = WeatherQueryString+'lat='+lat+'&lon='+lon;
  } else if (cityName!==undefined) {
    console.log('got cityName='+cityName);
    WeatherQueryString = WeatherQueryString+'q='+cityName;
  } else {
    console.log('didnt get enough info in the call, weather going to fail.');
  }

  IGPhotoQuery.equalTo("forDate", date);
  return IGPhotoQuery.find().then(function(results) {

    console.log('the number of photos is ' + results.length);
    console.log('getting weather with ' + WeatherQueryString);

    Parse.Cloud.httpRequest({
      url: WeatherQueryString,
      success: function(httpResponse) {
        
        var obj = JSON.parse(httpResponse.text);
        obj.IGPhotos = [];

        for (i = 0; i < results.length; i++) {
          obj['IGPhotos'].push({'PhotoNum':i, 'IGUsername':results[i].get('IGUsername'),'IGUrl':results[i].get('URL')});
        }
        console.log("the obj is: "+ JSON.stringify(obj) );

        response.success('succeeded');
      },
      error: function(httpResponse) {
        response.error('Request failed with response code ' + httpResponse.status);
      }
    });
  });
}

