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
         