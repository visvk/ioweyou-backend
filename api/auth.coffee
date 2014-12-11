uuid = require 'node-uuid'
request = require 'request'
bcrypt = require 'bcrypt'
auth = require '../lib/auth'
facebook = require '../lib/facebook'
userTable = require '../models/user'
#userSocialTable = require '../models/userSocial'
userFriendshipTable = require '../models/userFriendship'
config = require '../config'
db = require '../db'
session = require '../models/session'
moment = require 'moment'
_ = require 'lodash'
logger = require './../lib/logger'

module.exports = (app) ->
  app.post '/login',
    validateRequest,
    prepareLocals,
#    fetchIfUserAcceptAppFromFacebook,
#    fetchUserDataFromFacebook,
#    checkIfUserExists,
#    register,
#    fetchFriendsFromFacebook,
    login

  app.post '/register',
    validateRequest,
    prepareLocals,
#    fetchIfUserAcceptAppFromFacebook,
#    fetchUserDataFromFacebook,
    checkIfUserExists,
    register
#    fetchFriendsFromFacebook,
#    login

prepareLocals = (req, res, next) ->
  req.session = session
  res.locals.facebookToken = req.body.pass
  res.locals.isAppAccepted = false
  res.locals.facebookUser = null
  res.locals.existingUser = null
  res.locals.userFriends = null
  res.locals.newlyRegisteredUser = false

  next()

validateRequest = (req, res, next) ->
  req.checkBody('username', 'Username Required.').notEmpty()
  req.checkBody('password', 'Password required').notEmpty()

  if req.validationErrors()
    res.status(400).send()
  else
    next()

login = (req, res) ->
  # TODO: This is not the best solution
  if not res.locals.newlyRegisteredUser
    userTable.findUser req.body.username, (user) ->
      if user and bcrypt.compareSync(req.body.password, user.password)
        loggedUser =
          username: user.username
          first_name: ''
          last_name: ''
          email: ''
          ioweyouToken: uuid.v4()
          ioweyouId: user.id.toString()

        req.session.setUserData loggedUser.ioweyouToken, loggedUser
        res.header "Content-Type", "application/json"
        res.header('Cache-Control', 'private, no-cache, no-store, must-revalidate')
        res.header('Expires', '-1')
        res.header('Pragma', 'no-cache')
        res.status 200
        res.send access_token: loggedUser.ioweyouToken
      else
        res.status(401).send()
        return

  if res.locals.existingUser
    user = res.locals.existingUser

    loggedUser =
      username: user.username
      first_name: user.first_name
      last_name: user.last_name
      email: user.email
      ioweyouToken: uuid.v4()
      ioweyouId: user.id.toString()

    req.session.setUserData loggedUser.ioweyouToken, loggedUser
    res.header "Content-Type", "application/json"
    res.header('Cache-Control', 'private, no-cache, no-store, must-revalidate')
    res.header('Expires', '-1')
    res.header('Pragma', 'no-cache')
    res.status 200
    res.send access_token: loggedUser.ioweyouToken
  else
    res.status(500).send('Login error occured.')

register = (req, res, next) ->
  if res.locals.existingUser
    res.status(400).send({ message: "Username is used"})
    return

  username = res.body.username

  newUser =
    username: username
    password: bcrypt.hashSync(res.body.password, 10)
    first_name: ''
    last_name: ''
    email:''
    date_joined: moment().format('YYYY-MM-DD HH:mm:ss')
    last_login: moment().format('YYYY-MM-DD HH:mm:ss')
    is_active: true

  userTable.create newUser, (error, response) ->
    if not error
      res.locals.newlyRegisteredUser = true
      res.locals.existingUser = newUser
      next()
    else
      res.status(500).send(error)


#fetchIfUserAcceptAppFromFacebook = (req, res, next) ->
#  request.get facebook.getGraphAPI.AppRequest(res.locals.facebookToken), (error, response, appResponseBody) ->
#    if not error && response.statusCode == 200
#      appResponseObject = JSON.parse(appResponseBody)
#
#      if appResponseObject.id is config.facebook.appId
#        next()
#      else
#        res.status(403).send('Forbidden')
#    else
#      res.status(500).send('Facebook Server Error')
#
#fetchUserDataFromFacebook = (req, res, next) ->
#  request.get facebook.getGraphAPI.MeRequest(res.locals.facebookToken), (error, response, meResponseBody) ->
#    if not error && response.statusCode == 200
#      res.locals.facebookUser = JSON.parse(meResponseBody)
#      next()
#    else
#      res.status(500).send('Facebook Server Error')

checkIfUserExists = (req, res, next) ->
  userTable.getBy 'username', req.body.username, (user)->
    if user
      res.locals.existingUser = user

    next()
#
#
#fetchFriendsFromFacebook = (req, res, next) ->
#  if res.locals.newlyRegisteredUser
#    request.get facebook.getGraphAPI.FriendsRequest(res.locals.facebookToken, res.locals.facebookUser.id), (error, response, friendsResponseBody) ->
#      if not error && response.statusCode == 200
#        fetchedFriends = JSON.parse(friendsResponseBody)
#
#        installedFriends = _.filter fetchedFriends.data, (friend) ->
#          return friend.installed is true
#
#        friendsIds = _.map installedFriends, (friend) ->
#          return friend.id
#
#        userTable.findAllByFacebookIds friendsIds, (error, users) ->
#
#          _.forEach users, (user) ->
#            userFriendshipTable.createIfNotExists res.locals.existingUser.id, user.id, (error, reply) ->
#              if error
#                console.log error
#
#        next()
#      else
#        res.status(500).send('Facebook Server Error')
#  else
#    next()