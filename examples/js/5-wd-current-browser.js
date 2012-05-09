// assumes that selenium server is running

var wd, Wd; 
try {
  wd = require('wd-sync').wd;
  Wd = require('wd-sync').Wd;  
} catch (err) {
  wd = require('../../index').wd;
  Wd = require('../../index').Wd;  
}

// 5/ retrieving the current browser

var browser = wd.remote();

// do this once
Wd = Wd( {with: browser} );

var myOwnGetTitle = function() {
  return wd.current().title();
};

Wd( function() {
  
  browser.init( {browserName: 'firefox'} );
  
  browser.get("http://google.com");
  console.log(myOwnGetTitle());
  
  browser.quit();
  
});
