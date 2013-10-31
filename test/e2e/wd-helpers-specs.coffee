testInfo =
  name: 'wd-helper'
  tags: ['e2e']

require "../common/setup"

describe "wd.current() " + env.TEST_ENV_DESC, ->
  @timeout env.TIMEOUT
  {browser,sync} = {}
  allPassed = true

  before (done) ->
    {browser,sync} = wdSync.remote env.REMOTE_CONFIG
    sync ->
      # @configureHttp(env.HTTP_CONFIG)
      @init desiredWithTestInfo(testInfo)
      done()

  beforeEach (done) ->
    sync ->
      @get "http://saucelabs.com/test/guinea-pig"
      done()

  afterEach ->
    allPassed = allPassed and (@currentTest.state is 'passed')

  after (done) ->
    sync ->
      @quit()
      @sauceJobStatus allPassed if env.SAUCE
      done()

  describe "wd.current()", ->
    myOwnTitle = ->
      wdSync.current().title()

    it "should get title using wd.current()", (done) ->
      sync ->
        myOwnTitle().toLowerCase().should.include 'sauce labs'
        done()

  describe "wdSync.sleep()", ->
    it "should sleep", (done) ->
      sync ->
        wdSync.sleep 50
        done()
