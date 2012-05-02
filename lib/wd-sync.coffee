###
soda = require("soda")
{MakeSync,Sync} = require 'make-sync'

buildOptions = (mode) ->
  mode = 'sync' if not mode?
  {
    mode: mode
    exclude: '*'
    include: soda.commands.concat ['session']
  }

patch = (browser, options) ->
  if(options?.mode?)
    MakeSync browser, (buildOptions options.mode) 
    browser.queue = null  # necessary cause soda is doing weird stuff
  browser                 # in the 'chain' getter 

sodaSync =
  # similar to soda
  createClient: (options) -> 
    patch (soda.createClient options), options
  createSauceClient: (options) -> 
    patch (soda.createSauceClient options), options
    
  # retrieve the browser currently in use
  # useful when writting helpers  
  current: -> Fiber.current.soda_sync_browser
  
Soda = (options, cb) ->
  [options,cb] = [null,options] if typeof options is 'function' 
  if cb?
    Sync ->
      Fiber.current.soda_sync_browser = options?.with
      cb.apply options?.with, []
  if options
    # returning an identical function with context(browser) preconfigured 
    (options2, cb2) ->
      [options2,cb2] = [null,options2] if typeof options2 is 'function' 
      options2 = options if not options2?
      Soda options2, cb2      

# careful, below browser is a function so it get evaluated with the rest
# of the code  
SodaCan = (options, cb) ->
  [options,cb] = [null,options] if typeof options is 'function' 
  if cb?
    return (done) ->
      Sync ->
        Fiber.current.soda_sync_browser = options?.with?()
        cb.apply options?.with?(), []
        done() if done?
  if options
    # returning an identical function with context(browser) preconfigured 
    return (options2, cb2) ->
      [options2,cb2] = [null,options2] if typeof options2 is 'function' 
      options2 = options if not options2?
      SodaCan options2, cb2      

exports.Soda = Soda
exports.SodaCan = SodaCan
exports.soda = sodaSync
