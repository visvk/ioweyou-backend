#config = require '../config'
auth = require '../lib/auth'
userTable = require '../models/user'
userFriendshipTable = require '../models/userFriendship'

module.exports = (app) ->
  app.get '/users/:id', getById
  app.get '/users', filters, list
  app.get '/users/me', getMyProfile

_formatResponse = (users) ->
  response =
    status: "Success"
    users: users

filters = (req, res, next) ->

  res.locals.filters = {}

  if req.query.limit
    req.assert('limit', {
      isLength: 'Maximum value is 100.',
      isInt: 'Integer expected.'
    }).isLength(0, 100).isInt()

  if req.query.offset
    req.assert('offset', 'Invalid offset format. Expected integer').isInt()

  if req.validationErrors()
    res.status(404).send(req.validationErrors())
  else
    res.locals.filters =
      limit: req.query.limit
      offset: req.query.offset
      username: req.query.username

    next()

getById = (req, res) ->
  userId = req.params.id

  userTable.getById userId, (user) =>
    if user
      res.header "Content-Type", "application/json"
      res.send _formatResponse [user]
    else
      res.status(404).send()

getMyProfile = (req, res) ->
  userId = req.user.ioweyouId

  userTable.getById userId, (user) =>
    if user
      res.header "Content-Type", "application/json"
      res.send _formatResponse [user]
    else
      res.status(404).send()

list = (req, res) ->
  userTable.getAll res.locals.filters, (error, users) ->
    res.header "Content-Type", "application/json"
    if error
      res.status(500).send {error: 'Internal Server Error.'}
    else if users
      res.send _formatResponse users
    else
      res.status(404).send {error: "Not Found."}