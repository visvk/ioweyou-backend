config = require '../config'
auth = require '../lib/auth'
userTable = require '../models/user'
userFriendshipTable = require '../models/userFriendship'

module.exports = (app) ->
  app.get '/users/:id', auth.tokenAuth, getById
  app.get '/users/me', auth.tokenAuth, getMyProfile

_formatResponse = (users) ->
  response =
    status: "Success"
    users: users

getById = (req, res) ->
  userId = req.params.id

  userTable.getById userId, (user) =>
    if user
      res.header "Content-Type", "application/json"
      res.send _formatResponse [user]
    else
      res.status(404).send()

getMyProfile = (req, res) ->
  userId = res.locals.user.ioweyouId

  userTable.getById userId, (user) =>
    if user
      res.header "Content-Type", "application/json"
      res.send _formatResponse [user]
    else
      res.status(404).send()