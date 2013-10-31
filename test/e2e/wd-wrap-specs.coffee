require "../common/setup"

describe "wd wrap tests " + env.TEST_ENV_DESC, ->

  describe "without pre", ->
    testInfo =
      name: 'wd wrap without pre'
      tags: ['e2e']

    @timeout env.TIMEOUT
    someText = null
    {browser} = {}
    allPassed = true
    wrap = wdSync.wrap
      with: -> browser

    before ->
      {browser} = wdSync.remote env.REMOTE_CONFIG

    before wrap ->
      @init desiredWithTestInfo(testInfo)

    afterEach ->
      allPassed = allPassed and (@currentTest.state is 'passed')

    after wrap ->
      @quit()
      @sauceJobStatus allPassed if env.SAUCE

    describe "browsing page", ->
      beforeEach wrap ->
        @get "http://saucelabs.com/test/guinea-pig"

      it "should get title", wrap ->
        @title().toLowerCase().should.include 'sauce labs'

      it "should be able to type in field", wrap ->
        queryField = @elementById 'i_am_a_textbox'
        @type queryField, "Hello World"
        @type queryField, "\n"


  describe "with pre", ->
    testInfo =
      name: 'wd wrap with pre'
      tags: ['e2e']

    someText = null
    {browser} = {}
    allPassed = true
    wrap = wdSync.wrap
      pre: ->
        @timeout env.TIMEOUT
        someText = 'Test2'
      with: -> browser

    before ->
      {browser} = wdSync.remote env.REMOTE_CONFIG

    before wrap ->
      @init desiredWithTestInfo(testInfo)

    afterEach ->
      allPassed = allPassed and (@currentTest.state is 'passed')

    after wrap ->
      @quit()
      @sauceJobStatus allPassed if env.SAUCE

    it "should have run pre", wrap ->
      someText.should.equal 'Test2'

    describe "browsing page", ->
      beforeEach wrap pre: ->
        @timeout env.TIMEOUT/2
      , ->
        @get "http://saucelabs.com/test/guinea-pig"

      it "should get title", wrap ->
        @title().toLowerCase().should.include 'sauce labs'

      it "should be able to type in field", wrap ->
        queryField = @elementById 'i_am_a_textbox'
        @type queryField, "Hello World"
        @type queryField, "\n"
