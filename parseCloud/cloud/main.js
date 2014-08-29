
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world! Weather app checking in!");
});

Parse.Cloud.define("getStaticInstagramURL", function(request, response) {
  response.success("http://photos-c.ak.instagram.com/hphotos-ak-xaf1/10624164_1512601182319290_958640297_n.jpg");
});


Parse.Cloud.define("getWeatherData", function(request, response) {
  getWeatherData(request, response);
});

//api.openweathermap.org/data/2.5/weather?lat=35&lon=139

function getWeatherData(request, response) {

  var lat = request.params.lat;
  var lon = request.params.lon;
  
  console.log('getWeatherData called. lat= '+request.params.lat);

  Parse.Cloud.httpRequest({
    url: 'api.openweathermap.org/data/2.5/weather?lat='+lat+'&lon='+lon+'',
    success: function(httpResponse) {
      console.log('the response is ' + httpResponse.text);

      obj = JSON.parse(httpResponse.text);

      console.log('description is ' + obj.weather[0].description);
      console.log('base is ' + obj.base);
      console.log('temp is ' + obj.main.temp);
      console.log('high is ' + obj.main.temp_max);
      console.log('low is ' + obj.main.temp_min);

      response.success('succeeded');
    },
    error: function(httpResponse) {
      response.error('Request failed with response code ' + httpResponse.status);
    }
  });
}

function ParseWeatherJSON(weatherJSON) {


}




