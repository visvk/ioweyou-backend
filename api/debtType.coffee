config = require '../config'
auth = require '../lib/auth'
debtTypeTable = require '../models/user'

module.exports = (app) ->
  app.get '/types', auth.tokenAuth, list


list = (req, res) ->

  debtTypeTable.getAll (error, types) ->
    res.header "Content-Type", "application/json"
    if error
      res.status(500).send {error: 'Internal Server Error.'}
    else
      res.send types