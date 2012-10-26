# assumes that selenium server is running

wdSync = null
try
  wdSync = require 'wd-sync'
catch err
  wdSync = require '../../index'
  
# 5/ retrieving the current browser

  {browser, sync} = wdSync.remote()

myOwnGetTitle = ->
  wdSync.current().title()

sync ->
  @init browserName:'firefox'

  @get "http://google.com"
  console.log myOwnGetTitle()

  @quit()
