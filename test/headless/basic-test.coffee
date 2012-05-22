{testWithBrowser,testCurrent} = require '../common/basic-test-base'

describe "wd-sync", -> \
describe "headless", -> \
describe "basic tests", ->
  describe "browsing", ->
    for browserName in [undefined, 'zombie']
      testWithBrowser 'headless', browserName
  
  describe "ws.current()", ->  
    testCurrent('headless')    
  