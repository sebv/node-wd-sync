// assumes that selenium server is running

var wdSync; 
try {
  wdSync = require('wd-sync');
} catch (err) {
  wdSync = require('../../index');
}

// 5/ retrieving the current browser

var client = wdSync.remote()
    , browser = client.browser
    , sync = client.sync;

var myOwnGetTitle = function() {
  return wdSync.current().title();
};

sync( function() {
  
  browser.init( {browserName: 'firefox'} );
  
  browser.get("http://google.com");
  console.log(myOwnGetTitle());
  
  browser.quit();
  
});
