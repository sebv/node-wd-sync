{browse, passingBrowser, withoutPassingBrowser} = require '../common/wd-wrap-test-base'

describe "passing browser", ->  
  passingBrowser 'headless'

describe "without passing browser", ->    
  withoutPassingBrowser 'headless'
