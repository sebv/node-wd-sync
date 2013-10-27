wdSync = require '../../index'
should = require 'should'
TIMEOUT = 45000

testWithBrowser = (opt) ->
  describe "basic browsing", ->
    it (if opt.desired?.browserName? then "using #{opt.desired?.browserName}" else "without passing browser"), (done) ->
      @timeout (opt.timeout or TIMEOUT)
      {browser,sync} = {}
      switch opt.type
        when 'remote'
          {browser,sync} = wdSync.remote(opt.remoteConfig)

      sync ->
        should.exist @status()
        if browserName? then @init browserName: "#{browserName}"
        else @init(opt.desired)
        sessionId = @getSessionId()
        should.exist sessionId
        caps = @sessionCapabilities()
        should.exist caps
        should.exist caps.browserName if browserName?
        @get "http://saucelabs.com/test/guinea-pig"
        @title().toLowerCase().should.include 'sauce labs'
        queryField = @elementById 'i_am_a_textbox'
        @type queryField, "Hello World"
        @type queryField, "\n"
        @quit()
        done()

testCurrent = (opt) ->
  describe "wd.current()", ->
    it "browsing with using wd.current()", (done) ->
      @timeout (opt.timeout or TIMEOUT)
      {browser,sync} = {}
      switch opt.type
        when 'remote'
          {browser,sync} = wdSync.remote(opt.remoteConfig)

      myOwnTitle = ->
        wdSync.current().title()

      sync ->
        if browserName? then @init browserName: "#{browserName}"
        else @init(opt.desired)

        @get "http://saucelabs.com/test/guinea-pig"
        myOwnTitle().toLowerCase().should.include 'sauce labs'

        @quit()
        done()

testSleep = (opt) ->
  describe "wdSync.sleep()", ->
    it "should sleep", (done) ->
      @timeout (opt.timeout or TIMEOUT)
      {browser,sync} = {}
      switch opt.type
        when 'remote'
          {browser,sync} = wdSync.remote(opt.remoteConfig)

      sync ->
        wdSync.sleep 50
        done()

exports.testWithBrowser = testWithBrowser
exports.testCurrent = testCurrent
exports.testSleep = testSleep
