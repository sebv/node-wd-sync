{wd,WdWrap} = require '../../index'
should = require 'should'
browser = null
someText = null
TIMEOUT = 30000
describe "wd-sync", -> \
describe "WdWrap", ->

browse = (opt) ->
  @init(opt.desired)
  @get "http://saucelabs.com/test/guinea-pig"      
  @title().toLowerCase().should.include 'sauce labs'          
  queryField = @elementById 'i_am_a_textbox'
  @type queryField, "Hello World"  
  @type queryField, "\n"
  @quit()

getBrowser = (opt) ->
  switch opt.type
    when 'remote' then return wd.remote(opt.remoteConfig)
    when 'headless' then return wd.headless()

passingBrowser = (opt) ->
  describe "wd-wrap tests", ->
    describe "passing browser", ->  

      before (done) ->
        browser = getBrowser opt
        done()
      
      it "should work", WdWrap 
        with: -> 
          browser
        pre: ->
          @timeout (opt.timeout or TIMEOUT)  
          someText = 'Test1'
      , ->      
        someText.should.equal 'Test1'
        browse.apply this, [opt]
  
withoutPassingBrowser = (opt) ->  
  WdWrap = WdWrap 
    pre: -> 
      @timeout (opt.timeout or TIMEOUT)
      someText = 'Test2'
    with:-> 
      browser
  describe "wd-wrap tests", ->
    describe "without passing browser", ->  
        
      before (done) ->
        browser = getBrowser opt
        done()
      
      it "should work", WdWrap ->
        someText.should.equal 'Test2'
        browse.apply this, [opt]
  
exports.browse = browse
exports.passingBrowser = passingBrowser
exports.withoutPassingBrowser = withoutPassingBrowser
