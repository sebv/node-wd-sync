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
# assumes that selenium server is running

wdSync = require 'wd-sync'
  
# 1/ simple Wd example 

{browser, sync} = wdSync.remote()

sync ->        
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

  console.log @elementByNameIfExists 'not_exists' # undefined

  @quit()  

```

## Sauce Labs example

Remote testing with [Sauce Labs](http://saucelabs.com) works. 

```coffeescript
# configure saucelabs username/access key here
username = '<USERNAME>'
accessKey = '<ACCESS KEY>'

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

## Headless example

This uses the [wd-zombie](http://sebv/node-wd-zombie.git) module,
which implements the wd interface using [Zombie](http://github.com/assaf/zombie). 

IMPORTANT: A wd-zombie dependency must be configured in package.json.

In this mode, no need to run the Selenium server.

```coffeescript
# a dependency to 'wd-zombie' must be configured in package.json  

wdSync = require 'wd-sync'
  
# 3/ headless Wd example 

{browser, sync} = wdSync.headless()

sync ->        
  @init browserName:'firefox'

  @get "http://saucelabs.com/test/guinea-pig"
  console.log @title()          

  divEl = @elementByCss '#i_am_an_id'
  console.log @text divEl

  textField = @elementByName 'i_am_a_textbox'
  @type textField , "Hello World"  
  @type textField , wdSync.SPECIAL_KEYS.Return

  @quit()  

```

notes regarding headless/zombie:
- only worth using for simple pages, not relying heavily on Javacripts.   
- the headless functionality wont be maintained/improved, at least until Zombie 2 is stable. 

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

should = require 'should'

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

