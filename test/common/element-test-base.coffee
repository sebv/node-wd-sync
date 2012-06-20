{wd,Wd, WdWrap} = require '../../index'
should = require 'should'
CoffeeScript = require 'coffee-script'      
async = require 'async'
express = require 'express'

test = (type, browserName) ->

  browser = null;
  WdWrap = WdWrap with: (-> browser)
  capabilities = null

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

  it "init", WdWrap ->
    @init(
      browserName: browserName
      #debug: true
    )

  it "get", WdWrap ->
    @get "http://127.0.0.1:8181/element-test-page.html"

  it "element.text", WdWrap ->
    el =  @element "id", "text"
    el.text().should.include "I am some text"

  it "element.textPresent", WdWrap ->
    el =  @element "id", "text"
    (el.textPresent "some text").should.be.true

  it "element.textPresent", WdWrap ->
    el =  @element "id", "getAttribute"
    el.should.have.property "getAttribute"
    (el.getAttribute "att").should.equal "42"

  it "element.getValue", WdWrap ->
    el =  @element "id", "getValue"
    el.should.have.property "getValue"
    el.getValue().should.equal "value"

  it "element.sendKeys", WdWrap ->
    text = "keys"
    el =  @element "id", "sendKeys"
    el.should.have.property "sendKeys"
    el.sendKeys text
    el.getValue().should.equal text

  it "element.clear", WdWrap ->
    el =  @element "id", "clear"
    el.should.have.property "clear"
    el.clear()
    el.getValue().should.equal ""

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

