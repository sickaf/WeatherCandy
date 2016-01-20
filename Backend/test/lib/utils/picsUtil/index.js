var should = require('chai').should(),
    isGifOrGifv = require('../../../../lib/utils/picsUtil').isGifOrGifv,
    isGallery = require('../../../../lib/utils/picsUtil').isGallery,
    isJpg = require('../../../../lib/utils/picsUtil').isJpg,
    isPng = require('../../../../lib/utils/picsUtil').isPng,
    getPicUrl = require('../../../../lib/utils/picsUtil').getPicUrl,
    getPicImageId = require('../../../../lib/utils/picsUtil').getPicImageId,
    getPicUrlForClient = require('../../../../lib/utils/picsUtil').getPicUrlForClient,
    picUrlFilter = require('../../../../lib/utils/picsUtil').picUrlFilter;

describe('pics util test suite', function() {
  it('should return true if the file extension is `.gif`', function() {
    isGifOrGifv('test.gif').should.equal(true);
  });

  it('should return true if the file extension is `.gifv`', function() {
    isGifOrGifv('test.gifv').should.equal(true);
  });

  it('should return true if the file name contains `gallery`', function() {
    isGallery('test.gallery').should.equal(true);
  });

  it('should return true if the file extension is `.jpg`', function() {
    isJpg('test.jpg').should.equal(true);
  });

  it('should return true if the file extension is `.png`', function() {
    isPng('test.png').should.equal(true);
  });

  it('should return false for all of these', function() {
    isGifOrGifv('test.upfam').should.equal(false);
    isGallery('test.devonsucks').should.equal(false);
    isJpg('test.png').should.equal(false);
    isPng('test.jpg').should.equal(false);
  });

  it('should get the pic url from a pic obj', function() {
    var pic = {
      data: {
        url: 'test.gif'
      }
    };

    getPicUrl(pic).should.equal('test.gif');
  });

  it('should return false if a picture url from a picture object ends in `.gif`', function() {
    var pic = {
      data: {
        url: 'test.gif'
      }
    };

    picUrlFilter(pic).should.equal(false);
  });

  it('should filter this array of pic objects', function() {
    var arr = [
      {
        data: {
          url: 'test.gif'
        }
      },
      {
        data: {
          url: 'test.gifv'
        }
      },
      {
        data: {
          url: 'test.gallery'
        }
      },
      {
        data: {
          url: 'ayyyyylmao'
        }
      },
      {
        data: {
          url: 'supfam.gif'
        }
      }
    ];

    arr.filter(picUrlFilter).should.eql([{
      data: {url: 'ayyyyylmao'}
    }]);
  });

  it('should get the image id from this url', function() {
    var picUrl = 'http://picturewebsite.com/abc123';

    getPicImageId(picUrl).should.equal('abc123');
  });

  it('should get a jpg picture for the client', function() {
    var pic = {
      data: {
        url: 'test.jpg'
      }
    };

    getPicUrlForClient(pic).should.equal('test.jpg');
  });

  it('should get a picture with an id for the client', function() {
    var pic = {
      data: {
        url: '//image/abc123'
      }
    };

    getPicUrlForClient(pic).should.equal('http://i.imgur.com/abc123.jpg');
  });
});
