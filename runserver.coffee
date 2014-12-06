app = require('./app').app
config = require './config'
http = require 'http'
logger = require './lib/logger'

http.globalAgent.maxSockets = 50

app.listen config.app.port, (error, result) ->
  if error
    logger.info error
  else
    logger.info "Listening on port #{config.app.port}."