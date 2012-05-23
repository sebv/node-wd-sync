{test} = require '../common/typing-test-base'
  
describe "wd-sync", ->
  describe "unit", ->  
    test 'remote', 'chrome'
    test 'remote', 'firefox'