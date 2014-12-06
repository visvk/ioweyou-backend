winston = require 'winston'
config = require '../config'

winston.emitErrs = true
logger = new winston.Logger(
  transports: [
    new winston.transports.File(
      level: config.logger.console_log_level
      filename: "./logs/all-logs.log"
      handleExceptions: true
      json: true
      maxsize: 5242880 #5MB
      maxFiles: 5
      colorize: false
    )
    new winston.transports.Console(
      level: "debug"
      handleExceptions: true
      json: false
      colorize: true
    )
  ]
  exitOnError: false
)

module.exports = logger
module.exports.stream = write: (message, encoding) ->
  logger.info message