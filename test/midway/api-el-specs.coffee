testInfo =
  name: 'api el'
  tags: ['midway']

require "../common/setup"
{Express} = require "../common/express-helper"

CoffeeScript = require 'coffee-script'

describe "api el specs " + env.TEST_ENV_DESC, ->
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
    @sauceJobStatus allPassed if env.SAUCE

  express.partials['browser.element'] =
    '<div id="theDiv"><div name="meme">Hello World!</div></div>'
  it "browser.element", wrap ->
    should.exist @element "name", "meme"
    (-> @element "name", "meme2").should.throw()

  express.partials['browser.elementOrNull'] =
    '<div id="theDiv"><div name="meme">Hello World!</div></div>'
  it "browser.elementOrNull", wrap ->
    should.exist @elementOrNull "name", "meme"
    should.not.exist @elementOrNull "name", "meme2"

  express.partials['browser.hasElement'] =
    '<div id="theDiv"><div name="meme">Hello World!</div></div>'
  it "browser.hasElement", wrap ->
    (@hasElement "name", "meme").should.be.true
    (@hasElement "name", "meme2").should.be.false

  express.partials['browser.elements'] =
    '''
    <div id="theDiv">
      <div name="meme">Hello World!</div>
      <div name="meme">Hello World!</div>
      <div name="meme">Hello World!</div>
    </div>
    '''
  it "browser.elements", wrap ->
    (@elements "name", "meme").should.have.length 3
    (@elements "name", "meme2").should.eql []


  for funcSuffix in [
    'ById'
    , 'ByCss'
  ]
    do ->

      elFuncPartial =
        '''
          <div id="theDiv">
            <div id="elementById">Hello World!</div>
            <div class="elementByCss">Hello World!</div>

            <div>
              <div id="elementsById">Hello World!</div>
            </div>
            <div>
              <div name="elementsByName">Hello World!</div>
              <div name="elementsByName">Hello World!</div>
              <div name="elementsByName">Hello World!</div>
            </div>
            <div name="elementByName">Hello World!</div>
            <div>
              <div class="elementsByCss">Hello World!</div>
              <div class="elementsByCss">Hello World!</div>
              <div class="elementsByCss">Hello World!</div>
            </div>
          </div>
        '''

      elementFuncName = 'element' + funcSuffix
      hasElementFuncName = 'hasElement' + funcSuffix
      elementsFuncName = 'elements' + funcSuffix

      searchText = elementFuncName
      searchText = "click #{searchText}" if searchText.match /ByLinkText/
      searchText = ".#{searchText}" if searchText.match /ByCss/
      searchText = "//div[@id='elementByXPath']/input" if searchText.match /ByXPath/
      searchText = "span" if searchText.match /ByTagName/

      searchText2 = searchText + '2'
      searchText2 = "//div[@id='elementByXPath2']/input" if searchText.match /ByXPath/
      searchText2 = "span2" if searchText.match /ByTagName/

      searchSeveralText = searchText.replace('element','elements')
      searchSeveralText2 = searchText2.replace('element','elements')

      express.partials["browser." + elementFuncName] = elFuncPartial
      it "browser." + elementFuncName, wrap ->
        should.exist @[elementFuncName] searchText
        (-> @[elementFuncName] searchText2).should.throw()

      express.partials["browser." + elementFuncName + 'IfExists'] = elFuncPartial
      it "browser." + elementFuncName + 'IfExists', wrap ->
        should.exist @[elementFuncName + 'IfExists'] searchText
        should.not.exist @[elementFuncName + 'IfExists'] searchText2

      express.partials["browser." + hasElementFuncName] = elFuncPartial
      it "browser." + hasElementFuncName, wrap ->
        (@[hasElementFuncName] searchText).should.be.true
        (@[hasElementFuncName] searchText2).should.be.false

      express.partials["browser." + elementsFuncName] = elFuncPartial
      it "browser." + elementsFuncName, wrap ->
        res = @[elementsFuncName] searchSeveralText
        if(elementsFuncName.match /ById/)
          res.should.have.length 1
        else if(elementsFuncName.match /ByTagName/)
          (res.length > 1).should.be.true
        else
          res.should.have.length 3
        res = @[elementsFuncName] searchSeveralText2
        res.should.eql []

  express.partials['browser.getAttribute'] =
    ' <div id="theDiv" weather="sunny">Hi</div>'
  it "browser.getAttribute", wrap ->
    testDiv = @elementById "theDiv"
    (@getAttribute testDiv, "weather").should.equal "sunny"
    testDiv.getAttribute("weather").should.equal "sunny"
    should.not.exist @getAttribute testDiv, "timezone"

  express.partials['browser.getValue'] =
    '''
    <div id="theDiv">
      <input class="input-text" type="text" value="Hello getValueTest!">
      <textarea>Hello getValueTest2!</textarea>
    </div>
    '''
  it "browser.getValue", wrap ->
    inputField = @elementByCss "#theDiv input"
    (@getValue inputField).should.equal "Hello getValueTest!"
    inputField.getValue().should.equal "Hello getValueTest!"
    textareaField = @elementByCss "#theDiv textarea"
    (@getValue textareaField).should.equal "Hello getValueTest2!"


  express.partials['element(s) within element(s)'] =
    '''
    <div id="theDiv">
      <div class="subDiv">
        <textarea>Hello!</textarea>
      </div>
      <div class="subDiv2">
        <textarea>Hello2!</textarea>
      </div>
    </div>
    '''
  it "element(s) within element(s)", wrap ->
    theDiv = @elementById "theDiv"
    theDiv.text().should.include "Hello"
    subDiv = theDiv.elementByCss ".subDiv"
    subDiv.text().should.include "Hello"
    textareas = subDiv.elementsByTagName 'textarea'
    textareas.should.have.length(1)
    textareas[0].getValue().should.equal('Hello!')
    theDiv = (@elementsByCss "#theDiv")[0]
    theDiv.should.exist
    theDiv.getComputedCss('color').should.include 'rgb'
    textareas = theDiv.elementsByTagName 'textarea'
    textareas.should.have.length(2)
    textareas[1].getValue().should.equal('Hello2!')
