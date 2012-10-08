fs = require "fs"
async = require "async"

sourceDir = "#{__dirname}/../node_modules/wd/doc"

mappingFiles =
  'supported': 'jsonwire-mapping.md'
  'full': 'jsonwire-full-mapping.md'

module.exports = (type , done) ->
  done "Invalid type!" unless type in ['supported','full'] 
  sourcePath = "#{sourceDir}/#{mappingFiles[type]}"
  orig = null
  async.series [
    (done) ->
      fs.readFile sourcePath, (err, data) ->         
        orig = data.toString() unless err
        done err
    (done) ->
      hasErrors = false
      async.forEachSeries orig.split('\n'), (line, done) ->    
        m = line.match /(\w+)\((.*)\)\s*-&gt;\s*cb\((.*)\)/
        if m?
          # parsing line
          asyncCall = m[0]
          funcName = m[1]
          asyncParams = m[2]
          doneParams = m[3]
          # parsing params
          m = asyncParams.match /(.*),\s*cb/
          syncParams = ""
          syncParams = m[1] if m?
          # parsing return
          m = doneParams.match /err\s*,\s*(.*)/
          if m?
            returnObj = m[1]                      
            syncCall = "#{funcName}(#{syncParams}) -&gt; #{returnObj}"
          else
            syncCall = "#{funcName}(#{syncParams})"
          line = line.replace asyncCall, syncCall  
        else
          # checking for mistakes
          if line.match /gt;/
            hasErrors = true
            console.log  "!!!! #{line}"         
        console.log line
        done null
      , (err) ->
        console.log "!!! NOT CLEAN" if hasErrors
  ], done
