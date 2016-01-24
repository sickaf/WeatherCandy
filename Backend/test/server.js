var should = require('chai').should(),
    request = require('supertest'),
    app = require('../index');

describe('server test suite', function() {
  describe('/api tests', function() {
    it('should respond with categories from /api/categories', function(done) {
      request(app)
      .get('/api/categories')
      .end(function(err, res) {
        var responseBody = res.body;

        responseBody.hasOwnProperty('categories').should.equal(true);
        Array.isArray(responseBody.categories).should.equal(true);

        done();
      });
    });

    it('should have 4 keys: `id` `displayName` `subreddit` `background_image_url', function(done) {
      request(app)
      .get('/api/categories')
      .end(function(err, res) {
        var firstCategory = res.body.categories[0];

        Object.keys(firstCategory).length.should.equal(4);
        firstCategory.hasOwnProperty('id').should.equal(true);
        firstCategory.hasOwnProperty('displayName').should.equal(true);
        firstCategory.hasOwnProperty('background_image_url').should.equal(true);

        done();
      });
    });
  });
});
