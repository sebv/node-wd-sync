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
# assumes that selenium server is running

wdSync = require 'wd-sync'

# 1/ simple Wd example

{browser, sync} = wdSync.remote()

sync ->
  console.log "server status:", @status()
  @init browserName:'firefox'
  console.log "session id:", @getSessionId()
  console.log "session capabilities:", @sessionCapabilities()

  @get "http://google.com"
  console.log @title()

  queryField = @elementByName 'q'
  @type queryField, "Hello World"
  @type queryField, "\n"

  @setWaitTimeout 3000
  @elementByCss '#ires' # waiting for new page to load
  console.log @title()

  console.log @elementByNameIfExists 'not_exists' # undefined

  @quit()

```

## Sauce Labs example

Remote testing with [Sauce Labs](http://saucelabs.com) works. 

```coffeescript
# configure saucelabs username/access key here
username = process.env.SAUCE_USERNAME or '<USERNAME>'
accessKey = process.env.SAUCE_KEY or '<ACCESS KEY>'

wdSync = require 'wd-sync'

# 2/ wd saucelabs example

desired =
  platform: "LINUX"
  name: "wd-sync demo"
  browserName: "firefox"

{browser, sync} = wdSync.remote \
  "ondemand.saucelabs.com",
  80,
  username,
  accessKey

sync ->
  console.log "server status:", @status()
  @init(desired)
  console.log "session id:", @getSessionId()
  console.log "session capabilities:", @sessionCapabilities()

  @get "http://google.com"
  console.log @title()

  queryField = @elementByName 'q'
  @type queryField, "Hello World"
  @type queryField, "\n"

  @setWaitTimeout 3000
  @elementByCss '#ires' # waiting for new page to load
  console.log @title()

  @quit()

```

## browser initialization

Please refer to [wd doc](https://github.com/admc/wd#browser-initialization).

## wrap

`wrap` is a wrapper around `sync` within so it nicely integrates with
test frameworks like Mocha. `wrap` manages the done callback for you.
 
`pre` functions may be specified globally or for each test.
They are called  called before the `wrap` block starts, in the original 
context (In Mocha, it may be used to configure timeouts). 

The example below is using the Mocha test framework.

```coffeescript
# Assumes that the selenium server is running
# Use 'mocha --compilers coffee:coffee-script' to run (npm install -g mocha)

wdSync = require 'wd-sync'

chai = require 'chai'
chai.should()

# 4/ wrap example

describe "WdWrap", ->

  describe "wrap", ->

    browser = null
    wrap = wdSync.wrap
      with: -> browser
      pre: -> #optional
        @timeout 30000

    before (done) ->
      {browser} = wdSync.remote()
      done()

    it "should work", wrap -> # may also pass a pre here
      @init()

      @get "http://google.com"
      @title().toLowerCase().should.include 'google'

      queryField = @elementByName 'q'
      @type queryField, "Hello World"
      @type queryField, "\n"

      @setWaitTimeout 3000
      @elementByCss '#ires' # waiting for new page to load
      @title().toLowerCase().should.include 'hello world'

      @quit()

```

## to retrieve the browser currently in use

The current browser is automatically stored in the Fiber context.
It can be retrieved with the `wd.current()` function. 

This is useful when writing test helpers.

```coffeescript
# assumes that selenium server is running

wdSync = require 'wd-sync'
  
# 5/ retrieving the current browser

{browser, sync} = wdSync.remote()

myOwnGetTitle = ->
  wdSync.current().title()

sync ->
  @init browserName:'firefox'

  @get "http://google.com"
  console.log myOwnGetTitle()

  @quit()

```

## api

* [supported](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwire-mapping.md)
* [full JsonWireProtocol mapping](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwire-full-mapping.md)

## doc 

* [CoffeeScript](http://github.com/sebv/node-wd-sync/blob/master/doc/COFFEE-DOC.md)
* [JavaScript](http://github.com/sebv/node-wd-sync/blob/master/doc/JS-DOC.md)
* [wd doc](https://github.com/admc/wd/blob/master/README.md)
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

## publishing

```
npm version [patch|minor|major]
git push --tags
npm publish
```

