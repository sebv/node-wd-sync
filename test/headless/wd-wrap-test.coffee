{passingBrowser, withoutPassingBrowser} = require '../common/wd-wrap-test-base'

describe "wd-sync", ->
  describe "headless", ->
  
    passingBrowser 
      type: 'headless' 
  
    withoutPassingBrowser  
      type: 'headless'
