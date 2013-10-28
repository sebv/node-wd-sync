# wd-sync

A synchronous version with a nice api of [wd](http://github.com/admc/wd), 
the lightweight  [WebDriver / Selenium2](http://seleniumhq.org/projects/webdriver/) 
client for node.js, built using  [node-fibers](http://github.com/laverdet/node-fibers).

Remote testing with [Sauce Labs](http://saucelabs.com) also works.

Note: headless zombie was removed in 1.1.0

## status

[![Build Status](https://travis-ci.org/sebv/node-wd-sync.png)](https://travis-ci.org/sebv/node-wd-sync)
[![Selenium Test Status](https://saucelabs.com/buildstatus/node_wd_sync)](https://saucelabs.com/u/node_wd_sync)

[![Selenium Test Status](https://saucelabs.com/browser-matrix/node_wd_sync.svg)](https://saucelabs.com/u/node_wd_sync)

## install

```
npm install wd-sync
```

## code samples

### CoffeeScript

```coffeescript
{1wdsimplecoffee}
```        

### JavaScript

```javascript
{1wdsimplejs}
``` 

## doc 

* [CoffeeScript](http://github.com/sebv/node-wd-sync/blob/master/doc/COFFEE-DOC.md)
* [JavaScript](http://github.com/sebv/node-wd-sync/blob/master/doc/JS-DOC.md)
* [wd doc](https://github.com/admc/wd/blob/master/README.md)
* [JsonWireProtocol official doc](http://code.google.com/p/selenium/wiki/JsonWireProtocol)

Note: Doc and README modifications must be done in the doc/template directory.

## examples

* [CoffeeScript](http://github.com/sebv/node-wd-sync/tree/master/examples/coffee)
* [JavaScript](http://github.com/sebv/node-wd-sync/tree/master/examples/js)

## api

[supported](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwire-mapping.md)

[full JsonWireProtocol mapping](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwire-full-mapping.md)
  
## available environments

### WebDriver 

local [WebDriver / Selenium2](http://seleniumhq.org/projects/webdriver/) server

### Sauce Labs

Remote testing with [Sauce Labs](http://saucelabs.com).

## running tests

### local / selenium server: 

1/ Install and start Selenium server

```
./node_modules/.bin/install_selenium
./node_modules/.bin/install_chromedriver
./node_modules/.bin/start_selenium_with_chromedriver
```

2/ run tests
```
make test 
```

### remote / Sauce Labs 

1/ configure sauce environment
```
export SAUCE_USERNAME=<SAUCE_USERNAME>
export SAUCE_ACCESS_KEY=<SAUCE_ACCESS_KEY>
# if using sauce connect
./node_modules/.bin/install_sauce_connect
./node_modules/.bin/start_sauce_connect
```

2/ run tests
```
make test_e2e_sauce
make test_midway_sauce_connect
```

## building doc/mapping

### README + doc

1/ Update the templates

2/ run `make build_doc`

### mappings

1/ Upgrade wd

2/ run `make build_mapping`

## publishing

```
npm version [patch|minor|major]
git push --tags
npm publish
```

