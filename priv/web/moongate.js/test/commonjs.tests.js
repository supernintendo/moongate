var expect = require('chai').expect;
var mylib = require('../dist/Moongate.min.js');

describe('Client', function () {
  it('is contained within Moongate as CommonJS', function () {
    expect(mylib).to.be.an('object');
    expect(mylib.Client).to.not.be.null;
  });

  it('can be instantiated', function () {
    var t = new mylib.Client({});
    expect(t).to.be.defined;
  });
});
