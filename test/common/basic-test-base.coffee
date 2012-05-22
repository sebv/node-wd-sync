{wd,Wd} = require '../../index'
should = require 'should'

testWithBrowser = (type, browserName) ->
  it (if browserName? then "using #{browserName}" else "without passing browser"), (done) ->
    browser = null
    switch type
      when 'remote'
        browser = wd.remote()
      when 'headless'
        browser = wd.headless()
    Wd with:browser, ->
      should.exist @status()        
      if browserName? then @init browserName: "#{browserName}"
      else @init()
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

testCurrent = (type) ->
  it "browsing with using wd.current()", (done) ->
    browser = null
    switch type
      when 'remote'
        browser = wd.remote()
      when 'headless'
        browser = wd.headless()
      
    myOwnTitle = ->
      wd.current().title()
        
    Wd with:browser, ->        
      if browserName? then @init browserName: "#{browserName}"
      else @init()

      @get "http://saucelabs.com/test/guinea-pig"
      myOwnTitle().toLowerCase().should.include 'sauce labs'          

      @quit()
      done()
  
exports.testWithBrowser = testWithBrowser
exports.testCurrent = testCurrent

