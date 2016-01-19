var should = require('chai').should(),
    convertCondition = require('../../../../lib/utils/conditionConverter');

describe('weather condition converter test suite', function() {
  it('converts `201 to 0 [storm]', function() {
    convertCondition(201).should.equal(0);
  });

  it('converts `321 to 1 [drizzle]', function() {
    convertCondition(321).should.equal(1);
  });

  it('converts `500 to 1 [rain]', function() {
    convertCondition(500).should.equal(2);
  });

  it('converts `616 to 1 [snow]', function() {
    convertCondition(616).should.equal(3);
  });

  it('converts `741 to 1 [haze]', function() {
    convertCondition(741).should.equal(4);
  });

  it('converts `952 to 1 [clear]', function() {
    convertCondition(952).should.equal(5);
  });

  it('converts `803 to 1 [partlyCloudy]', function() {
    convertCondition(803).should.equal(6);
  });

  it('converts `804 to 1 [overcast]', function() {
    convertCondition(804).should.equal(7);
  });
});
