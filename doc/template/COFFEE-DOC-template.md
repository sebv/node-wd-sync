# wd-sync with CofffeeScript

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

The browser functions must to be run within a Wd block. This 
block holds the fiber environment. The Wd block context is set to the browser, 
so that the browser methods may be accessed using '@'.

The 'executeAsync' and 'safeExecuteAsync' methods may still be run asynchronously.

```coffeescript
{1wdsimplecoffee}
```

## Sauce Labs example

Remote testing with [Sauce Labs](http://saucelabs.com) works. 

```coffeescript
{2wdsaucelabscoffee}
```

## Headless example

This uses the [wd-zombie](http://sebv/node-wd-zombie.git) module,
which implements the wd interface using [Zombie](http://github.com/assaf/zombie). 

In this mode, no need to run the Selenium server.

```coffeescript
{3wdheadlesscoffee}
```

## WdWrap

WdWrap is a wrapper around Wd. It takes a function as argument and return a function like below:

```coffeescript
(done) ->
  // execute function
  done()
```

It's main use is within an asynchronous test framework, when only using this synchronous api is used, 
It manages the done callback for you.
 
A 'pre' method may also be specified. It is called before the Wd block starts, in the original 
context (In Mocha, it can be used to configure timeouts). 

The example below is using the mocha test framework.

```coffeescript
{4wdwrapmochasimplecoffee}
```

## a slightly leaner syntax

When there is a browser parameter and no callback, Wd or WdWrap
returns a version of itself with a browser default added.

Wd sample below:

```coffeescript
{5wdleanercoffee}
```

WdWrap sample below, using the mocha test framework:
```coffeescript
{6wdwrapmochaleanercoffee}
```


## to retrieve the browser currently in use

The current browser is automatically stored in the Fiber context.
It can be retrieved with the wd.current() function. 

This is useful when writing test helpers.

```coffeescript
{7wdcurrentbrowsercoffee}
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

check in [wd-by-method-test.coffee](https://github.com/sebv/node-wd-sync/blob/master/test/unit/wd-by-method-test.coffee)