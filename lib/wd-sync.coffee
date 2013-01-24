wd = require("wd")

{makeSync,sync,current} = require 'make-sync'
{EventEmitter} = require 'events'

# we force mixed mode on executeAsync, cause sort of make sense
# to use it this way.
mixedArgsMethods = [
  'executeAsync'  
  , 'safeExecuteAsync'  
]

# EventEmitter methods are excluded
eventEmitterMethods = \
  (k for k,v of EventEmitter.prototype when typeof v is 'function')

syncOptions =  
    mode: 'sync'
    include: '*'
    exclude: mixedArgsMethods.concat eventEmitterMethods.concat [/^_/,'toString']

# async wrapper used to hide implementation, avoiding 
# async interface calling itself 
wrapAsyncObject = (obj) ->
  res = {}
  for k,v of obj when (typeof v) is 'function'
    do ->
      _v = v
      res[k] = (args...) ->        
        _v.apply obj, args
  res

wrapSyncObject = (obj) ->
  res = {}
  for k,v of obj when (typeof v) is 'function'
    do ->
      _v = v
      res[k] = (args...) ->        
        _res = _v.apply obj, args        
        if _res?.browser?
          # element returned   
          makeSync _res, syncOptions
        _res
  res

patch = (browser) ->  
  browser = wrapAsyncObject browser

  # making methods synchronous
  makeSync browser, syncOptions
  for k in mixedArgsMethods # methods forced to mixed-args mode 
    do ->
      browser[k] = makeSync browser[k], mode:['mixed', 'args']
  browser = wrapSyncObject browser 
  # starts sync block.
  _sync = (cb) ->
    if cb?
      sync ->
        current().wd_sync_browser = browser
        cb.apply browser, []
  {
    browser: browser
    sync: _sync
  }
          
wdSync = 
  SPECIAL_KEYS: wd.SPECIAL_KEYS
  # similar to wd
  remote: (args...) ->
    browser = wd.remote args...
    patch browser

  # return headless zombie
  headless: (args...) ->
    wdZombie = require("wd-zombie")
    browser = wdZombie.remote args...
    patch browser
        
  # retrieve the browser currently in use
  # useful when writting helpers  
  current: -> current().wd_sync_browser

  sleep: (ms) ->
    fiber = current()
    setTimeout ->
      fiber.run()
    , ms
    Fiber.yield()

  # wrapper around Wd. 
  # a function returning the browser is passed in the 'with' option.
  wrap: (globalOptions) ->
    (options,cb) ->
      [options,cb] = [null,options] if typeof options is 'function' 
      (done) ->
        globalOptions.pre.apply @, [] if globalOptions?.pre?
        options.pre.apply @, [] if options?.pre?
        sync ->
          current().wd_sync_browser = globalOptions?.with?()
          cb.apply globalOptions?.with?(), [] 
          done() if done?

module.exports = wdSync
