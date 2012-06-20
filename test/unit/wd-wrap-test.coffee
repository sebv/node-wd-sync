{passingBrowser, withoutPassingBrowser} = require '../common/wd-wrap-test-base'

describe "wd-sync", ->
  describe "unit", ->
  
    passingBrowser 
      type: 'remote' 
      desired:
        browserName:'chrome'
  
    withoutPassingBrowser  
      type: 'remote'
      desired:
        browserName:'chrome'
