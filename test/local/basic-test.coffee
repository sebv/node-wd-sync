{testWithBrowser,testCurrent,testSleep} = require '../common/basic-test-base'

describe "wd-sync", ->
  describe "local", ->
    for browserName in ['chrome']
      testWithBrowser
        type: 'remote'
        desired:
          browserName:browserName

    testCurrent
      type: 'remote'
      desired:
        browserName:'firefox'

    testSleep
      type: 'remote'
      desired:
        browserName:'firefox'
