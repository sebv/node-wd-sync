{test,Express} = require '../common/per-method-test-base'
  
describe "wd-sync", -> \
describe "method by method tests", ->
  express = new Express
  before (done) ->
    express.start(done)
    done(null)
    
  after (done) ->
    express.stop(done)
    done(null)
    
  describe "using zombie", ->
    test 'headless', 'zombie'
  
