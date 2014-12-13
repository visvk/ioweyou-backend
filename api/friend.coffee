#config = require '../config'
auth = require '../lib/auth'
userTable = require '../models/user'
userFriendshipTable = require '../models/userFriendship'

module.exports = (app) ->
  app.get '/friends', auth.tokenAuth, getFriends
  app.post '/friends', auth.tokenAuth, addFriend


_formatResponse = (friends) ->
  response =
    status: "Success"
    friends: friends


getFriends = (req, res) ->
  userId = res.locals.user.ioweyouId

  userTable.getFriends userId, (friends) =>
    if friends
      res.header "Content-Type", "application/json"
      res.send _formatResponse friends
    else
      res.status(404).send()

addFriend = (req, res) ->
  userId = res.locals.user.ioweyouId

  friendId = req.body.user_id

  userFriendshipTable.createIfNotExists userId, friendId, (error, reply) ->
    res.header "Content-Type", "application/json"
    if error
      res.status(404).send()
      return

    res.send({ message: "Success"})
