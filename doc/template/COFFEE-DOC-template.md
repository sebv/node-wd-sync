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

The browser functions must to be run within a `sync` block. This 
block holds the fiber environment. The `sync` block context is set to the browser, 
so that the browser methods may be accessed using `@`.

The `executeAsync` and `safeExecuteAsync` methods may still be run asynchronously.

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

IMPORTANT: A wd-zombie dependency must be configured in package.json.

In this mode, no need to run the Selenium server.

```coffeescript
{3wdheadlesscoffee}
```

notes regarding headless/zombie:
- only worth using for simple pages, not relying heavily on Javacripts.   
- the headless functionality wont be maintained/improved, at least until Zombie 2 is stable. 

## wrap

`wrap` is a wrapper around `sync` within so it nicely integrates with
test frameworks like Mocha. `wrap` manages the done callback for you.
 
`pre` functionss may may be specified globally or for each test.
They are called  called before the `wrap` block starts, in the original 
context (In Mocha, it may be used to configure timeouts). 

The example below is using the Mocha test framework.

```coffeescript
{4wrapmochacoffee}
```

## to retrieve the browser currently in use

The current browser is automatically stored in the Fiber context.
It can be retrieved with the `wd.current()` function. 

This is useful when writing test helpers.

```coffeescript
{5wdcurrentbrowsercoffee}
```

## supported methods

* [supported JsonWireProtocol mapping](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwire-mapping.md)
* [full JsonWireProtocol mapping](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwire-full-mapping.md)

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

2a/ run tests
```
cake test:local 
```

2b/ run clean test (making sure wd-zombie is not installed first)
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

once:
```
cake test:prepare:headless
```

then:
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

