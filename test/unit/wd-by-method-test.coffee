{wd,Wd, WdWrap} = require '../../index'
should = require 'should'
CoffeeScript = require 'coffee-script'      

testWithBrowser = (browserName) ->
  it "using #{browserName}", (done) ->
    @setWaitTimeout 3000      
    done()

describe "wd-sync", ->

  describe "method tests", ->

    browser = null;
    WdWrap = WdWrap with: (-> browser)

    it "wd.remote", (done) ->
      browser = wd.remote(mode:'sync')
      Wd = Wd with:browser
      done()

    it "init", WdWrap ->
      @init browserName: "chrome"
    
    it "get", WdWrap ->
      @get "file://#{__dirname}/assets/test-page.html"

    it "refresh", WdWrap ->
      @refresh()

    it "eval", WdWrap ->
      (@eval "1+2").should.equal 3
      (@eval "document.title").should.equal "TEST PAGE"
      (@eval "$('#evalTest').length").should.equal 1
      (@eval "$('#evalTest li').length").should.equal 2

    it "execute", WdWrap ->
      @execute "window.wd_sync_execute_test = 'It worked!'"
      (@eval "window.wd_sync_execute_test").should.equal 'It worked!'

    # TODO implement async script timeout in wd
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
      # TBD
            
    it "element", WdWrap ->      
      should.exist (@element "name", "helloByName")
      should.not.exist (@element "name", "helloByName2") 

    it "elementByLinkText", WdWrap ->      
      should.exist (@elementByLinkText "click helloByLinkText")
      should.not.exist (@elementByLinkText "click helloByLinkText2") 

    it "elementById", WdWrap ->      
      should.exist (@elementById "helloById")
      should.not.exist (@elementById "helloById2") 
      
    it "elementByName", WdWrap ->      
      should.exist (@elementByName "helloByName")
      should.not.exist (@elementByName "helloByName2") 

    it "elementByCss", WdWrap ->      
      should.exist (@elementByCss "#helloById")
      should.not.exist (@elementByCss "#helloById2")

    it "getAttribute", WdWrap ->
      testDiv = @elementById "getAttributeTest"      
      should.exist testDiv
      (@getAttribute testDiv, "weather").should.equal "sunny"
      should.not.exist @getAttribute testDiv, "timezone"

    it "getValue (input)", WdWrap ->
      inputField = @elementByCss "#getValueTest input"       
      should.exist (inputField)
      (@getValue inputField).should.equal "Hello getValueTest!" 

    it "getValue (textarea)", WdWrap ->
      inputField = @elementByCss "#getValueTest2 textarea"       
      should.exist (inputField)
      (@getValue inputField).should.equal "Hello getValueTest2!" 

    it "clickElement", WdWrap ->
      #TODO

    it "moveTo", WdWrap ->
      #TODO

    it "scroll", WdWrap ->
      #TODO

    it "buttonDown", WdWrap ->
      #TODO
         
    it "buttonUp", WdWrap ->
      #TODO
                
    it "click", WdWrap ->
      #TODO
             
    it "doubleclick", WdWrap ->
      #TODO

    it "type", WdWrap ->
      inputField = @elementByCss "#typeTest input"       
      should.exist (inputField)
      @type inputField, "Hello World"
      (@getValue inputField).should.equal "Hello World" 
      @type inputField, "\n" # no effect
      (@getValue inputField).should.equal "Hello World" 

    it "clear", WdWrap ->
      #TODO

    it "title", WdWrap ->
      @title().should.equal "TEST PAGE"
                  
    it "text", WdWrap ->
      textDiv = @elementByCss "#textTest"             
      should.exist (textDiv)
      (@text textDiv).should.include "textTest content" 
      (@text textDiv).should.not.include "div" 

    it "textPresent", WdWrap ->
      #TODO

    it "dismiss_alert", WdWrap ->
      #TODO

    it "active", WdWrap ->
      #TODO

    it "keyToggle", WdWrap ->
      #TODO
    
    it "url", WdWrap ->
      #TODO
        
    it "close", WdWrap ->        
      @close()
        
    it "quit", WdWrap ->        
      @quit()
