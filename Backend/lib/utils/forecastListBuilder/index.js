var convertCondition = require('../conditionConverter');

/**
 * Extracts weather data points for a given time period
 *
 * @param {Array} forecastResponseList - list of objects containing weather data
 * @param {Number} currentDate
 * @returns {Array} modified list of weather data
 */
function buildForecastList(forecastResponseList, currentDate) {
  var result = [];

  forecastResponseList.forEach(function(entry) {
    var dateOfForecast = new Date(entry["dt"]),
        forecastUnit = {};

    if ((currentDate.getTime() / 1000) < dateOfForecast.getTime()) {
      forecastUnit.dt = entry.dt;
      forecastUnit.temperature = entry.main.temp;
      forecastUnit.condition = convertCondition(entry.weather[0].id);
      result.push(forecastUnit);
    };
  });

  return result;
}

module.exports = buildForecastList;
