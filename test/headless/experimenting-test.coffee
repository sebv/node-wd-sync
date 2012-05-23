f = () ->
  before (done) ->
    console.log "before"
    done null

  after (done) ->
    console.log "after"
    done null
  
  describe "experiment 1", ->
    it "should work", (done) ->
      done null
  
  describe "experiment 2", ->
    it "should work", (done) ->
      done null

describe "experiment", ->
  


  do f
  
 