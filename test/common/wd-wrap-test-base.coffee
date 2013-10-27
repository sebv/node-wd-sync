wdSync = require '../../index'
should = require 'should'
someText = null
TIMEOUT = 30000

test = (opt) ->
  describe "wd wrap tests", ->
    describe "with pre", ->
      {browser} = {}
      wrap = wdSync.wrap
        pre: ->
          @timeout (opt.timeout or TIMEOUT)
          someText = 'Test2'
        with: -> browser

      before (done) ->
        switch opt.type
          when 'remote' then {browser} = wdSync.remote(opt.remoteConfig)
        done()

      it "should work", wrap pre: ->
          @timeout (opt.timeout or TIMEOUT) + 100
        , ->
          someText.should.equal 'Test2'
          @init(opt.desired)
          @get "http://saucelabs.com/test/guinea-pig"
          @title().toLowerCase().should.include 'sauce labs'
          queryField = @elementById 'i_am_a_textbox'
          @type queryField, "Hello World"
          @type queryField, "\n"
          @quit()

    describe "without pre", ->
      {browser} = {}
      wrap = wdSync.wrap
        with: -> browser

      before (done) ->
        switch opt.type
          when 'remote' then {browser} = wdSync.remote(opt.remoteConfig)
        done()

      it "should work", wrap ->
        @init(opt.desired)
        @get "http://saucelabs.com/test/guinea-pig"
        @title().toLowerCase().should.include 'sauce labs'
        queryField = @elementById 'i_am_a_textbox'
        @type queryField, "Hello World"
        @type queryField, "\n"
        @quit()

exports.test = test
