// assumes that selenium server is running

var wdSync;
try {
  wdSync = require('wd-sync');
} catch (err) {
  wdSync = require('../../index');
}

// 1/ simple Wd example

var client = wdSync.remote()
    , browser = client.browser
    , sync = client.sync;

sync( function() {

  console.log("server status:", browser.status());
  browser.init( { browserName: 'firefox'} );
  console.log("session id:", browser.getSessionId());
  console.log("session capabilities:", browser.sessionCapabilities());

  browser.get("http://google.com");
  console.log(browser.title());

  var queryField = browser.elementByName('q');
  browser.type(queryField, "Hello World");
  browser.type(queryField, "\n");

  browser.setWaitTimeout(3000);
  browser.elementByCss('#ires'); // waiting for new page to load
  console.log(browser.title());

  console.log(browser.elementByNameIfExists('not_exists')); // undefined

  browser.quit();

});
