# wd-sync

A synchronous version with a nice api of [wd](http://github.com/admc/wd), 
the lightweight  [WebDriver / Selenium2](http://seleniumhq.org/projects/webdriver/) 
client for node.js, built using  [node-fibers](http://github.com/laverdet/node-fibers).

Remote testing with [Sauce Labs](http://saucelabs.com) also works.

## install

```
npm install wd-sync
```


## usage (coffeescript)

When creating a new browser with remote, an extra mode option need to be 
passed.

All the methods from [wd](http://github.com/admc/wd) are available. 

In sync mode, the browser function must to be run within a Wd block. This 
block holds the fiber environment. The Wd block context is set to the browser, 
so that the browser methods may be accessed using '@'.

```coffeescript
# assumes that selenium server is running

{wd,Wd} = require 'wd-sync'

browser = wd.remote(mode:'sync')

Wd with:browser, ->        
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

## Sauce Labs example

Remote testing with [Sauce Labs](http://saucelabs.com) works. The extra mode
option is also needed here.

```coffeescript
# configure saucelabs username/access key here
username = '<USERNAME>'
accessKey = '<ACCESS KEY>'

{wd,Wd} = require 'wd-sync'

desired =
  platform: "LINUX"
  name: "wd-sync demo"
  browserName: "firefox"
                 
browser = wd.remote \
  "ondemand.saucelabs.com",
  80,
  username,
  accessKey,
  mode:'sync'

Wd with:browser, ->        
  @init(desired)
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

WdWrap is a wrapper around Wd. It returns a function with a callback arguments, 
called last, after other commands have been executed. 

The example below is using the mocha test framework. The usual 'done' callback 
is managed within WdWrap.

The 'use' parameter is a function returning the browser evaluated each time the block is opened. 

A 'pre' method may also be specified. It is called before the Wd block starts, in the original 
context (In Mocha, it can be used to configure timeouts). 

```coffeescript
# Assumes that the selenium server is running

{wd,WdWrap} = require 'wd-sync'
should = require 'should'

describe "WdWrap", ->
  
  describe "passing browser", ->  
    
    browser = null
    
    before (done) ->
      browser = wd.remote(mode:'sync')
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

browser = wd.remote(mode:'sync')

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

{wd,WdWrap} = require 'wd-sync'
should = require 'should'

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
      browser = wd.remote(mode:'sync')
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

browser = wd.remote(mode:'sync')

myOwnGetTitle = ->
  wd.current().title()

Wd with:browser, ->        
  @init browserName:'firefox'

  @get "http://google.com"
  console.log myOwnGetTitle()          

  @quit()
```

## modes

check [make-sync](http://github.com/sebv/node-make-sync/blob/master/README.markdown#modes) for more details. 
Probably best to use the 'sync' mode.

```coffeescript
mode: 'sync'
mode: 'async'

mode: ['mixed']
mode: ['mixed','args']

mode: ['mixed','fibers']
```


## Selenium server

Download the Selenium server [here](http://seleniumhq.org/download/).

To start the server:

```
java -jar selenium-server.jar
```


## tested

* wd:
  * remote

* browser
  * init
  * get
  * title
  * setWaitTimeout
  * elementByCss
  * type
  * quit
