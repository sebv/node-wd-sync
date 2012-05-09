{wd,Wd,WdWrap} = require '../../index'
should = require 'should'
config = null
try config = require './config' catch err 
TIMEOUT = 180000

describe "wd-sauce", -> \
describe "sauce tests", -> \
describe "WdWrap", ->
  it "checking config", (done) ->
    should.exist config,
      'you need to configure your sauce username and access-key '\
      + 'in the file config.coffee.'
    done()
    
  describe "passing browser", ->
    browser = null;
      
    it "initializing browser", (done) ->
      @timeout TIMEOUT
      browser = wd.remote \
        "ondemand.saucelabs.com",
        80,
        config.saucelabs.username,
        config.saucelabs['access-key'],
        mode:'sync'
      done()
        
    it "browsing", WdWrap 
      with: -> 
        browser
      pre: -> 
        @timeout TIMEOUT 
    , ->   
      desired =
        platform: "LINUX"
        name: "wd-sync sauce test"     
        browserName: 'firefox'   
      @init(desired)
      @get "http://google.com"
      @title().toLowerCase().should.include 'google'          
      queryField = @elementByName 'q'
      @type queryField, "Hello World"  
      @type queryField, "\n"
      @setWaitTimeout 3000      
      @elementByCss '#ires' # waiting for new page to load
      @title().toLowerCase().should.include 'hello world'
      @quit()
        
  describe "without passing browser", ->
    browser = null
      
    WdWrap = WdWrap
      with: -> 
        browser 
      pre: -> 
        @timeout TIMEOUT
          
    it "initializing browser", (done) ->
      @timeout TIMEOUT
      browser = wd.remote \
        "ondemand.saucelabs.com",
        80,
        config.saucelabs.username,
        config.saucelabs['access-key'],
        mode:'sync'
      done()
        
    it "browsing", WdWrap ->        
      desired =
        platform: "LINUX"
        name: "wd-sync sauce test"        
        browserName: 'firefox'
      @init(desired)
      @get "http://google.com"
      @title().toLowerCase().should.include 'google'          
      queryField = @elementByName 'q'
      @type queryField, "Hello World"  
      @type queryField, "\n"
      @setWaitTimeout 3000      
      @elementByCss '#ires' # waiting for new page to load
      @title().toLowerCase().should.include 'hello world'
      @quit()
