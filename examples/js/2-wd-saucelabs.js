// configure saucelabs username/access key here
var username = '<USERNAME>'
, accessKey = '<ACCESS KEY>';

var wd, Wd; 
try {
  wd = require('wd-sync').wd;
  Wd = require('wd-sync').Wd;  
} catch (err) {
  wd = require('../../index').wd;
  Wd = require('../../index').Wd;  
}

// 2/ wd saucelabs example 

desired = {
  platform: "LINUX",
  name: "wd-sync demo",
  browserName: "firefox"
};

browser = wd.remote(
  "ondemand.saucelabs.com", 
  80, 
  username, 
  accessKey, 
  { mode: 'sync' }
);

Wd( function() {

  console.log("server status:", browser.status());
  browser.init(desired);
  console.log("session capabilities:", browser.sessionCapabilities());

  browser.get("http://google.com");
  console.log(browser.title());

  var queryField = browser.elementByName('q');
  browser.type(queryField, "Hello World");
  browser.type(queryField, "\n");

  browser.setWaitTimeout(3000);
  browser.elementByCss('#ires'); // waiting for new page to load
  console.log(browser.title());

  browser.quit();

});

