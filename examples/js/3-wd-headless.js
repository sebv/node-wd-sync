// a dependency to 'wd-zombie' must be configured in package.json  

var wdSync; 
try {
  wdSync = require('wd-sync');
} catch (err) {
  wdSync = require('../../index');
}

// 3/ headless Wd example 

var client = wdSync.headless()
    , browser = client.browser
    , sync = client.sync;

sync( function() {
  
  browser.init();
  
  browser.get("http://saucelabs.com/test/guinea-pig");
  console.log(browser.title());
  
  divEl = browser.elementByCss('#i_am_an_id');
  console.log(browser.text(divEl));
  
  var textField = browser.elementById('i_am_a_textbox');
  browser.type(textField, "Hello World");
  browser.type(textField, wdSync.SPECIAL_KEYS.Return);
    
  browser.quit();

});
