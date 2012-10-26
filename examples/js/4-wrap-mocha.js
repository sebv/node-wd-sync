// Assumes that the selenium server is running
// Use 'mocha' to run (npm install -g mocha)

var wdSync; 
try {
  wdSync = require('wd-sync');
} catch (err) {
  wdSync = require('../../index');
}

var should = require('should');

// 4/ wrap example

describe("WdWrap", function() {

  describe("passing browser", function() {    
    var browser
        , wrap = wdSync.wrap({
          with: function() {return browser}
          , pre: function() { this.timeout(30000); } //optional
        });

    
    before(function(done) {
      var client = wdSync.remote();
      browser = client.browser;
      done();
    });
    
    it("should work", wrap(function() { // may also pass a pre here

      browser.init();

      browser.get("http://google.com");
      browser.title().toLowerCase().should.include('google');

      var  queryField = browser.elementByName('q');
      browser.type(queryField, "Hello World");
      browser.type(queryField, "\n");

      browser.setWaitTimeout(3000);
      browser.elementByCss('#ires'); // waiting for new page to load
      browser.title().toLowerCase().should.include('hello world');

      browser.quit();

    }));
  });
});
