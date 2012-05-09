fs = require 'fs'
whiskers = require 'whiskers'

DEV_DIRS = ['lib','test']
COFFEE_PATHS = DEV_DIRS.concat ['index.coffee']
JS_PATHS = DEV_DIRS.concat ['index.js']
TEST_ENV = ['test/sync-test.coffee']

u = require 'sv-cake-utils'

task 'compile', 'Compile All coffee files', ->
  u.coffee.compile COFFEE_PATHS

task 'compile:watch', 'Compile All coffee files and watch for changes', ->
  u.coffee.compile COFFEE_PATHS, true

task 'clean', 'Remove all js files', ->
  u.js.clean JS_PATHS 

task 'test', 'Run All tests', ->
  u.mocha.test 'test/unit'

task 'test:sauce', 'Run Sauce Labs integration test', ->
  u.mocha.test 'test/sauce'

task 'grep:dirty', 'Lookup for debugger and console.log in code', ->
  u.grep.debug()
  u.grep.log()

# remove local import in examples
fixRequire = (s) ->
  s = s.replace /\{wd.*\ntry.*\n.*\ncatch.*\n.*\n/m, "{wd,Wd} = require 'wd-sync'\n"
  s.replace /var.*\ntry.*\n.*\n.*\n.*catch.*\n.*\n.*\n\}.*\n/ , \
    "var wd = require('wd-sync').wd\n, Wd = require('wd-sync').Wd;\n" 
    
# buid the dynamic doc files
task 'doc:build', ->
  ctx = {}
  
  for filename in fs.readdirSync('./examples/coffee') \
    when filename.match /\.coffee/
      key = filename.replace(/\-/g,'').replace('.','')
      ctx[key] = fixRequire ( fs.readFileSync("./examples/coffee/#{filename}", 'utf8') )      
  
  for filename in fs.readdirSync('./examples/js') \
    when filename.match /\.js/
      key = filename.replace(/\-/g,'').replace('.','')
      ctx[key] = fixRequire ( fs.readFileSync("./examples/js/#{filename}", 'utf8') )      
  
  template = fs.readFileSync('./doc/template/README-template.md', 'utf8')
  fs.writeFile \
    "./README.md" 
    , (whiskers.render template, ctx) 
    , (err) -> console.log err if err
