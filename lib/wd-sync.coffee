Fiber = require 'fibers'
wd = require 'wd'
_ = require "lodash"

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
wrapAsync = (target) ->
  res = {}
  for k,v of target when (typeof v) is 'function'
    do ->
      _v = v
      res[k] = (args...) ->
        _v.apply target, args
  res

isElement = (obj) ->
  obj?.browser?

wrapSync = (target) ->
  # async wrapping for safety
  target = wrapAsync target

  # making target methods synchronous
  makeSync target, syncOptions
  for k in mixedArgsMethods # methods forced to mixed-args mode
    do ->
      target[k] = makeSync target[k], mode:['mixed', 'args']

  # wrapping methods to make returned elements synchronous
  wrappedTarget = {}
  for k,v of target when (typeof v) is 'function'
    do ->
      _v = v
      wrappedTarget[k] = (args...) ->
        res = _v.apply target, args
        # single element returned
        res = wrapSync res if isElement res
        # array element returned
        if _(res).isArray()
          res = _.map res, (val) ->
            if isElement val then wrapSync val else val
        res
  wrappedTarget

patch = (browser) ->
  browser = wrapSync browser
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
          try
            current().wd_sync_browser = globalOptions?.with?()
            cb.apply globalOptions?.with?(), []
            done?()
          catch e
            done?(e)

module.exports = wdSync
