# wd-sync with CofffeeScript

A synchronous version with a nice api of [wd](http://github.com/admc/wd), 
the lightweight  [WebDriver / Selenium2](http://seleniumhq.org/projects/webdriver/) 
client for node.js, built using  [node-fibers](http://github.com/laverdet/node-fibers).

Remote testing with [Sauce Labs](http://saucelabs.com) also works.

Note: headless zombie was removed in 1.1.0

## status

[![Build Status](https://travis-ci.org/sebv/node-wd-sync.png)](https://travis-ci.org/sebv/node-wd-sync)
[![Selenium Test Status](https://saucelabs.com/buildstatus/node_wd_sync)](https://saucelabs.com/u/node_wd_sync)

[![Selenium Test Status](https://saucelabs.com/browser-matrix/node_wd_sync.svg)](https://saucelabs.com/u/node_wd_sync)

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

## wrap

`wrap` is a wrapper around `sync` within so it nicely integrates with
test frameworks like Mocha. `wrap` manages the done callback for you.
 
`pre` functions may be specified globally or for each test.
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

## api

* [supported](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwire-mapping.md)
* [full JsonWireProtocol mapping](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwire-full-mapping.md)

## doc 

* [CoffeeScript](http://github.com/sebv/node-wd-sync/blob/master/doc/COFFEE-DOC.md)
* [JavaScript](http://github.com/sebv/node-wd-sync/blob/master/doc/JS-DOC.md)
* [JsonWireProtocol official doc](http://code.google.com/p/selenium/wiki/JsonWireProtocol)

Doc modifications must be done in the doc/template directory.

## running tests

### local / selenium server: 

1/ Install and start Selenium server

```
./node_modules/.bin/install_selenium
./node_modules/.bin/install_chromedriver
./node_modules/.bin/start_selenium_with_chromedriver
```

2/ run tests
```
make test 
```

### remote / Sauce Labs 

1/ configure sauce environment
```
export SAUCE_USERNAME=<SAUCE_USERNAME>
export SAUCE_ACCESS_KEY=<SAUCE_ACCESS_KEY>
# if using sauce connect
./node_modules/.bin/install_sauce_connect
./node_modules/.bin/start_sauce_connect
```

2/ run tests
```
make test_e2e_sauce
make test_midway_sauce_connect
```

## building doc/mapping

### README + doc

1/ Update the templates

2/ run `make build_doc`

### mappings

1/ Upgrade wd

2/ run `make build_mapping`
