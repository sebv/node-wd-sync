# assumes that selenium server is running

{wd,Wd}={}
try 
  {wd,Wd} = require 'wd-sync' 
catch err
  {wd,Wd} = require '../../index' 
  
# 1/ simple Wd example 

browser = wd.remote()

Wd with:browser, ->        
  console.log "server status:", @status()
  @init browserName:'firefox'
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
