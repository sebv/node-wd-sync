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

All the methods from [wd](http://github.com/admc/wd) are available. 

The browser function must to be run within a Wd block. This 
block holds the fiber environment. 

The 'executeAsync' and 'safeExecuteAsync' methods may still be run asynchronously.

```javascript
// assumes that selenium server is running

var wd = require('wd-sync').wd
, Wd = require('wd-sync').Wd;

// 1/ simple Wd example 

browser = wd.remote();

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
  
  console.log(browser.elementByNameIfExists('not_exists')); // undefined
  
  browser.quit();

});

```


## Sauce Labs example

Remote testing with [Sauce Labs](http://saucelabs.com) works. 


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
  accessKey
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


## Headless example

This uses the [wd-zombie](http://sebv/node-wd-zombie.git) module,
which implements the wd interface using [Zombie](http://github.com/assaf/zombie). 

IMPORTANT: A 'wd-zombie' dependenciy must be added to your project package.json.

In this mode, no need to run the Selenium server.

```coffeescript
// a dependency to 'wd-zombie' must be configured in package.json  

var wd = require('wd-sync').wd
, Wd = require('wd-sync').Wd;

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

// 4/ simple WdWrap example

describe("WdWrap", function() {

  describe("passing browser", function() {    
    var browser;
    
    before(function(done) {
      browser = wd.remote();
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

Using the 'pre' option like in the mocha sample below may still be beneficial, althought not as good as the 
CoffeeScript syntax.

```javascript
// Assumes that the selenium server is running
// Use 'mocha' to run (npm install -g mocha)

var wd = require('wd-sync').wd
, Wd = require('wd-sync').Wd;

should = require('should');

// 5/ leaner WdWrap syntax

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

// 6/ retrieving the current browser

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

```

## supported methods

* [full JsonWireProtocol mapping](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwiremap-all.md)
* [supported JsonWireProtocol mapping](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwiremap-supported.md)


## doc 

* [CoffeeScript](http://github.com/sebv/node-wd-sync/blob/master/doc/COFFEE-DOC.md)
* [JavaScript](http://github.com/sebv/node-wd-sync/blob/master/doc/JS-DOC.md)
* [JsonWireProtocol official doc](http://code.google.com/p/selenium/wiki/JsonWireProtocol)

Doc modifications must be done in the doc/template directory, then run 'cake doc:build'.


## tests

### local / selenium server: 

1/ starts the selenium server with chromedriver:
```  
java -jar selenium-server-standalone-2.21.0.jar -Dwebdriver.chrome.driver=<PATH>/chromedriver
```

2/ run tests
```
cake test 
```

### remote / Sauce Labs 

1/ follow the instructions [here](http://github.com/sebv/node-wd-sync/blob/master/test/sauce/README.md) to
configure your username and access key.
 

2/ run tests
```
cake test:sauce
```

### headless 
```
cake test:headless
```


## selenium server

Download the Selenium server [here](http://seleniumhq.org/download/).

Download the Chromedriver [here](http://code.google.com/p/chromedriver/downloads/list).

To start the server:

```
java -jar selenium-server-standalone-2.21.0.jar -Dwebdriver.chrome.driver=./chromedriver
```


## per methods tests / code example

check in [wd-by-method-test.js](https://github.com/sebv/node-wd-sync/blob/master/test/unit/wd-by-method-test.js)