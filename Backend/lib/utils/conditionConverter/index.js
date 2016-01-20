/**
 * Converts a weather code into an integer value for the client
 *
 * @param {Number} original
 * @returns {Number} converted condition
 */
function convertCondition(original) {
  var storm = [200, 201, 202, 210, 211, 212, 221, 230, 231, 232, 900, 901, 902, 957, 958, 959, 960, 961, 962, 771, 781], //0
      drizzle = [300, 301, 302, 310, 311, 312, 313, 314, 321, 701], //1
      rain = [500, 501,502,503, 504, 511, 520, 521, 522, 531, 906], //2
      snow = [600, 601, 602, 611, 612, 615, 616, 620, 621, 622], //3
      haze = [711, 721, 731, 741, 751, 761, 762], //4
      clear = [800, 903, 904, 905, 951, 952, 954, 955, 956], //5
      partlyCloudy = [801, 802, 803], //6
      overcast = [804], //7
      conditions = [storm, drizzle, rain, snow, haze, clear, partlyCloudy, overcast];

  for (var i = 0; i < conditions.length; i++) {
    if (conditions[i].indexOf(original) !== -1) {
      return i;
    }
  }
  console.log("convertCondition couldnt find a match");
  return original;
}

module.exports = convertCondition;
