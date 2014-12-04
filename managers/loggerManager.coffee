winston = require 'winston'
config = require '../config'

module.exports =
  setLogger: () ->
    console.log "blah"
    global.logger = new (winston.Logger)(
      transports: [
        new winston.transports.Console
          level: config.logger.console_log_level
          colorize: true
          timestamp: true
          handleExceptions: true
      ]
    )

