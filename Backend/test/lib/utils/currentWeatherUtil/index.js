var should = require('chai').should(),
    currentWeatherUtil = require('../../../../lib/utils/currentWeatherUtil');

describe('currentWeatherUtil test suite', function() {
  it('should get a subset of the current weather', function() {
    var curWeather = {
      main: {
        temp: 10
      },
      weather: [{id: 300}],
      dt: 1234567890,
      sys: {
        sunrise: 10,
        sunset: 20
      },
      name: 'updog'
    };

    currentWeatherUtil(curWeather).should.eql({
      temperature: 10,
      condition: 1, // 300 -> drizzle -> 1
      dt: 1234567890,
      sunrise: 10,
      sunset: 20,
      cityName: 'updog'
    });
  });
});
