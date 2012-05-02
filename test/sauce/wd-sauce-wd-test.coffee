{wd,Wd,WdWrap} = require '../../index'
should = require 'should'
config = null
try config = require './config' catch err 
TIMEOUT = 180000

testWithBrowser = (browserName) ->
  it "using #{browserName}", (done) ->
    @timeout TIMEOUT 
    desired =
      platform: "LINUX"
      name: "wd-sync sauce test"        
    desired.browserName = browserName if browserName?
    if browserName is 'IE'
      desired.browserName = 'iexplore'
      desired.version = '9'
      desired.platform = 'VISTA'
    browser = wd.remote \
      "ondemand.saucelabs.com",
      80,
      config.saucelabs.username,
      config.saucelabs['access-key'],
      mode:'sync'
    Wd with:browser, ->        
      @init(desired)
      @get "http://google.com"
      @title().toLowerCase().should.include 'google'          
      queryField = @elementByName 'q'
      @type queryField, "Hello World"  
      @type queryField, "\n"
      @setWaitTimeout 3000      
      @elementByCss '#ires' # waiting for new page to load
      @title().toLowerCase().should.include 'hello world'
      @close()
      @quit()
      done()

describe "wd-sauce", ->
  it "checking config", (done) ->
    should.exist config,
      'you need to configure your sauce username and access-key '\
      + 'in the file config.coffee.'
    done()
  describe "using Wd", ->
    describe "passing browser", ->
      for browserName in [undefined,'firefox','chrome','IE']
        testWithBrowser browserName

    describe "without passing browser", ->
      it "initializing browser", (done) ->
        @timeout TIMEOUT 
        browser = wd.remote \
          "ondemand.saucelabs.com",
          80,
          config.saucelabs.username,
          config.saucelabs['access-key'],
          mode:'sync'
        Wd = Wd with:browser
        done()
      it "browsing", (done) ->        
        @timeout TIMEOUT 
        desired =
          platform: "LINUX"
          name: "wd-sync sauce test"        
          browserName: 'firefox'
        Wd ->        
          @init(desired)
          @get "http://google.com"
          @title().toLowerCase().should.include 'google'          
          queryField = @elementByName 'q'
          @type queryField, "Hello World"  
          @type queryField, "\n"
          @setWaitTimeout 3000      
          @elementByCss '#ires' # waiting for new page to load
          @title().toLowerCase().should.include 'hello world'
          @close()
          @quit()
          done()
