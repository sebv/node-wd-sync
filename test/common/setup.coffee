GLOBAL.wdSync = require '../../index'
chai = require 'chai'
GLOBAL.should = chai.should()

_ = require 'lodash'

{jobStatus,jobUpdate} = require './sauce-helper';
[GLOBAL.jobStatus, GLOBAL.jobUpdate] = [jobStatus, jobUpdate]

GLOBAL.env = {}

env.REMOTE_CONFIG = process.env.REMOTE_CONFIG

env.TIMEOUT = process.env.TIMEOUT || 45000
env.BROWSER = process.env.BROWSER || 'chrome'
env.DESIRED = process.env.DESIRED || \
  if env.BROWSER then browserName: env.BROWSER else undefined

env.EXPRESS_PORT = process.env.EXPRESS_PORT || 3000
env.MIDWAY_ROOT_URL = "http://127.0.0.1:" + env.EXPRESS_PORT

GLOBAL.desiredWithTestInfo = (testInfo) ->
  desired = _.clone env.DESIRED
  if env.SAUCE
    desired.name = testInfo.name if testInfo?.name
    if env.TRAVIS_JOB_NUMBER
      desired.name = "[" + env.TRAVIS_JOB_NUMBER + "] " + desired.name
    desired.tags = _.union(desired.tags, testInfo.tags) if testInfo?.tags
  desired['tunnel-identifier'] = env.TRAVIS_JOB_NUMBER if env.TRAVIS_JOB_NUMBER
  desired

env.SAUCE_CONNECT = if process.env.SAUCE_CONNECT then true else false
env.SAUCE = if process.env.SAUCE then true else false
env.SAUCE = env.SAUCE or env.SAUCE_CONNECT

env.TRAVIS_JOB_ID = process.env.TRAVIS_JOB_ID
env.TRAVIS_JOB_NUMBER = process.env.TRAVIS_JOB_NUMBER
env.TRAVIS_BUILD_NUMBER = process.env.TRAVIS_BUILD_NUMBER

if env.TRAVIS_JOB_ID
  env.TRAVIS = true;
  console.log "Travis environment detected."
  console.log "TRAVIS_JOB_ID --> ", env.TRAVIS_JOB_ID
  console.log "TRAVIS_BUILD_NUMBER --> ", env.TRAVIS_BUILD_NUMBER
  console.log "TRAVIS_JOB_NUMBER --> ", env.TRAVIS_JOB_NUMBER

if env.SAUCE
  env.SAUCE_JOB_ID = \
    env.TRAVIS_BUILD_NUMBER ||
    process.env.SAUCE_JOB_ID ||
    Math.round(new Date().getTime() / (1000*60));
  env.SAUCE_USERNAME = process.env.SAUCE_USERNAME
  env.SAUCE_ACCESS_KEY = process.env.SAUCE_ACCESS_KEY
  env.SAUCE_PLATFORM = process.env.SAUCE_PLATFORM
  env.SAUCE_RECORD_VIDEO = process.env.SAUCE_RECORD_VIDEO

  if env.SAUCE_CONNECT
    env.REMOTE_CONFIG =
      'http://' + env.SAUCE_USERNAME + ':' + env.SAUCE_ACCESS_KEY +
        '@localhost:4445/wd/hub'
  else
    env.REMOTE_CONFIG =
      'http://' + env.SAUCE_USERNAME + ':' + env.SAUCE_ACCESS_KEY +
        '@ondemand.saucelabs.com/wd/hub'

  env.DESIRED.platform = env.DESIRED.platform || env.SAUCE_PLATFORM || 'Linux'
  env.DESIRED.build = env.SAUCE_JOB_ID
  env.DESIRED["record-video"] = env.SAUCE_RECORD_VIDEO
  env.DESIRED.tags = env.DESIRED.tags || []
  env.DESIRED.tags.push('wd-sync')
  env.DESIRED.tags.push('travis') if(env.TRAVIS_JOB_NUMBER)
  #special case for explorer
  if BROWSER is 'explorer'
    env.DESIRED.browserName = 'internet explorer'
    env.DESIRED.platform = 'Windows 7'
    env.DESIRED.version = '10'

env.TEST_ENV_DESC = \
  "(" + (if env.SAUCE then 'sauce' else 'local') +  ", browser: " +
  (env.DESIRED.browserName || "default") + ")"


