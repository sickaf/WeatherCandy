var should = require('chai').should(),
    buildForecastList = require('../../../../lib/utils/forecastListBuilder');

describe('weather forecast list builder test suite', function() {
  it('should return [] for invalid data', function() {
    // need to use `eql` to compare contents of arrays
    buildForecastList([], new Date(0)).should.eql([]);
  });

  it('should extract stuff from this sample data', function() {
    var sampleForecastList = [
    {
      dt: 1453593600,
      main:
       { temp: 271.168,
         temp_min: 271.168,
         temp_max: 271.168,
         pressure: 1011.52,
         sea_level: 1015.04,
         grnd_level: 1011.52,
         humidity: 100,
         temp_kf: 0 },
      weather: [ { id: 600, main: 'Snow', description: 'light snow', icon: '13n' } ],
      clouds: { all: 92 },
      wind: { speed: 8.16, deg: 6.50116 },
      rain: {},
      snow: { '3h': 1.045 },
      sys: { pod: 'n' },
      dt_txt: '2016-01-24 00:00:00'
    },
    {
      dt: 1453680000,
      main:
       { temp: 269.703,
         temp_min: 269.703,
         temp_max: 269.703,
         pressure: 1026.79,
         sea_level: 1030.42,
         grnd_level: 1026.79,
         humidity: 100,
         temp_kf: 0 },
      weather:
       [ { id: 800,
           main: 'Clear',
           description: 'sky is clear',
           icon: '01n' } ],
      clouds: { all: 0 },
      wind: { speed: 3.81, deg: 297.501 },
      rain: {},
      snow: {},
      sys: { pod: 'n' },
      dt_txt: '2016-01-25 00:00:00'
    }];

    buildForecastList(sampleForecastList, new Date(1453500000)).should.eql([
      {
        dt: 1453593600,
        temperature: 271.168,
        condition: 3 // snow
      },
      {
        dt: 1453680000,
        temperature: 269.703,
        condition: 5 // clear
      },
    ]);
  });
});
