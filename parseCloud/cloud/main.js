
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

function getWeatherCandyData(request, response) {

  var lat = request.params.lat;
  var lon = request.params.lon;
  var date = request.params.date;
  var listOfIGs = [];
  var IGPhotoQuery = new Parse.Query("IGPhoto");
  IGPhotoQuery.equalTo("forDate", date);

  return IGPhotoQuery.find().then(function(results) {

    listOfIGs = results;

    console.log('the results.length is ' + results.length);

    Parse.Cloud.httpRequest({
      url: 'api.openweathermap.org/data/2.5/weather?lat='+lat+'&lon='+lon+'',
      success: function(httpResponse) {

        console.log('the response is ' + httpResponse.text);
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

