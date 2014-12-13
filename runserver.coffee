app = require('./app').app
http = require 'http'
logger = require './lib/logger'

http.globalAgent.maxSockets = process.env.maxSockets or 50

app.listen (process.env.PORT or 3000), (error, result) ->
  if error
    logger.info error
  else
    logger.info "Listening."