{wd,Wd, WdWrap} = require '../../index'
should = require 'should'
CoffeeScript = require 'coffee-script'      
async = require 'async'
express = require 'express'

test = (type, browserName) ->

  browser = null;
  WdWrap = WdWrap with: (-> browser)
  capabilities = null

  describe "method by method tests using #{browserName}", ->
  
    it "wd.remote or wd.headless", (done) ->
      switch type
        when 'remote'
          browser = wd.remote()
          browser.on "status", (info) ->
            console.log "\u001b[36m%s\u001b[0m", info
          browser.on "command", (meth, path) ->
            console.log " > \u001b[33m%s\u001b[0m: %s", meth, path    
          Wd = Wd with:browser
          done()
        when 'headless'
          browser = wd.headless()
          Wd = Wd with:browser
          done()      

    it "status", WdWrap ->
      should.exist @status()

    it "sessions", WdWrap ->
      should.exist @sessions()

    it "init", WdWrap ->
      @init(
        browserName: browserName
        #debug: true
      )
  
    it "sessionCapabilities", WdWrap ->
      capabilities = @sessionCapabilities()
      should.exist capabilities
      should.exist capabilities.browserName
      should.exist capabilities.platform
  
    it "altSessionCapabilities", WdWrap ->
      capabilities = @altSessionCapabilities()
      should.exist capabilities
      should.exist capabilities.browserName
      should.exist capabilities.platform

    it "get", WdWrap ->
      @get "http://127.0.0.1:8181/per-method-test-page.html"
  
    it "setPageLoadTimeout", WdWrap ->
      unless capabilities.browserName is 'chrome'
        @setPageLoadTimeout 5000            
  
    it "get (following setPageLoadTimeout)", WdWrap ->
      @get "http://127.0.0.1:8181/per-method-test-page.html"

      it "setPageLoadTimeout (disabling)", WdWrap ->
        unless capabilities.browserName is 'chrome'
          @setPageLoadTimeout -1       

    it "refresh", WdWrap ->
      @refresh()

    it "get other page", WdWrap ->
      @get "http://127.0.0.1:8181/per-method-test-page.html?p=2"
      @url().should.include "?p=2"

    it "back", WdWrap ->
      @back()
      @url().should.not.include "?p=2"
  
    it "forward", WdWrap ->
      @forward()
      @url().should.include "?p=2"    
      #@get "http://127.0.0.1:8181/per-method-test-page.html"
  
    it "eval", WdWrap ->
      (@eval "1+2").should.equal 3
      (@eval "document.title").should.equal "TEST PAGE"
      (@eval "$('#eval').length").should.equal 1
      (@eval "$('#eval li').length").should.equal 2
    
    it "safeEval", WdWrap ->
      (@safeEval "1+2").should.equal 3
      (@safeEval "document.title").should.equal "TEST PAGE"
      (@safeEval "$('#eval').length").should.equal 1
      (@safeEval "$('#eval li').length").should.equal 2
      switch type
        when 'remote'    
          (=> @safeEval "++wrong >expr").should.throw(/Error response status/)  
        when 'headless'    
          (=> @safeEval "++wrong >expr").should.throw(/Evaluation failure/)
        
    it "execute (no args)", WdWrap ->
      @execute "window.wd_sync_execute_test = 'It worked!'"
      (@eval "window.wd_sync_execute_test").should.equal 'It worked!'

    it "execute (with args)", WdWrap ->
      script = "window.wd_sync_execute_test = 'It worked! ' + (arguments[0] + arguments[1])"
      @execute script, [10, 5]
      (@eval "window.wd_sync_execute_test").should.equal 'It worked! 15'

    it "safeExecute (no args)", WdWrap ->
      @safeExecute "window.wd_sync_execute_test = 'It worked!'"
      (@eval "window.wd_sync_execute_test").should.equal 'It worked!'
      switch type
        when 'remote'    
          (=> @safeExecute "a wrong <> expr").should.throw(/Error response status/)
        when 'headless'    
          (=> @safeExecute "a wrong <> expr").should.throw(/Execution failure/)

    it "safeExecute (with args)", WdWrap ->
      script = "window.wd_sync_execute_test = 'It worked! ' + (arguments[0] + arguments[1])"
      @safeExecute script, [10, 5]
      (@eval "window.wd_sync_execute_test").should.equal 'It worked! 15'
      switch type
        when 'remote'    
          (=> @safeExecute "a wrong <> expr", [10, 5]).should.throw(/Error response status/)
        when 'headless'    
          (=> @safeExecute "a wrong <> expr", [10, 5]).should.throw(/Execution failure/)
  
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

    it "executeAsync (async mode, with args)", (done) ->
      scriptAsCoffee =
        """
          [args...,done] = arguments
          done("OK " + (args[0]+args[1]))              
        """
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
      browser.executeAsync scriptAsJs, [10, 4], (err,res) ->          
        res.should.equal "OK 14"
        done()
  
    it "safeExecuteAsync (async mode, no args)", (done) ->
      async.series [
        (done) ->
          scriptAsCoffee =
            """
              [args...,done] = arguments
              done "OK"              
            """
          scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
          browser.safeExecuteAsync scriptAsJs, (err,res) ->          
            res.should.equal "OK"
            done(null)
        (done) ->
          browser.safeExecuteAsync "a @@ wrong expr!", (err,res) ->          
            should.exist err
            (err instanceof Error).should.be.true
            done(null)
      ], ->
        done()
      
    it "safeExecuteAsync (async mode, with args)", (done) ->
      async.series [
        (done) ->
          scriptAsCoffee =
            """
              [args...,done] = arguments
              done("OK " + (args[0]+args[1]))              
            """
          scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
          browser.safeExecuteAsync scriptAsJs, [10, 4], (err,res) ->          
            res.should.equal "OK 14"
            done(null)
        (done) ->
          browser.safeExecuteAsync "a @@ wrong expr!", [10, 4], (err,res) ->          
            should.exist err
            (err instanceof Error).should.be.true
            done(null)
      ], ->
        done()

    it "executeAsync (sync mode, no args)", WdWrap ->
      scriptAsCoffee =
        """
          [args...,done] = arguments
          done "OK"              
        """
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
      res = @executeAsync scriptAsJs          
      res.should.equal "OK"

    it "executeAsync (sync mode, with args)", WdWrap ->
      scriptAsCoffee =
        """
          [args...,done] = arguments
          done("OK " + (args[0] + args[1]))              
        """
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
      res = @executeAsync scriptAsJs, [10, 2]          
      res.should.equal "OK 12"
  
    it "safeExecuteAsync (sync mode, no args)", WdWrap ->
      scriptAsCoffee =
        """
          [args...,done] = arguments
          done "OK"              
        """
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
      res = @safeExecuteAsync scriptAsJs          
      res.should.equal "OK"
      switch type
        when 'remote'    
          (=> @safeExecuteAsync "!!!a wrong expr").should.throw(/Error response status/)
        when 'headless'    
          (=> @safeExecuteAsync "!!!a wrong expr").should.throw(/Execution failure/)
    
    it "safeExecuteAsync (sync mode, with args)", WdWrap ->
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
  
    it "setWaitTimeout / setImplicitWaitTimeout", WdWrap ->
      @setWaitTimeout 0
      scriptAsCoffee = 
        '''
          setTimeout ->
            $('#setWaitTimeout').html '<div class="child">a child</div>'
          , 1000           
        '''
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'      
      @execute scriptAsJs
      # selenium server throws not found exception, this is normal
      should.not.exist (@elementByCssIfExists "#setWaitTimeout .child")
      @setImplicitWaitTimeout 2000
      should.exist (@elementByCss "#setWaitTimeout .child")
      @setWaitTimeout 0
  
    it "setAsyncScriptTimeout", WdWrap ->
      @setAsyncScriptTimeout 500
      scriptAsCoffee =
        """
          [args...,done] = arguments
          setTimeout ->
            done "OK"
          , 2000
        """
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
      err = null;
      try
        @executeAsync scriptAsJs
      catch _err
        err = _err
      should.exist err
      err.status.should.equal 28
      @setAsyncScriptTimeout 2000
      scriptAsCoffee =
        """
          [args...,done] = arguments
          setTimeout ->
            done "OK"
          , 500
        """
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
      res = @executeAsync scriptAsJs          
      res.should.equal "OK"
      @setAsyncScriptTimeout 0
    
    it "element", WdWrap ->
      should.exist @element "name", "elementByName"      
      (-> @element "name", "elementByName2").should.throw()
  
  
    it "elementOrNull", WdWrap ->      
      should.exist @elementOrNull "name", "elementByName"
      #should.not.exist @elementOrNull "name", "elementByName2"
  
    it "elementIfExists", WdWrap ->      
      should.exist @elementIfExists "name", "elementByName"
      should.not.exist @elementIfExists "name", "elementByName2"

    it "hasElement", WdWrap ->      
      (@hasElement "name", "elementByName").should.be.true;
      (@hasElement "name", "elementByName2").should.be.false;

    it "element", WdWrap ->      
      (@elements "name", "elementsByName").should.have.length 3
      (@elements "name", "elementsByName2").should.eql []

            
    for funcSuffix in [
      'ByClassName'
      , 'ByCssSelector' 
      , 'ById'
      , 'ByName' 
      , 'ByLinkText'
      , 'ByPartialLinkText'
      , 'ByTagName' 
      , 'ByXPath' 
      , 'ByCss'
    ]     
      do ->
        elementFuncName = 'element' + funcSuffix
        hasElementFuncName = 'hasElement' + funcSuffix
        elementsFuncName = 'elements' + funcSuffix
      
        searchText = elementFuncName;
        searchText = "click #{searchText}" if searchText.match /ByLinkText/
        searchText = ".#{searchText}" if searchText.match /ByCss/
        searchText = "//div[@id='elementByXPath']/input" if searchText.match /ByXPath/
        searchText = "span" if searchText.match /ByTagName/
          
        searchText2 = searchText + '2';
        searchText2 = "//div[@id='elementByXPath2']/input" if searchText.match /ByXPath/
        searchText2 = "span2" if searchText.match /ByTagName/
        
        searchSeveralText = searchText.replace('element','elements') 
        searchSeveralText2 = searchText2.replace('element','elements') 
       
        it elementFuncName, WdWrap ->  
          should.exist @[elementFuncName] searchText
          (-> @[elementFuncName] searchText2).should.throw()
      
        it elementFuncName + 'OrNull', WdWrap ->
          should.exist @[elementFuncName + 'OrNull'] searchText
          should.not.exist @[elementFuncName + 'OrNull'] searchText2

        it elementFuncName + 'IfExists', WdWrap ->
          should.exist @[elementFuncName + 'IfExists'] searchText
          should.not.exist @[elementFuncName + 'IfExists'] searchText2

        it hasElementFuncName, WdWrap ->
          (@[hasElementFuncName] searchText).should.be.true
          (@[hasElementFuncName] searchText2).should.be.false

        it elementsFuncName, WdWrap ->
          res = @[elementsFuncName] searchSeveralText
          if(elementsFuncName.match /ById/)
            res.should.have.length 1
          else if(elementsFuncName.match /ByTagName/)
            (res.length > 1).should.be.true
          else
            res.should.have.length 3          
          res = @[elementsFuncName] searchSeveralText2
          res.should.eql []
  
    it "getAttribute", WdWrap ->
      testDiv = @elementById "getAttribute"      
      should.exist testDiv
      (@getAttribute testDiv, "weather").should.equal "sunny"
      should.not.exist @getAttribute testDiv, "timezone"

    it "getValue (input)", WdWrap ->
      inputField = @elementByCss "#getValue input"       
      should.exist (inputField)
      (@getValue inputField).should.equal "Hello getValueTest!" 

    it "getValue (textarea)", WdWrap ->
      inputField = @elementByCss "#getValue textarea"       
      should.exist (inputField)
      (@getValue inputField).should.equal "Hello getValueTest2!" 
      
    it "clickElement", WdWrap ->
      anchor = @elementByCss "#clickElement a" 
      (@text anchor).should.equal "not clicked"
    
      scriptAsCoffee = 
        '''
          jQuery ->
            a = $('#clickElement a')
            a.click ->
              a.html 'clicked'    
              false          
        '''
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'      
      @execute scriptAsJs
    
      (@text anchor).should.equal "not clicked"
      @clickElement anchor
      (@text anchor).should.equal "clicked"
      
    it "moveTo", WdWrap ->
      a1 = @elementByCss "#moveTo .a1" 
      a2 = @elementByCss "#moveTo .a2" 
      current = @elementByCss "#moveTo .current"
      should.exist a1  
      should.exist a2  
      should.exist current  
      (@text current).should.equal ""
      scriptAsCoffee = 
        '''
          jQuery ->
            a1 = $('#moveTo .a1')
            a2 = $('#moveTo .a2')
            current = $('#moveTo .current')
            a1.hover ->
              current.html 'a1'
            a2.hover ->
              current.html 'a2'
        '''
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'      
      @execute scriptAsJs
      (@text current).should.equal ""
      @moveTo a1, 5, 5 
      (@text current).should.equal "a1"      
      @moveTo a2 
      (@text current).should.equal "a2"
    
  
    # @todo waiting for implementation
    # it "scroll", WdWrap ->
  
    
    it "buttonDown / buttonUp", WdWrap ->
      a = @elementByCss "#mouseButton a"
      resDiv = @elementByCss "#mouseButton div"
      should.exist a
      should.exist resDiv
      scriptAsCoffee = 
        '''
          jQuery ->
            a = $('#mouseButton a')
            resDiv = $('#mouseButton div')
            a.mousedown ->
              resDiv.html 'button down'
            a.mouseup ->
              resDiv.html 'button up'
        '''
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'      
      @execute scriptAsJs
      (@text resDiv).should.equal ''
      @moveTo a
      @buttonDown()
      (@text resDiv).should.equal 'button down'
      @buttonUp()
      (@text resDiv).should.equal 'button up'
  
    it "click", WdWrap ->      
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
  
    it "doubleclick", WdWrap ->
      div = @elementByCss "#doubleclick div" 
      (@text div).should.equal "not clicked"
      scriptAsCoffee = 
            '''
              jQuery ->
                div = $('#doubleclick div')
                div.dblclick ->
                  div.html 'doubleclicked'                                                 
            '''
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'  
      @execute scriptAsJs    
      @moveTo div
      @doubleclick()
      (@text div).should.equal "doubleclicked"
      
    it "type", WdWrap ->
      altKey = wd.SPECIAL_KEYS['Alt']
      nullKey = wd.SPECIAL_KEYS['NULL']    
      inputField = @elementByCss "#type input"       
      should.exist (inputField)
      @type inputField, "Hello"
      (@getValue inputField).should.equal "Hello" 
      @type inputField, [altKey, nullKey, " World"]
      (@getValue inputField).should.equal "Hello World"       
      @type inputField, [wd.SPECIAL_KEYS.Return] # no effect
      (@getValue inputField).should.equal "Hello World" 

  
    it "keys", WdWrap ->
      altKey = wd.SPECIAL_KEYS['Alt']
      nullKey = wd.SPECIAL_KEYS['NULL']    
      inputField = @elementByCss "#keys input"           
      should.exist (inputField)
      @clickElement inputField
      @keys "Hello"
      (@getValue inputField).should.equal "Hello" 
      @keys [altKey, nullKey, " World"]
      (@getValue inputField).should.equal "Hello World" 
      @type inputField, [wd.SPECIAL_KEYS.Return] # no effect
      (@getValue inputField).should.equal "Hello World" 
  
    it "clear", WdWrap ->
      inputField = @elementByCss "#clear input"
      should.exist (inputField)
      (@getValue inputField).should.equal "not cleared"
      @clear inputField 
      (@getValue inputField).should.equal ""
       
    it "title", WdWrap ->
      @title().should.equal "TEST PAGE"
                  
    it "text (passing element)", WdWrap ->
      textDiv = @elementByCss "#text"             
      should.exist (textDiv)
      (@text textDiv).should.include "text content" 
      (@text textDiv).should.not.include "div" 

    it "text (passing undefined)", WdWrap ->
      res = @text undefined
      # the whole page text is returned
      res.should.include "text content" 
      res.should.include "sunny" 
      res.should.include "click elementsByLinkText"
      res.should.not.include "div" 

    it "text (passing body)", WdWrap ->
      res = @text 'body'        # the whole page text is returned
      res.should.include "text content" 
      res.should.include "sunny" 
      res.should.include "click elementsByLinkText"
      res.should.not.include "div" 

    it "text (passing null)", WdWrap ->
      res = @text null
      # the whole page text is returned
      res.should.include "text content" 
      res.should.include "sunny" 
      res.should.include "click elementsByLinkText"
      res.should.not.include "div" 
    
    it "textPresent", WdWrap ->
      textDiv = @elementByCss "#textPresent"
      should.exist (textDiv)
      (@textPresent 'sunny', textDiv).should.be.true
      (@textPresent 'raining', textDiv).should.be.false          
  
    it "acceptAlert", WdWrap ->
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

    it "dismissAlert", WdWrap ->
      a = @elementByCss "#dismissAlert a"
      should.exist (a)
      scriptAsCoffee =
        """
          a = $('#dismissAlert a')
          a.click ->
            alert "coffee is running out"
            false
        """
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
      res = @execute scriptAsJs          
      @clickElement a
      # known bug on chrome/mac, need to use acceptAlert instead
      unless (capabilities.platform is 'MAC' and 
        capabilities.browserName is 'chrome')
          @dismissAlert()
      else
        @acceptAlert()
        
    it "active", WdWrap ->
      i1 = @elementByCss "#active .i1" 
      i2 = @elementByCss "#active .i2" 
      i1.click()
      @active().value.should.equal i1.value
      @clickElement i2
      @active().value.should.equal i2.value

    it "url", WdWrap ->
      url = @url() 
      url.should.include "per-method-test-page.html"
      url.should.include "http://"
  
    it "allCookies / setCookies / deleteAllCookies / deleteCookie", WdWrap ->
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
  
    it "waitForCondition", WdWrap ->
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
    
    
    it "waitForConditionInBrowser", WdWrap ->
      scriptAsCoffee = 
        '''
          setTimeout ->
            $('#waitForConditionInBrowser').html '<div class="child">a waitForCondition child</div>'
          , 1500
        '''
      scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'      
      @execute scriptAsJs
      should.not.exist @elementByCssIfExists "#waitForConditionInBrowser .child"
      @setAsyncScriptTimeout 5000
      exprCond = "$('#waitForConditionInBrowser .child').length > 0"
      (@waitForConditionInBrowser exprCond, 2000, 200).should.be.true         
      (@waitForConditionInBrowser exprCond, 2000).should.be.true         
      (@waitForConditionInBrowser exprCond).should.be.true         
      switch type
        when 'remote'    
          (=> @waitForConditionInBrowser "sdsds ;;sdsd {}").should.throw(/Error response status/)
          (=> @waitForCondition "sdsds ;;sdsd {}").should.throw(/Error response status/)
        when 'headless'    
          (=> @waitForConditionInBrowser "sdsds ;;sdsd {}").should.throw(/Execution failure/)
      @setAsyncScriptTimeout 0
  
  
    it "err.inspect", WdWrap ->        
      err = null;
      try
        browser.safeExecute "invalid-code> here"
      catch _err
        err = _err
      should.exist err    
      (err instanceof Error).should.be.true
      switch type
        when 'remote'
          err.inspect().should.include '"screen": "[hidden]"'
          err.inspect().should.include 'browser-error:'

    it "close", WdWrap ->        
      @close()
  
    it "quit", WdWrap ->        
      @quit()

class Express
  start: (done) ->
    @app = express.createServer()
    @app.use(express.static(__dirname + '/assets'));
    @app.listen 8181
        
  stop: (done) ->
    @app.close()
    
exports.test = test
exports.Express = Express
