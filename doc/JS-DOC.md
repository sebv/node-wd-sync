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

The browser functions must to be run within a `sync` block. This 
block holds the fiber environment. 

The `executeAsync` and `safeExecuteAsync` methods may still be run asynchronously.

```javascript
// assumes that selenium server is running

var wdSync = require('wd-sync');

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

```


## Sauce Labs example

Remote testing with [Sauce Labs](http://saucelabs.com) works. 


```javascript
// configure saucelabs username/access key here
var username = process.env.SAUCE_USERNAME || '<USERNAME>'
, accessKey = process.env.SAUCE_KEY || '<ACCESS KEY>';

var wdSync = require('wd-sync');

// 2/ wd saucelabs example

desired = {
  platform: "LINUX",
  name: "wd-sync demo",
  browserName: "firefox"
};

var client = wdSync.remote(
  "ondemand.saucelabs.com",
    80,
    username,
    accessKey)
  , browser = client.browser
  , sync = client.sync;

sync( function() {

  console.log("server status:", browser.status());
  browser.init(desired);
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

  browser.quit();

});


```

## wrap

`wrap` is a wrapper around `sync` within so it nicely integrates with
test frameworks like Mocha. `wrap` manages the done callback for you.
 
`pre` functions may be specified globally or within each tests.
They are called  called before the `wrap` block starts, in the original 
context (In Mocha, it may be used to configure timeouts). 

The example below is using the mocha test framework.

```javascript
// Assumes that the selenium server is running
// Use 'mocha' to run (npm install -g mocha)

var wdSync = require('wd-sync');

var should = require('should');

// 4/ wrap example

describe("WdWrap", function() {

  describe("passing browser", function() {    
    var browser
        , wrap = wdSync.wrap({
          with: function() {return browser}
          , pre: function() { this.timeout(30000); } //optional
        });

    
    before(function(done) {
      var client = wdSync.remote();
      browser = client.browser;
      done();
    });
    
    it("should work", wrap(function() { // may also pass a pre here

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

## to retrieve the browser currently in use

The current browser is automatically stored in the Fiber context.
It can be retrieved with the `wd.current()` function. 

This is useful when writing test helpers.

```javascript
// assumes that selenium server is running

var wdSync = require('wd-sync');

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

```

## supported methods

* [supported JsonWireProtocol mapping](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwire-mapping.md)
* [full JsonWireProtocol mapping](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwire-full-mapping.md)


## doc 

* [CoffeeScript](http://github.com/sebv/node-wd-sync/blob/master/doc/COFFEE-DOC.md)
* [JavaScript](http://github.com/sebv/node-wd-sync/blob/master/doc/JS-DOC.md)
* [JsonWireProtocol official doc](http://code.google.com/p/selenium/wiki/JsonWireProtocol)

Doc modifications must be done in the doc/template directory, then run `cake doc:build`.


## tests

### local / selenium server: 

1/ starts the selenium server with chromedriver:
```  
java -jar selenium-server-standalone-2.21.0.jar -Dwebdriver.chrome.driver=<PATH>/chromedriver
```

2a/ run tests
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

## selenium server

Download the Selenium server [here](http://seleniumhq.org/download/).

Download the Chromedriver [here](http://code.google.com/p/chromedriver/downloads/list).

To start the server:

```
java -jar selenium-server-standalone-2.25.0.jar -Dwebdriver.chrome.driver=./chromedriver
```

