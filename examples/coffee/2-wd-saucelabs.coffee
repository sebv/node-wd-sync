# configure saucelabs username/access key here
username = '<USERNAME>'
accessKey = '<ACCESS KEY>'

wdSync = null
try 
  wdSync = require 'wd-sync' 
catch err
  wdSync = require '../../index' 

# 2/ wd saucelabs example 

desired =
  platform: "LINUX"
  name: "wd-sync demo"
  browserName: "firefox"

{browser, sync} = wdSync.remote \
  "ondemand.saucelabs.com",
  80,
  username,
  accessKey

sync ->
  console.log "server status:", @status()          
  @init(desired)
  console.log "session capabilities:", @sessionCapabilities()

  @get "http://google.com"
  console.log @title()          

  queryField = @elementByName 'q'
  @type queryField, "Hello World"  
  @type queryField, "\n"

  @setWaitTimeout 3000      
  @elementByCss '#ires' # waiting for new page to load
  console.log @title()          

  @quit()
