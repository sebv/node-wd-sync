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
{1wdsimplejs}
```


## Sauce Labs example

Remote testing with [Sauce Labs](http://saucelabs.com) works. 


```javascript
{2wdsaucelabsjs}
```

## wrap

`wrap` is a wrapper around `sync` within so it nicely integrates with
test frameworks like Mocha. `wrap` manages the done callback for you.
 
`pre` functions may be specified globally or within each tests.
They are called  called before the `wrap` block starts, in the original 
context (In Mocha, it may be used to configure timeouts). 

The example below is using the mocha test framework.

```javascript
{4wrapmochajs}
```

## to retrieve the browser currently in use

The current browser is automatically stored in the Fiber context.
It can be retrieved with the `wd.current()` function. 

This is useful when writing test helpers.

```javascript
{5wdcurrentbrowserjs}
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

