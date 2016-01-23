var convertCondition = require('../conditionConverter');

/**
 * Converts a nested weather object into a single level weather object
 *
 * @param {Object} curWeather
 * @returns {Object} currentWeather - selected values from curWeather
 */
function currentWeatherUtil(curWeather) {
  var currentWeather = {};

  currentWeather.temperature = curWeather.main.temp;
  currentWeather.condition = convertCondition(curWeather.weather[0].id);
  currentWeather.dt = curWeather.dt;
  currentWeather.sunrise = curWeather.sys.sunrise;
  currentWeather.sunset  = curWeather.sys.sunset;
  currentWeather.cityName = curWeather.name;

  return currentWeather;
}

module.exports = currentWeatherUtil;
