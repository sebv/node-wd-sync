testInfo =
  name: 'api'
  tags: ['midway']

require "../common/setup"
{Express} = require "../common/express-helper"

CoffeeScript = require 'coffee-script'

describe "api specs " + env.TEST_ENV_DESC, ->
  @timeout env.TIMEOUT
  {browser,sync} = {}
  wrap = wdSync.wrap with: (-> browser)
  allPassed = true
  express = new Express(__dirname + '/assets')
  before ->
    express.start()
    {browser,sync} = wdSync.remote env.REMOTE_CONFIG
    if env.VERBOSE
      browser.on "status", (info) ->
        console.log "\u001b[36m%s\u001b[0m", info
      browser.on "command", (meth, path) ->
        console.log " > \u001b[33m%s\u001b[0m: %s", meth, path

  before wrap ->
    @init desiredWithTestInfo(testInfo)

  beforeEach (done) ->
    cleanTitle = @currentTest.title.replace(/@[-\w]+/g, '').trim();
    sync ->
      @get env.MIDWAY_ROOT_URL + '/test-page?partial=' + encodeURIComponent(cleanTitle)
      done()

  afterEach ->
    allPassed = allPassed and (@currentTest.state is 'passed')

  after wrap ->
    express.stop()
    @quit()
    jobStatus allPassed, @getSessionId()

  express.partials['browser.eval'] =
    '<div id="theDiv"><ul><li>line 1</li><li>line 2</li></ul></div>'
  it "browser.eval", wrap ->
    (@eval "1+2").should.equal 3
    (@eval "document.title").should.equal "WD Sync Tests"
    (@eval "$('#theDiv').length").should.equal 1
    (@eval "$('#theDiv li').length").should.equal 2

  it "browser.execute (with args)", wrap ->
    script = "window.wd_sync_execute_test = 'It worked! ' + (arguments[0] + arguments[1])"
    @execute script, [10, 5]
    (@eval "window.wd_sync_execute_test").should.equal 'It worked! 15'

  it "browser.executeAsync (async mode, no args)", (done) ->
    scriptAsCoffee =
      """
        [args...,done] = arguments
        done "OK"
      """
    scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
    browser.executeAsync scriptAsJs, (err,res) ->
      res.should.equal "OK"
      done()

  it "browser.executeAsync (sync mode, no args)", wrap ->
    scriptAsCoffee =
      """
        [args...,done] = arguments
        done "OK"
      """
    scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
    res = @executeAsync scriptAsJs
    res.should.equal "OK"

  it "browser.executeAsync (sync mode, with args)", wrap ->
    scriptAsCoffee =
      """
        [args...,done] = arguments
        done("OK " + (args[0] + args[1]))
      """
    scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
    res = @executeAsync scriptAsJs, [10, 2]
    res.should.equal "OK 12"

  it "browser.safeExecuteAsync (sync mode, with args)", wrap ->
    scriptAsCoffee =
      """
        [args...,done] = arguments
        done("OK " + (args[0] + args[1]))
      """
    scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
    res = @safeExecuteAsync scriptAsJs, [10, 2]
    res.should.equal "OK 12"
    (=> @safeExecuteAsync "!!!a wrong expr", [10, 2]).should.throw(/Error response status/)

  express.partials['browser.click'] =
    '''
    <div id="theDiv">
      <div class="numOfClicks">not clicked</div>
      <div class="buttonNumber">not clicked</div>
    </div>
    '''
  it "browser.click", wrap ->
    numOfClicksDiv = @elementByCss "#theDiv .numOfClicks"
    buttonNumberDiv= @elementByCss "#theDiv .buttonNumber"
    scriptAsCoffee =
      '''
        jQuery ->
          window.numOfClick = 0
          numOfClicksDiv = $('#theDiv .numOfClicks')
          buttonNumberDiv = $('#theDiv .buttonNumber')
          numOfClicksDiv.mousedown (eventObj) ->
            button = eventObj.button
            button = 'default' unless button?
            window.numOfClick = window.numOfClick + 1
            numOfClicksDiv.html "clicked #{window.numOfClick}"
            buttonNumberDiv.html "#{button}"
            false
      '''
    scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
    @execute scriptAsJs
    (@text numOfClicksDiv).should.equal "not clicked"
    @moveTo numOfClicksDiv
    @click 0
    (@text numOfClicksDiv).should.equal "clicked 1"
    (@text buttonNumberDiv).should.equal "0"
    @moveTo numOfClicksDiv
    unless env.SAUCE # click with no params not working on sauce
      @click()
      (@text numOfClicksDiv).should.equal "clicked 2"
      (@text buttonNumberDiv).should.equal "0"

  express.partials['browser.type'] =
    '<div id="theDiv"><input class="input-text" type="text"></div>'
  it "browser.type", wrap ->
    altKey = wdSync.SPECIAL_KEYS['Alt']
    nullKey = wdSync.SPECIAL_KEYS['NULL']
    inputField = @elementByCss "#theDiv input"
    should.exist (inputField)
    @type inputField, "Hello"
    (@getValue inputField).should.equal "Hello"
    @type inputField, [altKey, nullKey, " World"]
    (@getValue inputField).should.equal "Hello World"
    @type inputField, [wdSync.SPECIAL_KEYS.Return] # no effect
    (@getValue inputField).should.equal "Hello World"

  express.partials['browser.keys'] =
    '<div id="theDiv"><input class="input-text" type="text"></div>'
  it "browser.keys", wrap ->
    altKey = wdSync.SPECIAL_KEYS['Alt']
    nullKey = wdSync.SPECIAL_KEYS['NULL']
    inputField = @elementByCss "#theDiv input"
    should.exist (inputField)
    @clickElement inputField
    @keys "Hello"
    (@getValue inputField).should.equal "Hello"
    @keys [altKey, nullKey, " World"]
    (@getValue inputField).should.equal "Hello World"
    @type inputField, [wdSync.SPECIAL_KEYS.Return] # no effect
    (@getValue inputField).should.equal "Hello World"


  express.partials['browser.text'] =
    '<div id="theDiv"><div>text content</div></div>'
  it "browser.text", wrap ->
    textDiv = @elementByCss "#theDiv"
    should.exist (textDiv)
    @text(textDiv).should.include "text content"
    @text(textDiv).should.not.include "div"
    textDiv.text().should.include "text content"
    @text('body').should.include "text content"
    # todo: check why it doesn't work
    # @text().should.include "text content"

  express.partials['browser.acceptAlert'] =
    '<div id="theDiv"><a>click me</a></div>'
  it "browser.acceptAlert", wrap ->
    a = @elementByCss "#theDiv a"
    should.exist (a)
    scriptAsCoffee =
      """
        a = $('#theDiv a')
        a.click ->
          alert "coffee is running out"
          false
      """
    scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
    res = @execute scriptAsJs
    @clickElement a
    @acceptAlert()

  express.partials['browser.active'] =
    '''
    <div id="theDiv">
      <input class="i1" type="text" value="input 1">
      <input class="i2" type="text" value="input 2">
    </div>
    '''
  it "browser.active", wrap ->
    i1 = @elementByCss "#theDiv .i1"
    i2 = @elementByCss "#theDiv .i2"
    i1.click()
    @active().value.should.equal i1.value
    @clickElement i2
    @active().value.should.equal i2.value

  it "browser.url", wrap ->
    url = @url()
    url.should.include "test-page"
    url.should.include "http://"

  it "browser.<cookie methods>", wrap ->
    @deleteAllCookies()
    @allCookies().should.eql []
    @setCookie \
      name: 'fruit1'
      , value: 'apple'
    cookies = @allCookies()
    (cookies.filter (c) -> c.name is 'fruit1' and c.value is 'apple')\
       .should.have.length 1
    @setCookie \
      name: 'fruit2'
      , value: 'pear'
    cookies = @allCookies()
    cookies.should.have.length 2
    (cookies.filter (c) -> c.name is 'fruit2' and c.value is 'pear')\
       .should.have.length 1
    @setCookie \
      name: 'fruit3'
      , value: 'orange'
    @allCookies().should.have.length 3
    @deleteCookie 'fruit2'
    cookies = @allCookies()
    cookies.should.have.length 2
    (cookies.filter (c) -> c.name is 'fruit2' and c.value is 'pear')\
       .should.have.length 0
    @deleteAllCookies()
    @allCookies().should.eql []
    # not too sure how to test this case this one, so just making sure
    # that it does not throw
    @setCookie \
      name: 'fruit3'
      , value: 'orange'
      , secure: true
    @deleteAllCookies()

  it "browser.uploadFile", wrap ->
    filepath = @uploadFile "test/mocha.opts"
    should.exist filepath
    filepath.should.include 'mocha.opts'


  express.partials['browser.waitForCondition'] =
    '<div id="theDiv"></div>'
  it "browser.waitForCondition", wrap ->
    scriptAsCoffee =
      '''
        setTimeout ->
          $('#theDiv').html '<div class="child">a waitForCondition child</div>'
        , 1500
      '''
    scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
    @execute scriptAsJs
    should.not.exist @elementByCssIfExists "#theDiv .child"
    exprCond = "$('#theDiv .child').length > 0"
    (@waitForCondition exprCond, 2000, 200).should.be.true
    (@waitForCondition exprCond, 2000).should.be.true
    (@waitForCondition exprCond).should.be.true
    (=> @waitForCondition "sdsds ;;sdsd {}").should.throw(/Error response status/)

  it "err.inspect", wrap ->
    err = null
    try
      browser.safeExecute "invalid-code> here"
    catch _err
      err = _err
    should.exist err
    (err instanceof Error).should.be.true
    (err.inspect().length <= 510).should.be.true
