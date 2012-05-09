# assumes that selenium server is running

{wd,Wd}={}
try 
  {wd,Wd} = require 'wd-sync' 
catch err
  {wd,Wd} = require '../../index' 
  
# 6/ retrieving the current browser

browser = wd.remote(mode:'sync')

myOwnGetTitle = ->    
  wd.current().title()

Wd with:browser, ->        
  @init browserName:'firefox'

  @get "http://google.com"
  console.log myOwnGetTitle()          

  @quit()
