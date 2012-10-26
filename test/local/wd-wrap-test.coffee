{test} = require '../common/wd-wrap-test-base'

describe "wd-sync", ->
  describe "local", ->
    describe "wrap tests", -> 
      test 
        type: 'remote' 
        desired:
          browserName:'chrome'
