wd = require("wd")
{MakeSync,Sync} = require 'make-sync'

buildOptions = (mode) ->
  mode = 'sync' if not mode?
  {
    mode: mode
    include: '*'
    exclude: [
      'getOpts'
      , 'element' #TODO check if not used directly
    ]  
  }
  
wdSync = 
  # similar to wd
  remote: (args...) ->
    # lookink for sync mode
    mode = 'sync'
    args = args.filter (arg) ->
      if arg.mode?
        mode = arg.mode
        false
      else true
    browser = wd.remote(args...)
    options = buildOptions( mode )
    MakeSync browser, options 
    browser
    
  # retrieve the browser currently in use
  # useful when writting helpers  
  current: -> Fiber.current.wd_sync_browser
  
Wd = (options, cb) ->
  [options,cb] = [null,options] if typeof options is 'function' 
  if cb?
    Sync ->
      Fiber.current.wd_sync_browser = options?.with
      cb.apply options?.with, []
  if options
    # returning an identical function with context(browser) preconfigured 
    (options2, cb2) ->
      [options2,cb2] = [null,options2] if typeof options2 is 'function' 
      options2 = options if not options2?
      Wd options2, cb2      

# careful, below browser is a function so it get evaluated with the rest
# of the code  
WdWrap = (options, cb) ->
  [options,cb] = [null,options] if typeof options is 'function' 
  if cb?
    return (done) ->
      options.pre.apply @, [] if options?.pre?
      Sync ->
        Fiber.current.wd_sync_browser = options?.with?()
        cb.apply options?.with?(), []
        done() if done?
  if options
    # returning an identical function with context(browser) preconfigured 
    return (options2, cb2) ->
      [options2,cb2] = [null,options2] if typeof options2 is 'function' 
      options2 = options if not options2?
      WdWrap options2, cb2      

exports.Wd= Wd
exports.WdWrap = WdWrap
exports.wd = wdSync
