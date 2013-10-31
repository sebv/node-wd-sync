# assumes that selenium server is running
chai = require 'chai'
should = chai.should()

wdSync = null
try
  wdSync = require 'wd-sync'
catch err
  wdSync = require '../../index'

# 1/ simple Wd example

{browser, sync} = wdSync.remote()

subElementTest = (searchform) ->
  searchform.text().should.include "Comments:"

  # single element method
  textarea = searchform.elementByTagName('textarea')
  textarea.type('Bonjour!');
  textarea.getValue().should.equal('Bonjour!');
  textarea.clear()
  textarea.getValue().should.equal('');

  # multiple element method
  textareas = searchform.elementsByTagName('textarea')
  textareas.should.have.length(1);
  textareas[0].type('Ni Hao!');
  textareas[0].getValue().should.equal('Ni Hao!');
  textareas[0].clear()
  textareas[0].getValue().should.equal('');

sync ->
  console.log "server status:", @status()
  @init browserName:'chrome'
  console.log "session id:", @getSessionId()

  @get "http://saucelabs.com/test/guinea-pig"

  # root element via single element method
  subElementTest( @elementById "jumpContact" )

  # root element via multiple element method
  subElementTest( (@elementsByCss "#jumpContact")[0] )

  @quit()
