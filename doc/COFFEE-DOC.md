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

All the methods from [wd](http://github.com/admc/wd) are available. The element retrieval 
methods have been modified to return 'undefined' when the element is not found rather than
throw a 'Not Found' error.

The browser functions must to be run within a Wd block. This 
block holds the fiber environment. The Wd block context is set to the browser, 
so that the browser methods may be accessed using '@'.

The 'executeAsync' method may still be run asynchronously.

```coffeescript
# assumes that selenium server is running

{wd,Wd} = require 'wd-sync'
  
# 1/ simple Wd example 

browser = wd.remote()

Wd with:browser, ->        
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

  console.log @elementByName 'not_exists' # undefined

  @quit()  

```

## Sauce Labs example

Remote testing with [Sauce Labs](http://saucelabs.com) works. 

```coffeescript
# configure saucelabs username/access key here
username = '<USERNAME>'
accessKey = '<ACCESS KEY>'

{wd,Wd} = require 'wd-sync'

# 2/ wd saucelabs example 

desired =
  platform: "LINUX"
  name: "wd-sync demo"
  browserName: "firefox"

browser = wd.remote \
  "ondemand.saucelabs.com",
  80,
  username,
  accessKey

Wd with:browser, ->
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
# Assumes that the selenium server is running
# Use 'mocha' to run (npm install -g mocha)

{wd,Wd} = require 'wd-sync'

should = require 'should'

# 3/ simple WdWrap example

describe "WdWrap", ->

  describe "passing browser", ->  

    browser = null

    before (done) ->
      browser = wd.remote()
      done()

    it "should work", WdWrap 
      with: -> 
        browser
      pre: ->
        @timeout 30000 
    , ->      
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

## a slightly leaner syntax

When there is a browser parameter and no callback, Wd or WdWrap
returns a version of itself with a browser default added.

Wd sample below:

```coffeescript
# assumes that selenium server is running

{wd,Wd} = require 'wd-sync'
  
# 4/ leaner Wd syntax

browser = wd.remote()

# do this only once
Wd = Wd with:browser 

Wd ->        
  @init browserName:'firefox'

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

WdWrap sample below, using the mocha test framework:
```coffeescript
# Assumes that the selenium server is running
# Use 'mocha' to run (npm install -g mocha)

{wd,Wd} = require 'wd-sync'

should = require 'should'
      
# 5/ leaner WdWrap syntax

describe "WdWrap", ->

  describe "passing browser", ->  
    browser = null
    
    # do this only once
    WdWrap = WdWrap 
      with: -> 
        browser
      pre: ->
        @timeout 30000

    before (done) ->
      browser = wd.remote()
      done()

    it "should work", WdWrap ->      
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
It can be retrieved with the wd.current() function. 

This is useful when writing test helpers.

```coffeescript
# assumes that selenium server is running

{wd,Wd} = require 'wd-sync'
  
# 6/ retrieving the current browser

browser = wd.remote()

myOwnGetTitle = ->    
  wd.current().title()

Wd with:browser, ->        
  @init browserName:'firefox'

  @get "http://google.com"
  console.log myOwnGetTitle()          

  @quit()

```

## supported methods

* [full JsonWireProtocol mapping](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwiremap-all.md)
* [supported JsonWireProtocol mapping](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwiremap-supported.md)


## doc 

* [CoffeeScript](http://github.com/sebv/node-wd-sync/blob/master/doc/COFFEE-DOC.md)
* [JavaScript](http://github.com/sebv/node-wd-sync/blob/master/doc/JS-DOC.md)
* [JsonWireProtocol official doc](http://code.google.com/p/selenium/wiki/JsonWireProtocol)

Doc modifications must be done in the doc/template directory.


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

1/ follow the instruction2 [here](http://github.com/sebv/node-wd-sync/blob/master/test/sauce/README.md) to
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
java -jar selenium-server-standalone-2.21.0.jar -Dwebdriver.chrome.driver=./chromedriver
```


## per methods tests / code example

check in [wd-by-method-test.coffee](https://github.com/sebv/node-wd-sync/blob/master/test/unit/wd-by-method-test.coffee)