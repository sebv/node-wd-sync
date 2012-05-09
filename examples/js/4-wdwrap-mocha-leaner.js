// Assumes that the selenium server is running
// Use 'mocha' to run (npm install -g mocha)

var wd, WdWrap; 
try {
  wd = require('wd-sync').wd;
  WdWrap = require('wd-sync').WdWrap;  
} catch (err) {
  wd = require('../../index').wd;
  WdWrap = require('../../index').WdWrap;  
}

should = require('should');

// 4/ leaner WdWrap syntax

describe("WdWrap", function() {
  describe("passing browser", function() {
    var browser;
    
    // do this only once
    WdWrap = WdWrap({
      pre: function() { this.timeout(30000); }
    });
    
    before( function(done) {
      browser = wd.remote();
      done();
    });
    
    it("should work", WdWrap(function() {
      
      browser.init();
      
      browser.get("http://google.com");
      browser.title().toLowerCase().should.include('google');
      
      var queryField = browser.elementByName('q');
      browser.type(queryField, "Hello World");
      browser.type(queryField, "\n");
      
      browser.setWaitTimeout(3000);
      browser.elementByCss('#ires'); // waiting for new page to load
      browser.title().toLowerCase().should.include('hello world');
      
      browser.quit();
      
    }));
  });
});
