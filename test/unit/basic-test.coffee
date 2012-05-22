{testWithBrowser,testCurrent} = require '../common/basic-test-base'

describe "wd-sync", -> \
describe "unit", -> \
describe "basic tests", ->
  describe "browsing", ->
    for browserName in ['chrome', 'firefox', undefined]
      testWithBrowser 'remote', browserName
  describe "ws.current()", ->  
    testCurrent('remote')    
  