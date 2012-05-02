{wd,Wd} = require '../../index'
should = require 'should'
config = null
try config = require './config' catch err 

testWithBrowser = (browserName) ->
  it "checking config", (done) ->
    should.exist config,
      'you need to configure your sauce username and access-key '\
      + 'in the file config.coffee.'
    done()
  it "using #{browserName}", (done) ->
    @timeout 90000
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
      @quit()
      done()

describe "wd-async", ->
  for browserName in [undefined,'firefox','chrome','IE']
    testWithBrowser browserName
