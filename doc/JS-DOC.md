# wd-sync with JavaScript

A synchronous version with a nice api of [wd](http://github.com/admc/wd), 
the lightweight  [WebDriver / Selenium2](http://seleniumhq.org/projects/webdriver/) 
client for node.js, built using  [node-fibers](http://github.com/laverdet/node-fibers).

Remote testing with [Sauce Labs](http://saucelabs.com) also works.

## install

```
npm install wd-sync
```


## usage

When creating a new browser with remote, an extra 'mode' option need to be 
passed.

All the methods from [wd](http://github.com/admc/wd) are available. The element retrieval 
methods have been modified to return 'undefined' when the element is not found rather than
throw a 'Not Found' error.

In sync mode, the browser function must to be run within a Wd block. This 
block holds the fiber environment. 

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


## Sauce Labs example

Remote testing with [Sauce Labs](http://saucelabs.com) works. The extra 'mode'
option is also needed here.

```javascript
// configure saucelabs username/access key here
var username = '<USERNAME>'
, accessKey = '<ACCESS KEY>';

var wd = require('wd-sync').wd
, Wd = require('wd-sync').Wd;

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


```


## WdWrap

WdWrap is a wrapper around Wd. It takes a function as argument and return a function like below:

```javascript
(function(done) {
  // execute function
  return done();
});
```

It's main use is within an asynchronous test framework, when only using this synchronous api is used, 
It manages the done callback for you.
 
A 'pre' method may also be specified. It is called before the Wd block starts, in the original 
context (In Mocha, it can be used to configure timeouts). 

The example below is using the mocha test framework.

```javascript
// Assumes that the selenium server is running
// Use 'mocha' to run (npm install -g mocha)

var wd = require('wd-sync').wd
, Wd = require('wd-sync').Wd;

should = require('should');

// 3/ simple WdWrap example

describe("WdWrap", function() {

  describe("passing browser", function() {    
    var browser;
    
    before(function(done) {
      browser = wd.remote({
        mode: 'sync'
      });
      done();
    });
    
    it("should work", WdWrap({
      pre: function() { this.timeout(30000); }
    }, function() {

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

```

## a slightly leaner syntax (or the lack of it)

Since JavaScript has no short equivalent for the '@' alias, most this section is not relevant in JavaScript.  

Using the 'pre' option like in the mocha sample below may still be beneficial, althought not as good as the coffee
script syntax.

```javascript
// Assumes that the selenium server is running
// Use 'mocha' to run (npm install -g mocha)

var wd = require('wd-sync').wd
, Wd = require('wd-sync').Wd;

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
      browser = wd.remote({ mode: 'sync' });
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

```


## to retrieve the browser currently in use

The current browser is automatically stored in the Fiber context.
It can be retrieved with the wd.current() function. 

This is useful when writing test helpers.

Don't forget to set the 'use' option in the block, or globably like in the sample below. 

```javascript
// assumes that selenium server is running

var wd = require('wd-sync').wd
, Wd = require('wd-sync').Wd;

// 5/ retrieving the current browser

var browser = wd.remote( {mode: 'sync'} );

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

```

## modes

Check [make-sync](http://github.com/sebv/node-make-sync/blob/master/README.markdown#modes) for more details. 
Probably best to use the 'sync' mode. 

A few methods have the mixed-args mode forced on them.

```javascript
{mode: 'sync'}
{mode: 'async'}

{mode: ['mixed']}
{mode: ['mixed','args']}

{mode: ['mixed','fibers']}

# methods forced to ['mixed','args']
['executeAsync', 'element', 'getAttribute', 'text']
```


## Selenium server

Download the Selenium server [here](http://seleniumhq.org/download/).

Download the Chromedriver [here](http://code.google.com/p/chromedriver/downloads/list).

To start the server:

```
java -jar selenium-server-standalone-2.21.0.jar -Dwebdriver.chrome.driver=./chromedriver
```


## per methods tests / code example

check in [wd-by-method-test.js](https://github.com/sebv/node-wd-sync/blob/master/test/unit/wd-by-method-test.js)