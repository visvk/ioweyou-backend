express = require 'express'
config = require './config'
expressValidator = require 'express-validator'
mailer = require 'express-mailer'
apn = require './lib/apn'


app = exports.app = express()
app.set('title', 'I Owe YOU!')
app.set('views', __dirname + '/views')
app.set('view engine', 'jade')

app.use express.bodyParser()
app.use expressValidator()
app.use '/public/', express.static(__dirname + '/public')

mailer.extend app, config.mailer
apn.extend app, config.apn

require('./api/entry')(app)
require('./api/auth')(app)
require('./api/user')(app)
require('./api/userClient')(app)

app.get '/', (req, res)->
  res.sendfile './public/index.html'