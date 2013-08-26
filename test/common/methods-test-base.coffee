wdSync = require '../../index'
should = require 'should'
CoffeeScript = require 'coffee-script'
async = require 'async'
express = require 'express'

test = (type, browserName) ->

  describe "method tests using #{browserName}", ->

    {browser,sync} = {}
    wrap = wdSync.wrap with: (-> browser)
    capabilities = null


    it "wd.remote or wd.headless", (done) ->
      switch type
        when 'remote'
          {browser,sync} = wdSync.remote()
          browser.on "status", (info) ->
            console.log "\u001b[36m%s\u001b[0m", info
          browser.on "command", (meth, path) ->
            console.log " > \u001b[33m%s\u001b[0m: %s", meth, path
          done()
        when 'headless'
          {browser,sync} = wdSync.headless()
          done()

    it "status", wrap ->
      should.exist @status()

    it "init", wrap ->
      desired =
          browserName:browserName
      @init desired

    it "sessionCapabilities", wrap ->
      capabilities = @sessionCapabilities()
      should.exist capabilities
      should.exist capabilities.browserName
      should.exist capabilities.platform

    it "get", wrap ->
      @get "http://127.0.0.1:8181/local-test-page.html"

    it "eval", wrap ->
      (@eval "1+2").should.equal 3
      (@eval "document.title").should.equal "TEST PAGE"
      (@eval "$('#eval').length").should.equal 1
      (@eval "$('#eval li').length").should.equal 2

    it "execute (with args)", wrap ->
      script = "window.wd_sync_execute_test = 'It worked! ' + (arguments[0] + arguments[1])"
      @execute script, [10, 5]
      (@eval "window.wd_sync_execute_test").should.equal 'It worked! 15'

    it "executeAsync (async mode, no args)", (done) ->
      scriptAsCoffee =
        """
          [args...,done] = arguments
          done "OK"
        """
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
      browser.executeAsync scriptAsJs, (err,res) ->
        res.should.equal "OK"
        done()

    it "executeAsync (sync mode, no args)", wrap ->
      scriptAsCoffee =
        """
          [args...,done] = arguments
          done "OK"
        """
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
      res = @executeAsync scriptAsJs
      res.should.equal "OK"

    it "executeAsync (sync mode, with args)", wrap ->
      scriptAsCoffee =
        """
          [args...,done] = arguments
          done("OK " + (args[0] + args[1]))
        """
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
      res = @executeAsync scriptAsJs, [10, 2]
      res.should.equal "OK 12"

    it "safeExecuteAsync (sync mode, with args)", wrap ->
      scriptAsCoffee =
        """
          [args...,done] = arguments
          done("OK " + (args[0] + args[1]))
        """
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
      res = @safeExecuteAsync scriptAsJs, [10, 2]
      res.should.equal "OK 12"
      switch type
        when 'remote'
          (=> @safeExecuteAsync "!!!a wrong expr", [10, 2]).should.throw(/Error response status/)
        when 'headless'
          (=> @safeExecuteAsync "!!!a wrong expr", [10, 2]).should.throw(/Execution failure/)

    it "element", wrap ->
      should.exist @element "name", "elementByName"
      (-> @element "name", "elementByName2").should.throw()


    it "elementOrNull", wrap ->
      should.exist @elementOrNull "name", "elementByName"
      #should.not.exist @elementOrNull "name", "elementByName2"

    it "hasElement", wrap ->
      (@hasElement "name", "elementByName").should.be.true
      (@hasElement "name", "elementByName2").should.be.false

    it "elements", wrap ->
      (@elements "name", "elementsByName").should.have.length 3
      (@elements "name", "elementsByName2").should.eql []


    for funcSuffix in [
      'ById'
      , 'ByCss'
    ]
      do ->
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

        it elementFuncName, wrap ->
          should.exist @[elementFuncName] searchText
          (-> @[elementFuncName] searchText2).should.throw()

        it elementFuncName + 'IfExists', wrap ->
          should.exist @[elementFuncName + 'IfExists'] searchText
          should.not.exist @[elementFuncName + 'IfExists'] searchText2

        it hasElementFuncName, wrap ->
          (@[hasElementFuncName] searchText).should.be.true
          (@[hasElementFuncName] searchText2).should.be.false

        it elementsFuncName, wrap ->
          res = @[elementsFuncName] searchSeveralText
          if(elementsFuncName.match /ById/)
            res.should.have.length 1
          else if(elementsFuncName.match /ByTagName/)
            (res.length > 1).should.be.true
          else
            res.should.have.length 3
          res = @[elementsFuncName] searchSeveralText2
          res.should.eql []

    it "getAttribute", wrap ->
      testDiv = @elementById "getAttribute"
      should.exist testDiv
      (@getAttribute testDiv, "weather").should.equal "sunny"
      should.not.exist @getAttribute testDiv, "timezone"

    it "getValue (input)", wrap ->
      inputField = @elementByCss "#getValue input"
      should.exist (inputField)
      (@getValue inputField).should.equal "Hello getValueTest!"

    it "click", wrap ->
      numOfClicksDiv = @elementByCss "#click .numOfClicks"
      buttonNumberDiv= @elementByCss "#click .buttonNumber"
      scriptAsCoffee =
        '''
          jQuery ->
            window.numOfClick = 0
            numOfClicksDiv = $('#click .numOfClicks')
            buttonNumberDiv = $('#click .buttonNumber')
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
      @click()
      (@text numOfClicksDiv).should.equal "clicked 2"
      (@text buttonNumberDiv).should.equal "0"
      # not testing right click, cause not sure how to dismiss the right
      # click menu in chrome and firefox

    it "type", wrap ->
      altKey = wdSync.SPECIAL_KEYS['Alt']
      nullKey = wdSync.SPECIAL_KEYS['NULL']
      inputField = @elementByCss "#type input"
      should.exist (inputField)
      @type inputField, "Hello"
      (@getValue inputField).should.equal "Hello"
      @type inputField, [altKey, nullKey, " World"]
      (@getValue inputField).should.equal "Hello World"
      @type inputField, [wdSync.SPECIAL_KEYS.Return] # no effect
      (@getValue inputField).should.equal "Hello World"


    it "keys", wrap ->
      altKey = wdSync.SPECIAL_KEYS['Alt']
      nullKey = wdSync.SPECIAL_KEYS['NULL']
      inputField = @elementByCss "#keys input"
      should.exist (inputField)
      @clickElement inputField
      @keys "Hello"
      (@getValue inputField).should.equal "Hello"
      @keys [altKey, nullKey, " World"]
      (@getValue inputField).should.equal "Hello World"
      @type inputField, [wdSync.SPECIAL_KEYS.Return] # no effect
      (@getValue inputField).should.equal "Hello World"

    it "text (passing element)", wrap ->
      textDiv = @elementByCss "#text"
      should.exist (textDiv)
      (@text textDiv).should.include "text content"
      (@text textDiv).should.not.include "div"

    it "acceptAlert", wrap ->
      a = @elementByCss "#acceptAlert a"
      should.exist (a)
      scriptAsCoffee =
        """
          a = $('#acceptAlert a')
          a.click ->
            alert "coffee is running out"
            false
        """
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
      res = @execute scriptAsJs
      @clickElement a
      @acceptAlert()

    it "active", wrap ->
      i1 = @elementByCss "#active .i1"
      i2 = @elementByCss "#active .i2"
      i1.click()
      @active().value.should.equal i1.value
      @clickElement i2
      @active().value.should.equal i2.value

    it "url", wrap ->
      url = @url()
      url.should.include "local-test-page.html"
      url.should.include "http://"

    it "allCookies / setCookies / deleteAllCookies / deleteCookie", wrap ->
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

    it "uploadFile", wrap ->
      filepath = @uploadFile "test/mocha.opts"
      should.exist filepath
      filepath.should.include 'mocha.opts'

    it "waitForCondition", wrap ->
      scriptAsCoffee =
        '''
          setTimeout ->
            $('#waitForCondition').html '<div class="child">a waitForCondition child</div>'
          , 1500
        '''
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
      @execute scriptAsJs
      should.not.exist @elementByCssIfExists "#waitForCondition .child"
      exprCond = "$('#waitForCondition .child').length > 0"
      (@waitForCondition exprCond, 2000, 200).should.be.true
      (@waitForCondition exprCond, 2000).should.be.true
      (@waitForCondition exprCond).should.be.true
      switch type
        when 'remote'
          (=> @waitForCondition "sdsds ;;sdsd {}").should.throw(/Error response status/)
        when 'headless'
          (=> @waitForCondition "sdsds ;;sdsd {}").should.throw(/Evaluation failure/)

    it "element.text", wrap ->
      el =  @element "id", "el_text"
      el.text().should.include "I am some text"

    it "element.getValue", wrap ->
      el =  @element "id", "el_getValue"
      el.should.have.property "getValue"
      el.getValue().should.equal "value"

    it "err.inspect", wrap ->
      err = null
      try
        browser.safeExecute "invalid-code> here"
      catch _err
        err = _err
      should.exist err
      (err instanceof Error).should.be.true
      (err.inspect().length <= 510).should.be.true

    it "quit", wrap ->
      @quit()

class Express
  start: (done) ->
    @app = express()
    @app.use(express.static(__dirname + '/assets'))
    @server = @app.listen 8181

  stop: (done) ->
    @server.close()

exports.test = test
exports.Express = Express
