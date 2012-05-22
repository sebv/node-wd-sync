var wd, Wd; 
try {
  wd = require('wd-sync').wd;
  Wd = require('wd-sync').Wd;  
} catch (err) {
  wd = require('../../index').wd;
  Wd = require('../../index').Wd;  
}

// 3/ headless Wd example 

browser = wd.headless();

Wd( function() {
  
  browser.init();
  
  browser.get("http://saucelabs.com/test/guinea-pig");
  console.log(browser.title());
  
  divEl = browser.elementByCss('#i_am_an_id');
  console.log(browser.text(divEl));
  
  var textField = browser.elementById('i_am_a_textbox');
  browser.type(textField, "Hello World");
  browser.type(textField, wd.SPECIAL_KEYS.Return);
    
  browser.quit();

});
