config = require '../config'
auth = require '../lib/auth'
userTable = require '../models/user'
userFriendshipTable = require '../models/userFriendship'

module.exports = (app) ->
  app.get '/users/:id', auth.tokenAuth, getById

getById = (req, res) ->
  userId = req.params.id

  userTable.getById userId, (user) =>
    if user
      res.header "Content-Type", "application/json"
      res.send(user)
    else
      res.status(404).send()