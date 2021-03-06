#config = require '../config'
#auth = require '../lib/auth'
debtTypeTable = require '../models/user'

module.exports = (app) ->
  app.get '/types', list


_formatResponse = (types) ->
  response =
    status: "Success"
    types: types

list = (req, res) ->

  debtTypeTable.getAll (error, types) ->
    res.header "Content-Type", "application/json"
    if error
      res.status(500).send {error: 'Internal Server Error.'}
    else
      res.send _formatResponse types