{testWithBrowser,testCurrent} = require '../common/basic-test-base'
should = require 'should'
config = null
try config = require './config' catch err 
TIMEOUT = 180000

config = config.saucelabs
config.host = "ondemand.saucelabs.com"
config.port = 80

getDesired = (browserName, name) ->
  desired =
      platform: "LINUX"
      name: name        
  desired.browserName = browserName if browserName?
  if browserName is 'IE'
    desired.browserName = 'iexplore'
    desired.version = '9'
    desired.platform = 'VISTA'
  desired
  
describe "wd-sync", -> 
  describe "sauce", ->
    describe "sauce config", ->
      it "should have sauce config", (done) ->
        should.exist config,
          'you need to configure your sauce username and access-key '\
          + 'in the file config.coffee.'
        done()

    for browserName in ['chrome','IE']
      testWithBrowser 
        type: 'remote' 
        timeout: TIMEOUT 
        remoteConfig: config        
        desired: (getDesired browserName, "basic test with #{browserName}")
    
    testCurrent    
        type: 'remote' 
        timeout: TIMEOUT 
        remoteConfig: config        
        desired: (getDesired 'chrome', "wd.current()")
  
