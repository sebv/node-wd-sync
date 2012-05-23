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
{1wdsimplejs}
```


## Sauce Labs example

Remote testing with [Sauce Labs](http://saucelabs.com) works. 


```javascript
{2wdsaucelabsjs}
```


## Headless example

This uses the [wd-zombie](http://sebv/node-wd-zombie.git) module,
which implements the wd interface using [Zombie](http://github.com/assaf/zombie). 

IMPORTANT: A 'wd-zombie' dependency must be configured in package.json.

In this mode, no need to run the Selenium server.

```coffeescript
{3wdheadlessjs}
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
{4wdwrapmochasimplejs}
```

## a slightly leaner syntax (or the lack of it)

Since JavaScript has no short equivalent for the '@' alias, most this section is not relevant in JavaScript.  

Using the 'pre' option like in the mocha sample below may still be beneficial, althought not as good as the 
CoffeeScript syntax.

```javascript
{5wdwrapmochaleanerjs}
```


## to retrieve the browser currently in use

The current browser is automatically stored in the Fiber context.
It can be retrieved with the wd.current() function. 

This is useful when writing test helpers.

Don't forget to set the 'use' option in the block, or globably like in the sample below. 

```javascript
{6wdcurrentbrowserjs}
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