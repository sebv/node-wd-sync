{wd,Wd} = require '../../index'
should = require 'should'

testWithBrowser = (browserName) ->
  it "using #{browserName}", (done) ->
    browser = wd.remote(mode:'sync')
    Wd with:browser, ->        
      if browserName? then @init browserName: "#{browserName}"
      else @init()
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

describe "wd-sync", ->

  describe "passing browser", ->
    for browserName in [undefined,'firefox','chrome']
      testWithBrowser browserName

  describe "without passing browser", ->  
    before (done) ->
      browser = wd.remote(mode:'sync')
      Wd = Wd with:browser
      done()

    it "without passing browser", (done) ->
      Wd ->        
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
        done()

  describe 'wd.current()', ->
    it "browsing", (done) ->
      browser = wd.remote(mode:'sync')
      
      myOwnTitle = ->
        wd.current().title()
        
      Wd with:browser, ->        
        if browserName? then @init browserName: "#{browserName}"
        else @init()

        @get "http://google.com"
        myOwnTitle().toLowerCase().should.include 'google'          

        @quit()
        done()
    
  