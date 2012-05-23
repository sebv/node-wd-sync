should = require 'should'
CoffeeScript = require 'coffee-script'      
express = require 'express'
_ = require 'underscore'

{wd,Wd, WdWrap} = require '../../index'

altKey = wd.SPECIAL_KEYS['Alt']
nullKey = wd.SPECIAL_KEYS['NULL']
returnKey = wd.SPECIAL_KEYS['Return']
enterKey = wd.SPECIAL_KEYS['Enter']

click = (sel) ->
  field = wd.current().elementByCssOrNull sel  
  wd.current().clickElement field


keysAndCheck = (sel, entered,expected) ->
  field = wd.current().elementByCssOrNull sel      
  unless (entered is "") or (_.isEqual entered, [])   
    wd.current().moveTo field
    wd.current().keys entered    
  (wd.current().getValue field).should.equal expected 

typeAndCheck = (sel, entered,expected) ->
  field = wd.current().elementByCssOrNull sel  
  wd.current().type field, entered
  (wd.current().getValue field).should.equal expected 

inputAndCheck = (method, sel, entered,expected) ->
  switch method
    when 'type' then typeAndCheck sel, entered, expected
    when 'keys' then keysAndCheck sel, entered, expected
      
clearAndCheck = (sel) ->
  field = wd.current().elementByCssOrNull sel 
  wd.current().clear field
  (wd.current().getValue field).should.equal "" 

preventDefault = (_sel, eventType) ->
  scriptAsCoffee =
    """
      $('#{_sel}').#{eventType} (e) ->
        e.preventDefault()
    """
  scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
  wd.current().execute scriptAsJs          


unbind = (_sel, eventType) ->
  scriptAsCoffee =
    """
      $('#{_sel}').unbind '#{eventType}' 
    """
  scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
  wd.current().execute scriptAsJs          

altKeyTracking = (_sel) ->
  scriptAsCoffee =
    """
      f = $('#{_sel}')
      f.keydown (e) ->
        if e.altKey
          f.val 'altKey on'
        else
          f.val 'altKey off'
        e.preventDefault()
    """    
  scriptAsJs = CoffeeScript.compile scriptAsCoffee, bare:'on'
  wd.current().execute scriptAsJs          

browser = null;
WdWrap = WdWrap with: (-> browser)

