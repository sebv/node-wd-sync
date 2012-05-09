// assumes that selenium server is running

var wd, Wd; 
try {
  wd = require('wd-sync').wd;
  Wd = require('wd-sync').Wd;  
} catch (err) {
  wd = require('../../index').wd;
  Wd = require('../../index').Wd;  
}

// 1/ simple Wd example 

browser = wd.remote({mode: 'sync'});

Wd( function() {
  
  console.log("server status:", browser.status());
  browser.init( { browserName: 'firefox'} );
  console.log("session capabilities:", browser.sessionCapabilities());
  
  browser.get("http://google.com");
  console.log(browser.title());
  
  var queryField = browser.elementByName('q');
  browser.type(queryField, "Hello World");
  browser.type(queryField, "\n");
  
  browser.setWaitTimeout(3000);
  browser.elementByCss('#ires'); // waiting for new page to load
  console.log(browser.title());
  
  console.log(browser.elementByName('not_exists')); // undefined
  
  browser.quit();

});
