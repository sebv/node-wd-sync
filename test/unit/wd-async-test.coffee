{wd,Wd} = require '../../index'
should = require 'should'

testWithBrowser = (browserName) ->
  it "using #{browserName}", (done) ->
    browser = wd.remote(mode:'async')        
    browser.init browserName: "#{browserName}" , (err) ->
      browser.get "http://google.com", (err) ->
        browser.title (err, title) ->
          title.toLowerCase().should.include 'google'          
          browser.elementByName 'q', (err, queryField) ->
            browser.type queryField, "Hello World", (err) ->  
              browser.type queryField, "\n", (err) ->
                browser.setWaitTimeout 3000 , (err) ->      
                  browser.elementByCss '#ires', (err, resDiv)  ->
                    browser.title (err, title) ->
                      title.toLowerCase().should.include 'hello world'
                      browser.quit ->
                        done()

describe "wd-sync", -> \
describe "async tests", ->  
  for browserName in ['firefox','chrome']
    testWithBrowser browserName