testMethod = (method, sel, browserName) ->
  it "0/ click", WdWrap -> 
    click sel                  
  it "1/ typing nothing", WdWrap -> 
    inputAndCheck method, sel, "", ""                  
  it "2/ typing []", WdWrap -> 
    inputAndCheck method, sel, [], ""
  it "3/ typing 'Hello'", WdWrap -> 
    inputAndCheck method, sel, 'Hello', 'Hello'
  it "4/ clear", WdWrap -> 
    clearAndCheck sel        
  it "5/ typing ['Hello']", WdWrap -> 
    inputAndCheck method, sel, ['Hello'], 'Hello'
  it "6/ clear", WdWrap ->
    clearAndCheck sel
  it "7/ typing ['Hello',' ','World','!']", WdWrap -> 
    inputAndCheck method, sel, ['Hello',' ','World','!'], 'Hello World!'
  it "8/ clear", WdWrap -> 
    clearAndCheck sel        
  it "9/ typing 'Hello\\n'", WdWrap -> 
    inputAndCheck method, sel, 'Hello\n', 
      (if sel.match /input/ then 'Hello' else 'Hello\n')
  it "10/ typing '\\r'", WdWrap -> 
    switch browserName
      when 'chrome' # chrome chrashes when sent '\r'
        inputAndCheck method, sel, [returnKey], 
          (if sel.match /input/ then 'Hello' else 'Hello\n\n')    
      else
        inputAndCheck method, sel, '\r', 
          (if sel.match /input/ then 'Hello' else 'Hello\n\n')    
  it "11/ typing [returnKey]", WdWrap -> 
    inputAndCheck method, sel, [returnKey],
      (if sel.match /input/ then 'Hello' else 'Hello\n\n\n')    
  it "12/ typing [enterKey]", WdWrap -> 
    inputAndCheck method, sel, [enterKey],
      (if sel.match /input/ then 'Hello' else 'Hello\n\n\n\n')    
  it "13/ typing ' World!'", WdWrap -> 
    inputAndCheck method, sel, ' World!',
      (if sel.match /input/ then 'Hello World!' else 'Hello\n\n\n\n World!')    
  it "14/ clear", WdWrap -> 
    clearAndCheck sel                
  it "15/ preventing default on keydown", WdWrap -> 
    preventDefault sel, 'keydown'      
  it "16/ typing 'Hello'", WdWrap -> 
    inputAndCheck method, sel, 'Hello', ''
  it "17/ unbinding keydown", WdWrap ->
    unbind sel, 'keydown'      
  it "18/ typing 'Hello'", WdWrap -> 
    inputAndCheck method, sel, 'Hello', 'Hello'
  it "19/ clear", WdWrap -> 
    clearAndCheck sel                
  it "20/ preventing default on keypress", WdWrap -> 
    preventDefault sel, 'keypress'      
  it "21/ typing 'Hello'", WdWrap -> 
    inputAndCheck method, sel, 'Hello', ''
  it "22/ unbinding keypress", WdWrap ->
    unbind sel, 'keypress'      
  it "23/ typing 'Hello'", WdWrap -> 
    inputAndCheck method, sel, 'Hello', 'Hello'
  it "24/ clear", WdWrap -> 
    clearAndCheck sel                        
  it "25/ preventing default on keyup", WdWrap -> 
    preventDefault sel, 'keyup'      
  it "26/ typing 'Hello'", WdWrap -> 
    inputAndCheck method, sel, 'Hello', 'Hello'
  it "27/ unbinding keypress", WdWrap ->
    unbind sel, 'keyup'      
  it "28/ clear", WdWrap -> 
    clearAndCheck sel                                
  it "29/ adding alt key tracking", WdWrap ->         
    altKeyTracking sel   
  it "30/ typing ['a']", WdWrap -> 
    inputAndCheck method, sel, ['a'], 'altKey off'
  it "31/ typing [altKey,nullKey,'a']", WdWrap -> 
    inputAndCheck method, sel, [altKey,nullKey,'a'], 'altKey off'
  it "32/ typing [altKey,'a']", WdWrap -> 
    inputAndCheck method, sel, [altKey,'a'], 'altKey on'
  it "33/ typing ['a']", WdWrap -> 
    inputAndCheck method, sel, ['a'], 
      switch method 
        when 'keys' then 'altKey on'
        else 'altKey off'
  it "34/ clear", WdWrap -> 
    clearAndCheck sel                                
  it "35/ typing [nullKey]", WdWrap -> 
    inputAndCheck method, sel, [nullKey], ''
  it "36/ typing ['a']", WdWrap -> 
    inputAndCheck method, sel, ['a'], 'altKey off'        
  it "37/ clear", WdWrap -> 
    clearAndCheck sel                        
  it "38/ unbinding keydown", WdWrap ->
    unbind sel, 'keydown'     

test = (type, browserName) ->
  
  describe 'typing', ->
    before (done) ->
      @app = express.createServer()
      @app.use(express.static(__dirname + '/assets'));
      @app.listen 8181
      done null
              
    after (done) ->
      @app.close()
      done null
    
    describe 'wd initialization', ->
      it "wd.remote or wd.headless", (done) ->
        switch type
          when 'remote'
            browser = wd.remote()
            browser.on "status", (info) ->
              console.log "\u001b[36m%s\u001b[0m", info
            browser.on "command", (meth, path) ->
              console.log " > \u001b[33m%s\u001b[0m: %s", meth, path    
            Wd = Wd with:browser
            done null
          when 'headless'
            browser = wd.headless()
            Wd = Wd with:browser
            done null      
    
      it "init", WdWrap ->
        @init(
          browserName: browserName
          #debug: true
        )

      it "get", WdWrap ->
        @get "http://127.0.0.1:8181/typing-test-page.html"
    
    describe 'input', ->
      describe 'type', ->
        testMethod 'type', "#type input", browserName            
      describe 'keys', ->
        testMethod 'keys', "#type input", browserName       
    describe 'textarea', ->
      describe 'type', ->
        testMethod 'type', "#type textarea", browserName            
      describe 'keys', ->
        testMethod 'keys', "#type textarea", browserName            
    
    describe 'clean', ->
      it "quit", WdWrap ->        
        @quit()
      
exports.test = test
