# wd-sync

NOTE: API change in 1.0.0, see section below.

A synchronous version with a nice api of [wd](http://github.com/admc/wd), 
the lightweight  [WebDriver / Selenium2](http://seleniumhq.org/projects/webdriver/) 
client for node.js, built using  [node-fibers](http://github.com/laverdet/node-fibers).

Remote testing with [Sauce Labs](http://saucelabs.com) also works.

## install

```
npm install wd-sync
```

## upgrade to V1

The main changes are the folowing:

### CoffeeScript

- 1/ require: `wdSync = require 'wd-sync'`
- 2/ `Wd` becomes `sync`
- 3/ `WdWrap` becomes `wrap`
- 4/ to retrieve browser + sync: `{browser, sync} = wdSync.remote()`
- 5/ to create a `wrap`: `wrap = wdSync.wrap ...`  

### JavaScript

- 1/ require: `var wdSync = require('wd-sync');`
- 2/ `Wd` becomes `sync`
- 3/ `WdWrap` becomes `wrap`
- 4/ to retrieve browser + sync: `var client = wdSync.remote(), browser=
client.browser, sync = client.sync;`
- 5/ to create a `wrap`: `var wrap = wdSync.wrap(...`  

## code samples

### CoffeeScript

```coffeescript
# assumes that selenium server is running

wdSync = require 'wd-sync'
  
# 1/ simple Wd example 

{browser, sync} = wdSync.remote()

sync ->        
  console.log "server status:", @status()
  @init browserName:'firefox'
  console.log "session capabilities:", @sessionCapabilities()

  @get "http://google.com"
  console.log @title()          

  queryField = @elementByName 'q'
  @type queryField, "Hello World"  
  @type queryField, "\n"

  @setWaitTimeout 3000      
  @elementByCss '#ires' # waiting for new page to load
  console.log @title()

  console.log @elementByNameIfExists 'not_exists' # undefined

  @quit()  

```        

### JavaScript

```javascript
// assumes that selenium server is running

var wdSync = require('wd-sync');

// 1/ simple Wd example 

var client = wdSync.remote()
    , browser = client.browser
    , sync = client.sync;

sync( function() {
  
  console.log("server status:", browser.status());
  browser.init( { browserName: 'firefox'} );
  console.log("session capabilities:", browser.sessionCapabilities());
  
  browser.get("http://google.com");
  console.log(browser.title());
  
  var queryField = browser.elementByName('q');
  browser.type(queryField, "Hello World");
  browser.type(queryField, "\n");
  
  browser.setWaitTimeout(3000);
  browser.elementByCss('#ires'); // waiting for new page to load
  console.log(browser.title());
  
  console.log(browser.elementByNameIfExists('not_exists')); // undefined
  
  browser.quit();

});

``` 

## doc 

* [CoffeeScript](http://github.com/sebv/node-wd-sync/blob/master/doc/COFFEE-DOC.md)
* [JavaScript](http://github.com/sebv/node-wd-sync/blob/master/doc/JS-DOC.md)

Doc and README modifications must be done in the doc/template directory, then run 'cake doc:build'.

## examples

* [CoffeeScript](http://github.com/sebv/node-wd-sync/tree/master/examples/coffee)
* [JavaScript](http://github.com/sebv/node-wd-sync/tree/master/examples/js)


## supported methods

<table class="wikitable">
  <tbody>
    <tr>
      <td width="50%" style="border: 1px solid #ccc; padding: 5px;">
        <strong>JsonWireProtocol</strong>
      </td>
      <td width="50%" style="border: 1px solid #ccc; padding: 5px;">
        <strong>wd</strong>
      </td>
    </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            GET <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#GET_/status">/status</a><br>
            Query the server's current status.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              status() -&gt; status<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session">/session</a><br>
            Create a new session.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              init(desired) -&gt; sessionID<br>
            
              Initialize the browser.<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            GET <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#GET_/sessions">/sessions</a><br>
            Returns a list of the currently active sessions.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
          
            <p>
              
                sessions() -&gt; sessions<br>
              
            </p>
          
            <p>
              
                Alternate strategy to get session capabilities from server session list: <br>
              
                altSessionCapabilities() -&gt; capabilities<br>
              
            </p>
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            GET <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#GET_/session/:sessionId">/session/:sessionId</a><br>
            Retrieve the capabilities of the specified session.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              sessionCapabilities() -&gt; capabilities<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            DELETE <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#DELETE_/session/:sessionId">/session/:sessionId</a><br>
            Delete the session.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              quit()<br>
            
              Destroy the browser.<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/timeouts">/session/:sessionId/timeouts</a><br>
            Configure the amount of time that a particular type of operation can execute for before they are aborted and a |Timeout| error is returned to the client.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              setPageLoadTimeout(ms)<br>
            
              (use setImplicitWaitTimeout and setAsyncScriptTimeout to set the other timeouts)<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/timeouts/async_script">/session/:sessionId/timeouts/async_script</a><br>
            Set the amount of time, in milliseconds, that asynchronous scripts executed by /session/:sessionId/execute_async are permitted to run before they are aborted and a |Timeout| error is returned to the client.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              setAsyncScriptTimeout(ms)<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/timeouts/implicit_wait">/session/:sessionId/timeouts/implicit_wait</a><br>
            Set the amount of time the driver should wait when searching for elements.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              setImplicitWaitTimeout(ms)<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            GET <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#GET_/session/:sessionId/window_handle">/session/:sessionId/window_handle</a><br>
            Retrieve the current window handle.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              windowHandle() -&gt; handle<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            GET <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#GET_/session/:sessionId/window_handles">/session/:sessionId/window_handles</a><br>
            Retrieve the list of all window handles available to the session.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              windowHandles() -&gt; arrayOfHandles<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            GET <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#GET_/session/:sessionId/url">/session/:sessionId/url</a><br>
            Retrieve the URL of the current page.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              url() -&gt; url<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/url">/session/:sessionId/url</a><br>
            Navigate to a new URL.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              get(url)<br>
            
              Get a new url.<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/forward">/session/:sessionId/forward</a><br>
            Navigate forwards in the browser history, if possible.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              forward()<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/back">/session/:sessionId/back</a><br>
            Navigate backwards in the browser history, if possible.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              back()<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/refresh">/session/:sessionId/refresh</a><br>
            Refresh the current page.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              refresh()<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/execute">/session/:sessionId/execute</a><br>
            Inject a snippet of JavaScript into the page for execution in the context of the currently selected frame.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
          
            <p>
              
                execute(code, args) -&gt; result<br>
              
                execute(code) -&gt; result<br>
              
                args: script argument array (optional)<br>
              
                 <br>
              
            </p>
          
            <p>
              
                Execute script using eval(code): <br>
              
                safeExecute(code, args) -&gt; result<br>
              
                safeExecute(code) -&gt; result<br>
              
                args: script argument array (optional)<br>
              
                 <br>
              
            </p>
          
            <p>
              
                Evaluate expression (using execute): <br>
              
                eval(code) -&gt; value<br>
              
            </p>
          
            <p>
              
                Evaluate expression (using safeExecute): <br>
              
                safeEval(code) -&gt; value<br>
              
            </p>
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/execute_async">/session/:sessionId/execute_async</a><br>
            Inject a snippet of JavaScript into the page for execution in the context of the currently selected frame.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
          
            <p>
              
                executeAsync(code, args) -&gt; result<br>
              
                executeAsync(code) -&gt; result<br>
              
                args: script argument array (optional)<br>
              
                 <br>
              
            </p>
          
            <p>
              
                Execute async script using eval(code): <br>
              
                safeExecuteAsync(code, args) -&gt; result<br>
              
                safeExecuteAsync(code) -&gt; result<br>
              
                args: script argument array (optional)<br>
              
            </p>
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            GET <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#GET_/session/:sessionId/screenshot">/session/:sessionId/screenshot</a><br>
            Take a screenshot of the current page.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              takeScreenshot() -&gt; screenshot<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/frame">/session/:sessionId/frame</a><br>
            Change focus to another frame on the page.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              frame(frameRef)<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/window">/session/:sessionId/window</a><br>
            Change focus to another window.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              window(name)<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            DELETE <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#DELETE_/session/:sessionId/window">/session/:sessionId/window</a><br>
            Close the current window.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              close()<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            GET <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#GET_/session/:sessionId/cookie">/session/:sessionId/cookie</a><br>
            Retrieve all cookies visible to the current page.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              allCookies() -&gt; cookies<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/cookie">/session/:sessionId/cookie</a><br>
            Set a cookie.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              setCookie(cookie)<br>
            
              cookie example:  <br>
            
               {name:'fruit', value:'apple'}<br>
            
              Optional cookie fields: <br>
            
               path, domain, secure, expiry<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            DELETE <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#DELETE_/session/:sessionId/cookie">/session/:sessionId/cookie</a><br>
            Delete all cookies visible to the current page.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              deleteAllCookies()<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            DELETE <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#DELETE_/session/:sessionId/cookie/:name">/session/:sessionId/cookie/:name</a><br>
            Delete the cookie with the given name.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              deleteCookie(name)<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            GET <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#GET_/session/:sessionId/title">/session/:sessionId/title</a><br>
            Get the current page title.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              title() -&gt; title<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/element">/session/:sessionId/element</a><br>
            Search for an element on the page, starting from the document root.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
          
            <p>
              
                element(using, value) -&gt; element<br>
              
            </p>
          
            <p>
              
                elementByClassName(value) -&gt; element<br>
              
                elementByCssSelector(value) -&gt; element<br>
              
                elementById(value) -&gt; element<br>
              
                elementByName(value) -&gt; element<br>
              
                elementByLinkText(value) -&gt; element<br>
              
                elementByPartialLinkText(value) -&gt; element<br>
              
                elementByTagName(value) -&gt; element<br>
              
                elementByXPath(value) -&gt; element<br>
              
                elementByCss(value) -&gt; element<br>
              
            </p>
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/elements">/session/:sessionId/elements</a><br>
            Search for multiple elements on the page, starting from the document root.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
          
            <p>
              
                elements(using, value) -&gt; elements<br>
              
            </p>
          
            <p>
              
                elementsByClassName(value) -&gt; elements      <br>
              
                elementsByCssSelector(value) -&gt; elements      <br>
              
                elementsById(value) -&gt; elements      <br>
              
                elementsByName(value) -&gt; elements      <br>
              
                elementsByLinkText(value) -&gt; elements      <br>
              
                elementsByPartialLinkText(value) -&gt; elements      <br>
              
                elementsByTagName(value) -&gt; elements      <br>
              
                elementsByXPath(value) -&gt; elements      <br>
              
                elementsByCss(value) -&gt; elements      <br>
              
            </p>
          
            <p>
              
                Retrieve an element avoiding not found exception and returning null instead: <br>
              
                elementOrNull(using, value) -&gt; element<br>
              
            </p>
          
            <p>
              
                elementByClassNameOrNull(value) -&gt; element<br>
              
                elementByCssSelectorOrNull(value) -&gt; element<br>
              
                elementByIdOrNull(value) -&gt; element<br>
              
                elementByNameOrNull(value) -&gt; element<br>
              
                elementByLinkTextOrNull(value) -&gt; element<br>
              
                elementByPartialLinkTextOrNull(value) -&gt; element<br>
              
                elementByTagNameOrNull(value) -&gt; element<br>
              
                elementByXPathOrNull(value) -&gt; element<br>
              
                elementByCssOrNull(value) -&gt; element<br>
              
            </p>
          
            <p>
              
                Retrieve an element avoiding not found exception and returning undefined instead: <br>
              
                elementIfExists(using, value) -&gt; element<br>
              
            </p>
          
            <p>
              
                elementByClassNameIfExists(value) -&gt; element<br>
              
                elementByCssSelectorIfExists(value) -&gt; element<br>
              
                elementByIdIfExists(value) -&gt; element<br>
              
                elementByNameIfExists(value) -&gt; element<br>
              
                elementByLinkTextIfExists(value) -&gt; element<br>
              
                elementByPartialLinkTextIfExists(value) -&gt; element<br>
              
                elementByTagNameIfExists(value) -&gt; element<br>
              
                elementByXPathIfExists(value) -&gt; element<br>
              
                elementByCssIfExists(value) -&gt; element<br>
              
            </p>
          
            <p>
              
                Check if element exists: <br>
              
                hasElement(using, value) -&gt; boolean<br>
              
            </p>
          
            <p>
              
                hasElementByClassName(value) -&gt; boolean <br>
              
                hasElementByCssSelector(value) -&gt; boolean <br>
              
                hasElementById(value) -&gt; boolean <br>
              
                hasElementByName(value) -&gt; boolean <br>
              
                hasElementByLinkText(value) -&gt; boolean <br>
              
                hasElementByPartialLinkText(value) -&gt; boolean <br>
              
                hasElementByTagName(value) -&gt; boolean <br>
              
                hasElementByXPath(value) -&gt; boolean <br>
              
                hasElementByCss(value) -&gt; boolean <br>
              
            </p>
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/element/active">/session/:sessionId/element/active</a><br>
            Get the element on the page that currently has focus.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              active() -&gt; element<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/element/:id/click">/session/:sessionId/element/:id/click</a><br>
            Click on an element.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
          
            <p>
              
                clickElement(element)<br>
              
            </p>
          
            <p>
              
                element.click()<br>
              
            </p>
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            GET <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#GET_/session/:sessionId/element/:id/text">/session/:sessionId/element/:id/text</a><br>
            Returns the visible text for the element.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
          
            <p>
              
                text(element) -&gt; text<br>
              
                element: specific element, 'body', or undefined<br>
              
            </p>
          
            <p>
              
                element.text() -&gt; text<br>
              
            </p>
          
            <p>
              
                Check if text is present: <br>
              
                textPresent(searchText, element) -&gt; boolean<br>
              
                element: specific element, 'body', or undefined<br>
              
                 <br>
              
            </p>
          
            <p>
              
                element.textPresent(searchText) -&gt; boolean<br>
              
                 <br>
              
            </p>
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/element/:id/value">/session/:sessionId/element/:id/value</a><br>
            Send a sequence of key strokes to an element.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
          
            <p>
              
                type(element, keys)<br>
              
                Type keys (all keys are up at the end of command).<br>
              
                special key map: wd.SPECIAL_KEYS (see lib/special-keys.js)<br>
              
            </p>
          
            <p>
              
                element.type(keys)<br>
              
            </p>
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/keys">/session/:sessionId/keys</a><br>
            Send a sequence of key strokes to the active element.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              keys(keys)<br>
            
              Press keys (keys may still be down at the end of command).<br>
            
              special key map: wd.SPECIAL_KEYS (see lib/special-keys.js)<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            GET <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#GET_/session/:sessionId/element/:id/name">/session/:sessionId/element/:id/name</a><br>
            Query for an element's tag name.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
          
            <p>
              
                getTagName(element) -&gt; name<br>
              
            </p>
          
            <p>
              
                element.getTagName() -&gt; name<br>
              
            </p>
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/element/:id/clear">/session/:sessionId/element/:id/clear</a><br>
            Clear a TEXTAREA or text INPUT element's value.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
          
            <p>
              
                clear(element)<br>
              
            </p>
          
            <p>
              
                element.clear()<br>
              
            </p>
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            GET <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#GET_/session/:sessionId/element/:id/attribute/:name">/session/:sessionId/element/:id/attribute/:name</a><br>
            Get the value of an element's attribute.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
          
            <p>
              
                getAttribute(element, attrName) -&gt; value<br>
              
            </p>
          
            <p>
              
                element.getAttribute(attrName) -&gt; value<br>
              
            </p>
          
            <p>
              
                Get element value (in value attribute): <br>
              
                getValue(element) -&gt; value<br>
              
            </p>
          
            <p>
              
                element.getValue() -&gt; value<br>
              
            </p>
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            GET <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#GET_/session/:sessionId/element/:id/displayed">/session/:sessionId/element/:id/displayed</a><br>
            Determine if an element is currently displayed.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
          
            <p>
              
                isDisplayed(element) -&gt; displayed<br>
              
            </p>
          
            <p>
              
                element.isDisplayed() -&gt; displayed<br>
              
            </p>
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            GET <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#GET_/session/:sessionId/element/:id/css/:propertyName">/session/:sessionId/element/:id/css/:propertyName</a><br>
            Query the value of an element's computed CSS property.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
          
            <p>
              
                getComputedCss(element, cssProperty ) -&gt; value<br>
              
            </p>
          
            <p>
              
                element.getComputedCss(cssProperty ) -&gt; value<br>
              
            </p>
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/accept_alert">/session/:sessionId/accept_alert</a><br>
            Accepts the currently displayed alert dialog.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              acceptAlert()<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/dismiss_alert">/session/:sessionId/dismiss_alert</a><br>
            Dismisses the currently displayed alert dialog.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              dismissAlert()<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/moveto">/session/:sessionId/moveto</a><br>
            Move the mouse by an offset of the specificed element.
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              moveTo(element, xoffset, yoffset)<br>
            
              Move to element, xoffset and y offset are optional.<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/click">/session/:sessionId/click</a><br>
            Click any mouse button (at the coordinates set by the last moveto command).
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              click(button)<br>
            
              Click on current element.<br>
            
              Buttons: {left: 0, middle: 1 , right: 2}<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/buttondown">/session/:sessionId/buttondown</a><br>
            Click and hold the left mouse button (at the coordinates set by the last moveto command).
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              buttonDown()<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/buttonup">/session/:sessionId/buttonup</a><br>
            Releases the mouse button previously held (where the mouse is currently at).
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              buttonUp()<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
            POST <a href="http://code.google.com/p/selenium/wiki/JsonWireProtocol#POST_/session/:sessionId/doubleclick">/session/:sessionId/doubleclick</a><br>
            Double-clicks at the current mouse coordinates (set by moveto).
          
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              doubleclick() <br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            EXTRA
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              Opens a new window (using Javascript window.open):<br>
            
              newWindow(url, name)<br>
            
              newWindow(url)<br>
            
              name: optional window name<br>
            
              Window can later be accessed by name with the window method, <br>
            
              or by getting the last handle returned by the windowHandles method.<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            EXTRA
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              windowName() -&gt; name<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            EXTRA
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              waitForElement(using, value, timeout)<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            EXTRA
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              waitForVisible(using, value, timeout)<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            EXTRA
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              waitForElementByClassName(value, timeout)<br>
            
              waitForElementByCssSelector(value, timeout)<br>
            
              waitForElementById(value, timeout)<br>
            
              waitForElementByName(value, timeout)<br>
            
              waitForElementByLinkText(value, timeout)<br>
            
              waitForElementByPartialLinkText(value, timeout)<br>
            
              waitForElementByTagName(value, timeout)<br>
            
              waitForElementByXPath(value, timeout)<br>
            
              waitForElementByCss(value, timeout)<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            EXTRA
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              waitForVisibleByClassName(value, timeout)<br>
            
              waitForVisibleByCssSelector(value, timeout)<br>
            
              waitForVisibleById(value, timeout)<br>
            
              waitForVisibleByName(value, timeout)<br>
            
              waitForVisibleByLinkText(value, timeout)<br>
            
              waitForVisibleByPartialLinkText(value, timeout)<br>
            
              waitForVisibleByTagName(value, timeout)<br>
            
              waitForVisibleByXPath(value, timeout)<br>
            
              waitForVisibleByCss(value, timeout)<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            EXTRA
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              isVisible(element ) -&gt; boolean<br>
            
              deprecated: isVisible(queryType, querySelector) -&gt; boolean<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            EXTRA
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              Waits for JavaScript condition to be true (polling within wd client): <br>
            
              waitForCondition(conditionExpr, timeout, pollFreq) -&gt; boolean<br>
            
              waitForCondition(conditionExpr, timeout) -&gt; boolean<br>
            
              waitForCondition(conditionExpr) -&gt; boolean<br>
            
              conditionExpr: condition expression, should return a boolean<br>
            
              timeout: timeout (optional, default: 1000) <br>
            
              pollFreq: pooling frequency (optional, default: 100)<br>
            
              return true if condition satisfied, error otherwise.<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            EXTRA
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              Waits for JavaScript condition to be true (async script polling within browser): <br>
            
              waitForConditionInBrowser(conditionExpr, timeout, pollFreq) -&gt; boolean<br>
            
              waitForConditionInBrowser(conditionExpr, timeout) -&gt; boolean<br>
            
              waitForConditionInBrowser(conditionExpr) -&gt; boolean<br>
            
              conditionExpr: condition expression, should return a boolean<br>
            
              timeout: timeout (optional, default: 1000) <br>
            
              pollFreq: pooling frequency (optional, default: 100)<br>
            
              return true if condition satisfied, error otherwise.<br>
            
          
          
        </td>
      </tr>
    
      <tr>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            EXTRA
          
          
        </td>
        <td style="border: 1px solid #ccc; padding: 5px;">
          
          
            
              isVisible() -&gt; boolean<br>
            
          
          
        </td>
      </tr>
      
  </tbody>
</table>

* [supported JsonWireProtocol mapping](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwire-mapping.md)
* [full JsonWireProtocol mapping](http://github.com/sebv/node-wd-sync/blob/master/doc/jsonwire-full-mapping.md)
  
## available environments

### WebDriver 

local [WebDriver / Selenium2](http://seleniumhq.org/projects/webdriver/) server

### Sauce Labs

Remote testing with [Sauce Labs](http://saucelabs.com).

### Headless

Headless testing using [Zombie](http://github.com/assaf/zombie).

notes regarding headless/zombie:
- only worth using for simple pages, not relying heavily on Javacripts.   
- the headless functionality wont be maintained/improved, at least until Zombie 2 is stable. 

## tests

### local / selenium server: 

1/ starts the selenium server with chromedriver:
```  
java -jar selenium-server-standalone-2.21.0.jar -Dwebdriver.chrome.driver=<PATH>/chromedriver
```

2a/ run tests
```
cake test:local 
```

2b/ run clean test (making sure wd-zombie is not installed first)
```
cake test
```

### remote / Sauce Labs 

1/ follow the instructions [here](http://github.com/sebv/node-wd-sync/blob/master/test/sauce/README.md) to
configure your username and access key.
 

2/ run tests
```
cake test:sauce
```

### headless 

once:
```
cake test:headless
```

then:
```
cake test:headless
```

## todo

doc + example for methods returning element instances 

