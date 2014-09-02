
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

function addInstagram(request, response) {


}

function getWeatherCandyData(request, response) {

  var lat = request.params.lat;
  var lon = request.params.lon;
  var date = request.params.date;
  var cityName = request.params.cityName;
  var cityID = request.params.cityID;
  var WeatherQueryString ="api.openweathermap.org/data/2.5/weather?";
  var kelvin = 273;

  var IGPhotoQuery = new Parse.Query("IGPhoto");


  //build WeatherQueryString with parameters the client sent us
  if ( cityID !== undefined ) { 
    console.log("got cityID="+cityID);
    WeatherQueryString = WeatherQueryString+"id="+cityID;
  } else if ( (lat !== undefined) && (lon !== undefined) ) { //TODO: use isNaN here instead
    console.log("got lat="+lat+" and lon="+lon);
    WeatherQueryString = WeatherQueryString+"lat="+lat+"&lon="+lon;
  } else if (cityName!==undefined) {
    console.log("got cityName="+cityName);
    WeatherQueryString = WeatherQueryString+"q="+cityName;
  } else {
    console.log("didnt get enough info in the call, weather going to fail.");
  }

  IGPhotoQuery.equalTo("forDate", date);
  return IGPhotoQuery.find().then(function(results) {

    console.log("the number of photos is " + results.length);
    console.log("getting weather with " + WeatherQueryString);

    Parse.Cloud.httpRequest({
      url: WeatherQueryString,
      success: function(httpResponse) {
        
        var obj = JSON.parse(httpResponse.text);
        obj.IGPhotos = [];

        for (i = 0; i < results.length; i++) {
          obj["IGPhotos"].push({"PhotoNum":i, "IGUsername":results[i].get("IGUsername"),"IGUrl":results[i].get("URL")});
        }

        stringToReturn =  ""+obj.name + "$"+obj.weather[0].description+"$"+(obj.main.temp-kelvin)+"$"+(obj.main.temp_max-kelvin)+"$"+(obj.main.temp_min-kelvin)+"$"+obj.IGPhotos[0].IGUrl;
        console.log("stringToReturn: "+ stringToReturn);

        var weatherCandyDataStr = JSON.stringify(obj);
        console.log("the obj is: "+ weatherCandyDataStr );


        response.success(stringToReturn);
      },
      error: function(httpResponse) {
        response.error("Request failed with response code " + httpResponse.status);
      }
    });
  });
}

