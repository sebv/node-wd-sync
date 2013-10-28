# Assumes that the selenium server is running
# Use 'mocha --compilers coffee:coffee-script' to run (npm install -g mocha)

wdSync = null
try
  wdSync = require 'wd-sync'
catch err
  wdSync = require '../../index'

chai = require 'chai'
chai.should()

# 4/ wrap example

describe "WdWrap", ->

  describe "wrap", ->

    browser = null
    wrap = wdSync.wrap
      with: -> browser
      pre: -> #optional
        @timeout 30000

    before (done) ->
      {browser} = wdSync.remote()
      done()

    it "should work", wrap -> # may also pass a pre here
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
