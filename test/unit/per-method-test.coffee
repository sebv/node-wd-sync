{test,Express} = require '../common/per-method-test-base'
  
describe "wd-sync", ->
  describe "unit", ->
    express = new Express
    before (done) ->
      express.start(done)
      done(null)
    
    after (done) ->
      express.stop(done)
      done(null)
    
    test 'remote', 'chrome'

    test 'remote', 'firefox'
