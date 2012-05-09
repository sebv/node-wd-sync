# configure saucelabs username/access key here
username = '<USERNAME>'
accessKey = '<ACCESS KEY>'

{wd,WdWrap}={}
try 
  {wd,WdWrap} = require 'wd-sync' 
catch err
  {wd,WdWrap} = require '../../index' 

# 2/ wd saucelabs example 

desired =
  platform: "LINUX"
  name: "wd-sync demo"
  browserName: "firefox"

browser = wd.remote \
  "ondemand.saucelabs.com",
  80,
  username,
  accessKey,
  mode:'sync'

Wd with:browser, ->
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