testInfo =
  name: 'basic'
  tags: ['e2e']

require "../common/setup"

describe "basic browsing " + env.TEST_ENV_DESC, (done) ->
  {browser,sync} = {}
  allPassed = true
  @timeout env.TIMEOUT

  before (done) ->
    {browser,sync} = wdSync.remote env.REMOTE_CONFIG
    sync ->
      @init desiredWithTestInfo(testInfo)
      done()

  afterEach ->
    allPassed = allPassed and (@currentTest.state is 'passed')

  after (done) ->
    sync ->
      @quit()
      @sauceJobStatus allPassed if env.SAUCE
      done()

  describe "precheck", ->
    it "should work", (done) ->
      sync ->
        @status().should.exist
        sessionId = @getSessionId()
        sessionId.should.exist
        caps = @sessionCapabilities()
        caps.should.exist
        caps.browserName.should.exist  if env.DESIRED.browserName?
        done()

  describe "browse page", ->
    beforeEach (done) ->
      sync ->
        @get "http://saucelabs.com/test/guinea-pig"
        done()

    it "should have correct title", (done) ->
      sync ->
        @title().toLowerCase().should.include 'sauce labs'
        done()

    it "typing in field should work", (done) ->
      sync ->
        queryField = @elementById 'i_am_a_textbox'
        @type queryField, "Hello World"
        @type queryField, "\n"
        done()

