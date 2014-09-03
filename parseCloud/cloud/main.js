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

d = new Date();
d.yyyymmdd();
 
function getWeatherCandyData(request, response) {
 
  var objForClient = new Object();
  var lat = request.params.lat;
  var lon = request.params.lon;
  var date = new Date(request.params.date);
  console.log("date"+date.toUTCString());
  date = date.yyyymmdd();
  var cityName = request.params.cityName;
  var cityID = request.params.cityID;
  var weatherQueryString ="api.openweathermap.org/data/2.5/weather?";
  var forecastQueryString ="api.openweathermap.org/data/2.5/forecast?";
 
  var kelvin = 273;
  var IGPhotoQuery = new Parse.Query("IGPhoto");
 
  //build weatherQueryString with parameters the client sent us
  if ( cityID !== undefined ) { 
    console.log("got cityID="+cityID);
    weatherQueryString = weatherQueryString+"id="+cityID;
    forecastQueryString = forecastQueryString+"id="+cityID;
  } else if ( (lat !== undefined) && (lon !== undefined) ) { //TODO: use isNaN here instead
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
 
  IGPhotoQuery.equalTo("forDate", date);
  return IGPhotoQuery.find().then(function(results) {
 
    var myIGPhotoSet = [];
        for (i = 0; i < results.length; i++) {
          myIGPhotoSet.push({ "PhotoNum":i,
                              "IGUsername":results[i].get("IGUsername"),
                              "IGUrl":results[i].get("URL"), 
                              "IGForDate":results[i].get("forDate")});
    }
    objForClient.IGPhotoSet = myIGPhotoSet;
 
    Parse.Cloud.httpRequest({
      url: weatherQueryString,
      success: function(httpResponse) {
        objForClient.currentWeather = JSON.parse(httpResponse.text);
 
        Parse.Cloud.httpRequest({
          url:forecastQueryString,
          success: function(httpResponse2) {
            var tmpForecastObj = JSON.parse(httpResponse2.text);
             
            objForClient.forecastList = [];
            for (i=0; i< 8; i++) {
              objForClient.forecastList.push(tmpForecastObj.list[i]);
            }
 
            console.log(JSON.stringify(objForClient, undefined, 2) );
            response.success(objForClient);
          },
          error: function(httpResponse) {
            response.error("Forecast request failed with response code " + httpResponse2.status);
          }
        });
      },
      error: function(httpResponse) {
        response.error("Current weather request failed with response code " + httpResponse.status);
      }
    });
  });
}
