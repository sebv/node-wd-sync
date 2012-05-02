{wd,WdWrap} = require '../../index'
should = require 'should'
browser = null
someText = null
TIMEOUT = 30000
describe "WdWrap", ->
  
  describe "passing browser", ->  
    before (done) ->
      browser = wd.remote(mode:'sync')
      done()
      
    it "should work", WdWrap 
      with: -> 
        browser
      pre: ->
        @timeout 30000 
        someText = 'Test1'
    , ->      
      someText.should.equal 'Test1'
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
  
  describe "without passing browser", ->    
    WdWrap = WdWrap 
      pre: -> 
        @timeout 30000
        someText = 'Test2'
      with:-> 
        browser
        
    before (done) ->
      browser = wd.remote(mode:'sync')
      done()
      
    it "should work", WdWrap ->
      someText.should.equal 'Test2'
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
