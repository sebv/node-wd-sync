{testWithBrowser,testCurrent} = require '../common/basic-test-base'

describe "wd-sync", -> 
  describe "unit", ->
    for browserName in ['chrome']
      testWithBrowser 
        type: 'remote' 
        desired:
          browserName:browserName
    
    testCurrent    
      type: 'remote' 
      desired:
        browserName:'chrome'
  