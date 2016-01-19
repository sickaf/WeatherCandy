function convertCondition(original) {
  var storm = [200, 201, 202, 210, 211, 212, 221, 230, 231, 232, 900, 901, 902, 957, 958, 959, 960, 961, 962,771, 781]; //0
  var drizzle = [300, 301, 302, 310, 311, 312, 313, 314, 321, 701]; //1
  var rain = [500, 501,502,503, 504, 511, 520, 521, 522, 531, 906]; //2
  var snow = [600, 601, 602, 611, 612, 615, 616, 620, 621, 622]; //3
  var haze = [711, 721, 731, 741, 751, 761, 762]; //4
  var clear = [800, 903, 904, 905, 951, 952, 954, 954, 955, 956]; //5 todo(marcus): lmao 954 twice
  var partlyCloudy = [801, 802, 803]; //6
  var overcast = [804]; //7

  var conditions = [storm, drizzle, rain, snow, haze, clear, partlyCloudy, overcast];
  for (var x = 0; x < conditions.length; x++)
  {
    var conditionSet = conditions[x];
    for (var i = 0; i<conditionSet.length; i++) {
      if (original == conditionSet[i]) {
        return x;
      }
    }
  }
  console.log("convertCondition couldnt find a match");
  return original;
}

module.exports = convertCondition;
