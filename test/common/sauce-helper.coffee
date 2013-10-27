{makeSync} = require 'make-sync'
request = require 'request'

_jobStatus = (passed, sessionId, done) ->
  return done() unless env.SAUCE
  httpOpts =
    url: 'http://' + env.SAUCE_USERNAME + ':' +
      env.SAUCE_ACCESS_KEY + '@saucelabs.com/rest/v1/' +
      env.SAUCE_USERNAME + '/jobs/' + sessionId,
    method: 'PUT'
    headers: {
      'Content-Type': 'text/json'
    }
    body: JSON.stringify
      passed: passed

    jar: false # disable cookies: avoids CSRF issues
  request httpOpts, (err) ->
    if err then return done err
    if env.VERBOSE
      console.log("> job:", sessionId, "marked as " +
        (passed? "pass" : "fail") + "." );
    done()

jobStatus = makeSync _jobStatus

_jobUpdate = (jsonData, sessionId, done) ->
  return done() unless env.SAUCE
  httpOpts =
    url: 'http://' + env.SAUCE_USERNAME + ':' +
      env.SAUCE_ACCESS_KEY + '@saucelabs.com/rest/v1/' +
      env.SAUCE_USERNAME + '/jobs/' + sessionId,
    method: 'PUT'
    headers: {
      'Content-Type': 'text/json'
    }
    body: jsonData
    jar: false # disable cookies: avoids CSRF issues
  request httpOpts, (err) ->
    if err then return done err
    if env.VERBOSE
      console.log("> job:", sessionId, "marked as " +
        (passed? "pass" : "fail") + "." );
    done()

jobUpdate = makeSync _jobUpdate

module.exports =
  jobStatus: jobStatus
  jobUpdate: jobUpdate

