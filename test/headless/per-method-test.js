// Generated by CoffeeScript 1.3.3
(function() {
  var Express, test, _ref;

  _ref = require('../common/per-method-test-base'), test = _ref.test, Express = _ref.Express;

  describe("wd-sync", function() {
    return describe("headless", function() {
      var express;
      express = new Express;
      before(function(done) {
        express.start(done);
        return done(null);
      });
      after(function(done) {
        express.stop(done);
        return done(null);
      });
      return test('headless', 'zombie');
    });
  });

}).call(this);
