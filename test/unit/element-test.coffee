{test,Express} = require '../common/element-test-base'
  
describe "wd-sync", -> \
describe "element tests", ->
  express = new Express
  before (done) ->
    express.start(done)
    done(null)
    
  after (done) ->
    express.stop(done)
    done(null)
    
  describe "using chrome", ->
    test 'remote', 'chrome'
###  
  describe "using firefox", ->
    test 'remote', 'firefox'
