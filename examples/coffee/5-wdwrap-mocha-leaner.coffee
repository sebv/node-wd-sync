# Assumes that the selenium server is running
# Use 'mocha' to run (npm install -g mocha)

{wd,WdWrap}={}
try 
  {wd,WdWrap} = require 'wd-sync' 
catch err
  {wd,WdWrap} = require '../../index' 

should = require 'should'
      
# 5/ leaner WdWrap syntax

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

