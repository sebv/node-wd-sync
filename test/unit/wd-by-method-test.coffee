{wd,Wd, WdWrap} = require '../../index'
should = require 'should'
CoffeeScript = require 'coffee-script'      

test = (browserName) ->

  browser = null;
  WdWrap = WdWrap with: (-> browser)
  capabilities = null

  it "wd.remote", (done) ->
    browser = wd.remote(mode:'sync')
    Wd = Wd with:browser
    done()

  it "init", WdWrap ->
    @init browserName: browserName

  it "capabilities", WdWrap ->
    capabilities = @capabilities()
    should.exist capabilities
    should.exist capabilities.browserName
    should.exist capabilities.platform
       
  it "get", WdWrap ->
    @get "file://#{__dirname}/assets/test-page.html"
          
  it "refresh", WdWrap ->
    @refresh()

  it "eval", WdWrap ->
    (@eval "1+2").should.equal 3
    (@eval "document.title").should.equal "TEST PAGE"
    (@eval "$('#eval').length").should.equal 1
    (@eval "$('#eval li').length").should.equal 2

  it "execute", WdWrap ->
    @execute "window.wd_sync_execute_test = 'It worked!'"
    (@eval "window.wd_sync_execute_test").should.equal 'It worked!'

  # @todo implement async script timeout in wd
  it "executeAsync (async mode)", (done) ->
    scriptAsCoffee =
      """
        [args...,done] = arguments
        done "OK"              
      """
    scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
    browser.executeAsync scriptAsJs, (err,res) ->          
      res.should.equal "OK"
      done()

  it "executeAsync (sync mode)", WdWrap ->
    scriptAsCoffee =
      """
        [args...,done] = arguments
        done "OK"              
      """
    scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
    res = @executeAsync scriptAsJs          
    res.should.equal "OK"
    
  it "setWaitTimeout", WdWrap ->
    @setWaitTimeout 0
    scriptAsCoffee = 
      '''
        jQuery ->
          setTimeout ->
            $('#setWaitTimeout').html '<div class="child">a child</div>'
          , 1000           
      '''
    scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'      
    @execute scriptAsJs
    should.not.exist (@elementByCss "#setWaitTimeout .child")
    @setWaitTimeout 2000
    should.exist (@elementByCss "#setWaitTimeout .child")
    @setWaitTimeout 0
      
  it "element", WdWrap ->      
    should.exist (@element "name", "elementByName")
    should.not.exist (@element "name", "elementByName2") 

  it "elementByLinkText", WdWrap ->      
    should.exist (@elementByLinkText "click helloByLinkText")
    should.not.exist (@elementByLinkText "click helloByLinkText2") 

  it "elementById", WdWrap ->      
    should.exist (@elementById "elementById")
    should.not.exist (@elementById "elementById2") 
      
  it "elementByName", WdWrap ->      
    should.exist (@elementByName "elementByName")
    should.not.exist (@elementByName "elementByName2") 

  it "elementByCss", WdWrap ->      
    should.exist (@elementByCss "#elementByCss")
    should.not.exist (@elementByCss "#elementByCss2")

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
    @moveTo a1 
    (@text current).should.equal "a1"      
    @moveTo a2 
    (@text current).should.equal "a2"
    
  ###
  @todo waiting for implementation
  it "scroll", WdWrap ->
  ###
    
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
    anchor = @elementByCss "#click a" 
    (@text anchor).should.equal "not clicked"
    scriptAsCoffee = 
      '''
        jQuery ->
          a = $('#click a')
          a.click ->
            a.html 'clicked'              
      '''
    scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'      
    @execute scriptAsJs
    (@text anchor).should.equal "not clicked"
    @moveTo anchor
    @click 0
    (@text anchor).should.equal "clicked"
    @click() 
             
  it "doubleclick", WdWrap ->
    anchor = @elementByCss "#doubleclick a" 
    (@text anchor).should.equal "not clicked"
    scriptAsCoffee = 
      '''
        jQuery ->
          a = $('#doubleclick a')
          a.click ->
            a.html 'clicked'              
      '''
    scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'      
    @execute scriptAsJs
    (@text anchor).should.equal "not clicked"
    @moveTo anchor
    @doubleclick 0
    (@text anchor).should.equal "clicked"
    @doubleclick()
      
  it "type", WdWrap ->
    inputField = @elementByCss "#type input"       
    should.exist (inputField)
    @type inputField, "Hello World"
    (@getValue inputField).should.equal "Hello World" 
    @type inputField, "\n" # no effect
    (@getValue inputField).should.equal "Hello World" 

  it "clear", WdWrap ->
    inputField = @elementByCss "#clear input"
    should.exist (inputField)
    (@getValue inputField).should.equal "not cleared"
    @clear inputField 
    (@getValue inputField).should.equal ""
       
  it "title", WdWrap ->
    @title().should.equal "TEST PAGE"
                  
  it "text", WdWrap ->
    textDiv = @elementByCss "#text"             
    should.exist (textDiv)
    (@text textDiv).should.include "text content" 
    (@text textDiv).should.not.include "div" 
    
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
    @clickElement i1
    @active().should.equal i1
    @clickElement i2
    @active().should.equal i2
      
  it "url", WdWrap ->
    @url().should.include "/test/unit/assets/test-page.html"
        
  it "close", WdWrap ->        
    @close()

  it "quit", WdWrap ->        
    @quit()

describe "wd-sync", ->

  describe "method by method tests", ->

    describe "using chrome", ->
      test 'chrome'

    describe "using firefox", ->
      test 'firefox'
