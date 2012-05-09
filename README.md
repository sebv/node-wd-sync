# wd-sync

A synchronous version with a nice api of [wd](http://github.com/admc/wd), 
the lightweight  [WebDriver / Selenium2](http://seleniumhq.org/projects/webdriver/) 
client for node.js, built using  [node-fibers](http://github.com/laverdet/node-fibers).

Remote testing with [Sauce Labs](http://saucelabs.com) also works.

## install

```
npm install wd-sync
```

## code samples

### CoffeeScript

```coffeescript
# assumes that selenium server is running

{wd,Wd} = require 'wd-sync'
  
# 1/ simple Wd example 

browser = wd.remote(mode:'sync')

Wd with:browser, ->        
  console.log "server status:", @status()
  @init browserName:'firefox'
  console.log "session capabilities:", @sessionCapabilities()

  @get "http://google.com"
  console.log @title()          

  queryField = @elementByName 'q'
  @type queryField, "Hello World"  
  @type queryField, "\n"

  @setWaitTimeout 3000      
  @elementByCss '#ires' # waiting for new page to load
  console.log @title()

  console.log @elementByName 'not_exists' # undefined

  @quit()  

```        

### JavaScript

```javascript
// assumes that selenium server is running

var wd = require('wd-sync').wd
, Wd = require('wd-sync').Wd;

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

``` 

## doc 

## examples

* [CoffeeScript](http://github.com/sebv/node-wd-sync/tree/master/examples/coffee)
* [JavaScript](http://github.com/sebv/node-wd-sync/tree/master/examples/js)


## tests

### local / selenium server: 

```
cake test 
```

### remote / Sauce Labs 

```
cake test:sauce
```

