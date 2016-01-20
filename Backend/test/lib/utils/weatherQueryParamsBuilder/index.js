var should = require('chai').should(),
    buildWeatherQueryParams = require('../../../../lib/utils/weatherQueryParamsBuilder');

describe('weather query builder test suite', function() {
  it('should return `null` if all paramaters are `null`', function() {
    // can't use `.should` off of a `null` value, had to write it this way
    (buildWeatherQueryParams(null, null, null, null) === null).should.equal(true);
  });

  it('should return `null` if all paramaters are `undefined`', function() {
    // can't use `.should` off of a `null` value, had to write it this way
    (buildWeatherQueryParams(undefined, undefined, undefined, undefined) === null).should.equal(true);
  });

  it('should return `"id="+cityId` when `cityId` exists', function() {
    buildWeatherQueryParams(123, undefined, undefined, undefined).should.equal('id=123');
  });

  it('should return `"lat="+lat+"&lon="+lon` when only `lat` & `lon` exist', function() {
    buildWeatherQueryParams(undefined, 69, 420, undefined).should.equal('lat=69&lon=420');
  });

  it('should return `"q="+cityName` when only `cityName` exists', function() {
    buildWeatherQueryParams(undefined, undefined, undefined, 'updog').should.equal('q=updog');
  });
});
