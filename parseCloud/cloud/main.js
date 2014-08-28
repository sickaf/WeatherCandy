
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world! Weather app checking in!");
});

Parse.Cloud.define("getInstagramURL", function(request, response) {
  response.success("http://photos-c.ak.instagram.com/hphotos-ak-xaf1/10624164_1512601182319290_958640297_n.jpg");
});

Parse.Cloud.beforeSave("IGPhoto", function(request, response) {
    var igPhoto = request.object;
    var imageURL;
    igPhoto.get('fromUser').fetch().then(function(user) {
 
        fromUsername = user.get('username');
        return challenge.get('toUser').fetch();
 
    }).then(function(user) {
 
        toUsername = user.get('username');
 
        var firstQuery = new Parse.Query("TBChallenge");
        firstQuery.include("fromUser");
        firstQuery.include("toUser");
 
        var fromInnerQuery = new Parse.Query("_User");
        fromInnerQuery.equalTo("username", fromUsername);
        firstQuery.matchesQuery("fromUser", fromInnerQuery);
 
        var toInnerQuery = new Parse.Query("_User");
        toInnerQuery.equalTo("username", toUsername);
        firstQuery.matchesQuery("toUser", toInnerQuery);
 
        return firstQuery.find();
 
    }).then(function(results) {
        if (results.length > 0) {
            response.error('Duplicate challenge');
        } else {
            response.success();
        };
    });
});



Parse.Cloud.define("weatherData", function(request, response) {
  
  var query = new Parse.Query("Review");
  query.equalTo("movie", request.params.movie);
  query.find({
    success: function(results) {
      var sum = 0;
      for (var i = 0; i < results.length; ++i) {
        sum += results[i].get("stars");
      }
      response.success(sum / results.length);
    },
    error: function() {
      response.error("weather lookup failed");
    }
  });
});



