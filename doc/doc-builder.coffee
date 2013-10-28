#!/usr/bin/env node

fs = require "fs"
async = require "async"
whiskers = require 'whiskers'

rootDir = "#{__dirname}/.."
wdDir = "#{__dirname}/../node_modules/wd"

mappingFiles =
  'supported': 'jsonwire-mapping.md'
  'full': 'jsonwire-full-mapping.md'

# remove local import in examples
fixRequire = (s) ->
  s = s.replace /\wdSync.*\ntry.*\n.*\ncatch.*\n.*\n/m, "wdSync = require 'wd-sync'\n"
  s = s.replace /var.*wdSync;.*\ntry.*\n.*\n.*catch.*\n.*\n\}.*\n/ , \
    "var wdSync = require('wd-sync');\n"
  s

# buid the dynamic doc files
buildDoc = ->
  ctx = {}
  # retrieving coffee example code
  for filename in fs.readdirSync(rootDir + '/examples/coffee') \
    when filename.match /\.coffee/
      key = filename.replace(/\-/g,'').replace('.','')
      ctx[key] = fixRequire ( fs.readFileSync(rootDir + "/examples/coffee/#{filename}", 'utf8') )
  # retrieving js example code
  for filename in fs.readdirSync(rootDir + '/examples/js') \
    when filename.match /\.js/
      key = filename.replace(/\-/g,'').replace('.','')
      ctx[key] = fixRequire ( fs.readFileSync(rootDir + "/examples/js/#{filename}", 'utf8') )
  # README
  template = fs.readFileSync(rootDir + '/doc/template/README-template.md', 'utf8')
  fs.writeFile \
    "./README.md"
    , (whiskers.render template, ctx)
    , (err) -> console.log err if err
  template = fs.readFileSync(rootDir + '/doc/template/COFFEE-DOC-template.md', 'utf8')
  # COFFEE DOC
  fs.writeFile \
    rootDir + "/doc/COFFEE-DOC.md"
    , (whiskers.render template, ctx)
    , (err) -> console.log err if err
  template = fs.readFileSync(rootDir + '/doc/template/JS-DOC-template.md', 'utf8')
  # JS DOC
  fs.writeFile \
    rootDir + "/doc/JS-DOC.md"
    , (whiskers.render template, ctx)
    , (err) -> console.log err if err

buildMapping = (type , done) ->
  done "Invalid type!" unless type in ['supported','full']
  sourcePath = "#{wdDir}/doc/#{mappingFiles[type]}"
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

if process.argv[2] is 'mapping' and process.argv[3]
  buildMapping process.argv[3], (err) ->
    if(err)
      console.log err
      process.exit 1

if process.argv[2] is 'doc'
  buildDoc()



