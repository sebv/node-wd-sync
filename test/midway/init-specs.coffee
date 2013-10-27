testInfo =
  name: 'api'
  tags: ['init']

require "../common/setup"

describe "init specs " + env.TEST_ENV_DESC, ->
  @timeout env.TIMEOUT
  {browser,sync} = {}
  allPassed = true
  wrap = wdSync.wrap with: (-> browser)

  before ->
    {browser,sync} = wdSync.remote env.REMOTE_CONFIG
    browser.on "status", (info) ->
      console.log "\u001b[36m%s\u001b[0m", info
    browser.on "command", (meth, path) ->
      console.log " > \u001b[33m%s\u001b[0m: %s", meth, path

  afterEach ->
    allPassed = allPassed and (@currentTest.state is 'passed')

  after wrap ->
    @quit()
    jobStatus allPassed, @getSessionId()

  it "browser.status", wrap ->
    @status().should.exist

  describe "init", ->
    before wrap ->
      @init env.DESIRED

    it "browser.sessionCapabilities", wrap ->
      capabilities = @sessionCapabilities()
      capabilities.should.exist
      capabilities.browserName.should.exist
      capabilities.platform.should.exist

