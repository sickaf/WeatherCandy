function picsUtil() {
  // nuthin
}

/**
 * @param {Object}
 * @returns {String}
 */
function getPicUrl(pic) {
  var picExists = pic && pic.data && pic.data.hasOwnProperty('url'); // '0' is falsy :(

  return picExists ? pic.data.url : '';
}

/**
 * Remove gallery links and gifs. This function should be used in Array.prototype.filter
 *   as the filter function
 *
 * @param {Object} pic
 * @returns {Boolean} true if the pic url does not contain `.gif`, `.gifv` or `gallery`
 */
function picUrlFilter(pic) {
  var picUrl = getPicUrl(pic);

  return !(isGifOrGifv(picUrl) || isGallery(picUrl));
}

/**
 * Extracts the image id from after the last slash in an image url
 *
 * @param {String} picUrl
 * @returns {String} image id
 */
function getPicImageId(picUrl) {
  var slashIndex = picUrl.lastIndexOf('/');

  return picUrl.substring(slashIndex + 1);
}

/**
 * Returns the `.jpg`, `.png` or imgur url to the client
 *
 * @param {Object} pic
 * @returns {String} url to be sent to the client
 */
function getPicUrlForClient(pic) {
  var picUrl = getPicUrl(pic),
      url = '';

  if (isJpg(picUrl) || isPng(picUrl)) {
    url = picUrl;
  } else if (picUrl.length > 0) {
    url = 'http://i.imgur.com/' + getPicImageId(picUrl) + '.jpg';
  }

  return url;
}

// following functions all regex for file extensions or file name contents

function isGifOrGifv(picUrl) {
  return /\.gifv?$/.test(picUrl);
}

function isGallery(picUrl) {
  return /gallery/.test(picUrl);
}

function isJpg(picUrl) {
  return /\.jpg$/.test(picUrl);
}

function isPng(picUrl) {
  return /\.png$/.test(picUrl);
}

module.exports = picsUtil;
picsUtil.isGifOrGifv = isGifOrGifv;
picsUtil.isGallery = isGallery;
picsUtil.isJpg = isJpg;
picsUtil.isPng = isPng;
picsUtil.getPicUrlForClient = getPicUrlForClient;
picsUtil.getPicImageId = getPicImageId;
picsUtil.getPicUrl = getPicUrl;
picsUtil.picUrlFilter = picUrlFilter;
