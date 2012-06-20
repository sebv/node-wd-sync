// Generated by CoffeeScript 1.3.3
(function() {
  var passingBrowser, withoutPassingBrowser, _ref;

  _ref = require('../common/wd-wrap-test-base'), passingBrowser = _ref.passingBrowser, withoutPassingBrowser = _ref.withoutPassingBrowser;

  describe("wd-sync", function() {
    return describe("headless", function() {
      passingBrowser({
        type: 'headless'
      });
      return withoutPassingBrowser({
        type: 'headless'
      });
    });
  });

}).call(this);
