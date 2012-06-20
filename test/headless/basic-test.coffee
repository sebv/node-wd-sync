{testWithBrowser,testCurrent} = require '../common/basic-test-base'

describe "wd-sync", -> 
  describe "headless", ->
    for browserName in [undefined, 'zombie']
      testWithBrowser 
        type: 'headless' 
        desired:
          browserName:browserName
    
    testCurrent    
      type: 'headless' 
      desired:
        browserName:'chrome'
