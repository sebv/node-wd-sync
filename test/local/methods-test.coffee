{test,Express} = require '../common/methods-test-base'
  
describe "wd-sync", ->
  describe "local", ->
    express = new Express
    before (done) ->
      express.start(done)
      done(null)
    
    after (done) ->
      express.stop(done)
      done(null)
    
    test 'remote', 'firefox'
