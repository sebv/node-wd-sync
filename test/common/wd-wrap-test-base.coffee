{wd,WdWrap} = require '../../index'
should = require 'should'
browser = null
someText = null
TIMEOUT = 30000
describe "wd-sync", -> \
describe "WdWrap", ->

browse = ->
  @init()
  @get "http://saucelabs.com/test/guinea-pig"      
  @title().toLowerCase().should.include 'sauce labs'          
  queryField = @elementById 'i_am_a_textbox'
  @type queryField, "Hello World"  
  @type queryField, "\n"
  @quit()

getBrowser = (type) ->
  switch type
    when 'remote' then return wd.remote()
    when 'headless' then return wd.headless()

passingBrowser = (type) ->
  before (done) ->
    browser = getBrowser type
    done()
      
  it "should work", WdWrap 
    with: -> 
      browser
    pre: ->
      @timeout TIMEOUT  
      someText = 'Test1'
  , ->      
    someText.should.equal 'Test1'
    browse.apply this
  
withoutPassingBrowser = (type) ->
  WdWrap = WdWrap 
    pre: -> 
      @timeout TIMEOUT 
      someText = 'Test2'
    with:-> 
      browser
        
  before (done) ->
    browser = getBrowser type
    done()
      
  it "should work", WdWrap ->
    someText.should.equal 'Test2'
    browse.apply this
  
exports.browse = browse
exports.passingBrowser = passingBrowser
exports.withoutPassingBrowser = withoutPassingBrowser
