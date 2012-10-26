# a dependency to 'wd-zombie' must be configured in package.json  

wdSync = null
try 
  wdSync = require 'wd-sync' 
catch err
  wdSync = require '../../index' 
  
# 3/ headless Wd example 

{browser, sync} = wdSync.headless()

sync ->        
  @init browserName:'firefox'

  @get "http://saucelabs.com/test/guinea-pig"
  console.log @title()          

  divEl = @elementByCss '#i_am_an_id'
  console.log @text divEl

  textField = @elementByName 'i_am_a_textbox'
  @type textField , "Hello World"  
  @type textField , wdSync.SPECIAL_KEYS.Return

  @quit()  
