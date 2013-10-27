express = require 'express'

Express = (rootDir) ->
  @rootDir = rootDir
  @partials = {}
  @

Express.prototype.start = ->
  @app = express()
  @app.set 'view engine', 'hbs'
  @app.set 'views', this.rootDir + '/views'

  partials = @partials;
  @app.get '/test-page', (req, res) ->
    content = ''
    if req.query.partial
      content = partials[req.query.partial]
    res.render 'test-page', (
      testTitle: req.query.partial,
      content: content
    )

  @app.use express["static"](this.rootDir + '/public');
  @server = @app.listen(env.EXPRESS_PORT);

Express.prototype.stop = ->
  @server.close()

module.exports =
  Express: Express
