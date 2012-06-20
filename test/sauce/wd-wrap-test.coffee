{passingBrowser, withoutPassingBrowser} = require '../common/wd-wrap-test-base'
should = require 'should'
config = null
try config = require './config' catch err 
TIMEOUT = 180000

config = config.saucelabs
config.host = "ondemand.saucelabs.com"
config.port = 80

describe "wd-sync", -> 
  describe "sauce", ->
    describe "sauce config", ->
      it "should have sauce config", (done) ->
        should.exist config,
          'you need to configure your sauce username and access-key '\
          + 'in the file config.coffee.'
        done()
    
    passingBrowser 
      type: 'remote' 
      timeout: TIMEOUT 
      remoteConfig: config        
      desired:
        name: 'wd-wrap test passing browser'
        platform: "LINUX"
        browserName:'chrome'
  
    withoutPassingBrowser
      type: 'remote' 
      timeout: TIMEOUT 
      remoteConfig: config
      desired:
        name: 'wd-wrap test without passing browser'
        platform: "LINUX"
        browserName:'chrome'
