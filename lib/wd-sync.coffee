wd = require("wd")
{MakeSync,Sync} = require 'make-sync'


# We force mixed mode on those, because either they are executed internally
# in async mode or it makes sense to call them asynchronously 
mixedArgsMethods = [
  'executeAsync'  
  , 'element' 
  , 'getAttribute'  
  , 'text'  
]

buildOptions = (mode) ->  
  mode = 'sync' if not mode?
  {
    mode: mode
    include: '*'
    exclude: mixedArgsMethods.concat [
      'getOpts'
      , 'defaultElement'      
    ]   
  }
  
patch = (browser, mode) ->
  # modifying element so that it just returns undefined
  # when the element searched is not found  
  _element = browser.element
  browser.element = (args...,done) ->
    cb = (err,res...) ->
      if err?.status is 7
        # not found
        done null, undefined        
      else
        done err,res...
    args.push cb
    _element.apply @, args

  # fixing moveTo it can be called with only one argument 
  _moveTo = browser.moveTo
  browser.moveTo = (args..., done) ->
    args.push undefined while args.length < 3
    args.push done
    _moveTo.apply @, args
    
  # fixing click and doubleclick so it can be called without 
  for m in ['click','doubleclick']
    do ->
      _m = browser[m]
      browser[m] = (args..., done) ->
        args.push 0 if args.length is 0 # default to left button
        args.push done
        _m.apply @, args
       
  # making methods synchronous
  options = buildOptions( mode )
  MakeSync browser, options
   
  # element and getAttribute may be called internally or externally
  # , so better stick to this mode
  for k in mixedArgsMethods 
    do ->
      browser[k] = MakeSync browser[k], mode:['mixed', 'args']
        
wdSync = 
  # similar to wd
  remote: (args...) ->
    
    # extracting mode from args
    mode = 'sync'
    args = args.filter (arg) ->
      if arg.mode?
        mode = arg.mode
        false
      else true
    
    browser = wd.remote(args...)
    patch browser, mode 
    return browser
    
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
