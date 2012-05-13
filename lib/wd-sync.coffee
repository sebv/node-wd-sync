wd = require("wd")
{MakeSync,Sync} = require 'make-sync'
{EventEmitter} = require 'events'

# we force mixed mode on executeAsync, cause sort of make sense
# to use it this way.
mixedArgsMethods = [
  'executeAsync'  
]

# EventEmitter methods are excluded
eventEmitterMethods = \
  (k for k,v of EventEmitter.prototype when typeof v is 'function')

buildOptions = (mode) ->  
  
  mode = 'sync' if not mode?
  {
    mode: mode
    include: '*'
    exclude: mixedArgsMethods.concat eventEmitterMethods.concat [/^_/]
  }
  
patch = (browser, mode) ->  
  # making methods synchronous
  options = buildOptions( mode )
  MakeSync browser, options
  for k in mixedArgsMethods # methods forced to mixed-args mode 
    do ->
      browser[k] = MakeSync browser[k], mode:['mixed', 'args']
        
wdSync = 
  SPECIAL_KEYS: wd.SPECIAL_KEYS
  # similar to wd
  remote: (args...) ->   
    # extracting mode from args 
    mode = 'sync'
    browser = wd.remote(args...)
    for arg in args      
      mode = arg.mode if arg.mode?      
    patch browser, mode 
    return browser
        
  # retrieve the browser currently in use
  # useful when writting helpers  
  current: -> Fiber.current.wd_sync_browser

# starts sync block.
# the browser is passed in the 'with' option.
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

# wrapper around Wd. 
# a function returning the browser is passed in the 'with' option.
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
