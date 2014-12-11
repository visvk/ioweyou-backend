express = require 'express'
config = require './config'
expressValidator = require 'express-validator'
mailer = require 'express-mailer'
bodyParser = require 'body-parser'
morgan = require 'morgan'
validator = require './lib/validator'
logger = require './lib/logger'

app = exports.app = express()
app.set('title', 'I Owe YOU!')
app.set('views', __dirname + '/views')
app.set('view engine', 'jade')

app.use morgan('dev', { "stream": logger.stream })
app.use bodyParser.json()
app.use expressValidator({
  errorFormatter: validator.errorFormatter
})
mailer.extend app, config.mailer

#Controllers
require('./api/debt')(app)
require('./api/debtType')(app)
require('./api/auth')(app)
require('./api/user')(app)
require('./api/friend')(app)

#if config.apn.env in ["prod", "dev"]
#  apn = require('./lib/apn').apn
#
#  #Events
#  require('./event/applePushNotificationsSubscriber')()