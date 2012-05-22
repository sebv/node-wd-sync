{wd,Wd}={}
try 
  {wd,Wd} = require 'wd-sync' 
catch err
  {wd,Wd} = require '../../index' 
  
# 3/ headless Wd example 

browser = wd.headless()

Wd with:browser, ->        
  @init browserName:'firefox'

  @get "http://saucelabs.com/test/guinea-pig"
  console.log @title()          

  divEl = @elementByCss '#i_am_an_id'
  console.log @text divEl

  textField = @elementByName 'i_am_a_textbox'
  @type textField , "Hello World"  
  @type textField , wd.SPECIAL_KEYS.Return

  @quit()  
