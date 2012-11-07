DEV_DIRS = ['lib','test']
COFFEE_PATHS = DEV_DIRS.concat ['index.coffee']
JS_PATHS = DEV_DIRS.concat ['index.js']
TEST_ENV = ['test/sync-test.coffee']

fs = require 'fs'
whiskers = require 'whiskers'
u = require 'sv-cake-utils'
async = require 'async'

mappingBuilder = require "./doc/mapping-builder"

task 'compile', 'Compile All coffee files', ->
  u.coffee.compile COFFEE_PATHS

task 'compile:watch', 'Compile All coffee files and watch for changes', ->
  u.coffee.compile COFFEE_PATHS, watch:true

task 'clean', 'Remove all js files', ->
  u.js.clean JS_PATHS 

task 'test', 'Run local tests (uninstall zombie first)', ->
  u.exec 'npm uninstall wd-zombie', (err) ->
    if err then process.exit 1
    u.mocha.test 'test/local', (status) ->
      process.exit status unless status is 0

task 'test:local', 'Run local tests', ->
  u.mocha.test 'test/local', (status) ->
    process.exit status unless status is 0

task 'test:sauce', 'Run Sauce Labs integration tests', ->
  u.mocha.test 'test/sauce', (status) ->
    process.exit status unless status is 0

task 'test:prepare:headless', 'install zombie', ->
  u.exec 'npm install wd-zombie@0.0.x'

task 'test:headless', 'Run headless tests', ->
  u.mocha.test 'test/headless', (status) ->
    process.exit status unless status is 0

task 'mapping:build', 'build JsonWire mappings', ->
  async.series [
    (done) -> mappingBuilder 'supported', done
  ]

task 'mapping:full:build', 'build JsonWire mappings', ->
  async.series [
    (done) -> mappingBuilder 'full', done
  ]

task 'grep:dirty', 'Lookup for debugger and console.log in code', ->
  u.grep.debug()
  u.grep.log()

# remove local import in examples
fixRequire = (s) ->
  s = s.replace /\wdSync.*\ntry.*\n.*\ncatch.*\n.*\n/m, "wdSync = require 'wd-sync'\n"
  s = s.replace /var.*wdSync;.*\ntry.*\n.*\n.*catch.*\n.*\n\}.*\n/ , \
    "var wdSync = require('wd-sync');\n" 
  s
    
# buid the dynamic doc files
task 'doc:build', ->
  ctx = {}
  # retrieving coffee example code  
  for filename in fs.readdirSync('./examples/coffee') \
    when filename.match /\.coffee/
      key = filename.replace(/\-/g,'').replace('.','')
      ctx[key] = fixRequire ( fs.readFileSync("./examples/coffee/#{filename}", 'utf8') )        
  # retrieving js example code
  for filename in fs.readdirSync('./examples/js') \
    when filename.match /\.js/
      key = filename.replace(/\-/g,'').replace('.','')
      ctx[key] = fixRequire ( fs.readFileSync("./examples/js/#{filename}", 'utf8') )      
  # README
  template = fs.readFileSync('./doc/template/README-template.md', 'utf8')  
  fs.writeFile \
    "./README.md" 
    , (whiskers.render template, ctx) 
    , (err) -> console.log err if err
  template = fs.readFileSync('./doc/template/COFFEE-DOC-template.md', 'utf8')
  # COFFEE DOC
  fs.writeFile \
    "./doc/COFFEE-DOC.md" 
    , (whiskers.render template, ctx) 
    , (err) -> console.log err if err
  template = fs.readFileSync('./doc/template/JS-DOC-template.md', 'utf8')
  # JS DOC
  fs.writeFile \
    "./doc/JS-DOC.md" 
    , (whiskers.render template, ctx) 
    , (err) -> console.log err if err
