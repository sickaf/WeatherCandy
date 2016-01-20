/**
 * Builds weatherQueryString paramaters with parameters from client
 *
 * @param {Number} cityID
 * @param {Number} latitude
 * @param {Number} longitude
 * @param {String} cityName
 * @returns {String|null} weather query string
 */
function buildWeatherQueryParams(cityID, latitude, longitude, cityName) {
  if (cityID) {
    return 'id=' + cityID;
  } else if (latitude && longitude) {
    return 'lat=' + latitude + '&lon=' + longitude
  } else if (cityName) {
    return 'q=' + cityName;
  } else {
    // not enough info
    return null;
  }
}

module.exports = buildWeatherQueryParams;
