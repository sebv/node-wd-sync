{testWithBrowser,testCurrent} = require '../common/basic-test-base'

describe "wd-sync", -> 
  describe "local", ->
    for browserName in ['firefox']
      testWithBrowser 
        type: 'remote' 
        desired:
          browserName:browserName
             
    testCurrent    
      type: 'remote' 
      desired:
        browserName:'chrome'
  
