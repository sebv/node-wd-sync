# assumes that selenium server is running

wdSync = null
try
  wdSync = require 'wd-sync'
catch err
  wdSync = require '../../index'

# 1/ simple Wd example

{browser, sync} = wdSync.remote()

sync ->
  console.log "server status:", @status()
  @init browserName:'firefox'
  console.log "session id:", @getSessionId()
  console.log "session capabilities:", @sessionCapabilities()

  @get "http://google.com"
  console.log @title()

  queryField = @elementByName 'q'
  @type queryField, "Hello World"
  @type queryField, "\n"

  @setWaitTimeout 3000
  @elementByCss '#ires' # waiting for new page to load
  console.log @title()

  console.log @elementByNameIfExists 'not_exists' # undefined

  @quit()
