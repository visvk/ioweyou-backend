moment = require 'moment'
#config = require '../config'
auth = require '../lib/auth'
debtsTable = require '../models/debt'
userTable = require '../models/user'
userFriendshipTable = require '../models/userFriendship'
userManager = require '../managers/user'
#clientTable = require '../models/userClient'
session = require '../models/session'
emiter = require '../lib/eventEmiter'
#
logger = require './../lib/logger'

module.exports = (app) ->
  app.get '/debts', auth.tokenAuth, filters, list
#  app.get '/debts/summary', auth.tokenAuth, filters, summary
  app.get '/debts/count', auth.tokenAuth, filters, count
  app.post '/debts',auth.tokenAuth, create

  app.get '/debts/:id', auth.tokenAuth, one
  app.patch '/debts/:id', auth.tokenAuth, modify
  app.post '/debts/:id/accept', auth.tokenAuth, accept
  app.post '/debts/:id/reject', auth.tokenAuth, reject
  app.delete '/debts/:id', auth.tokenAuth, remove


_formatResponse = (debts) ->
  response =
    status: "Success"
    debts: debts

filters = (req, res, next) ->

  res.locals.filters = {}

  if req.query.limit
    req.assert('limit', {
      isLength: 'Maximum value is 100.',
      isInt: 'Integer expected.'
    }).isLength(0, 100).isInt()

  if req.query.offset
    req.assert('offset', 'Invalid offset format. Expected integer').isInt()

  if req.query.from
    req.assert('from', 'Invalid from date format. Expected POSIX time').isInt()

  if req.query.to
    req.assert('to', 'Invalid from date format. Expected POSIX time').isInt()

  if req.query.contractor
    req.assert('contractor', 'Invalid contractor format. Expected integer.').isInt()

  if req.query.status
    req.assert('status', 'Invalid status format. Expected integer.').isInt()

  if req.query.order
    req.assert('order', 'Invalid order format. Expected asc or desc.').isIn(['asc', 'desc'])

  if req.validationErrors()
    res.status(404).send(req.validationErrors())
  else
    res.locals.filters =
      limit: req.query.limit
      offset: req.query.offset
      from: Number(req.query.from)
      to: Number(req.query.to)
      contractor: req.query.contractor
      status: req.query.status
      order: req.query.order
      name: req.query.name

    next()

one = (req, res) ->
  req.assert('id', 'Invalid debts ID').notEmpty().isInt()

  if req.validationErrors()
    logger.warn "Debt validation Error: ", req.validationErrors()
    res.status(400).send()
    return

  debtsId = req.params.id
  userId = res.locals.user.ioweyouId

  debtsTable.getUserDebtById userId, debtsId, (error, debts) ->
    res.header "Content-Type", "application/json"
    if error
      logger.warn "Debt one error: ", error
      res.status(500).send()
    else if debts
      res.send _formatResponse [debts]
    else
      res.status(404).send()


list = (req, res) ->
  userId = res.locals.user.ioweyouId

  debtsTable.getAll userId, res.locals.filters, (error, debts) ->
    res.header "Content-Type", "application/json"
    if error
      logger.warn "Debt List Error: ", error
      res.status(500).send {error: 'Internal Server Error.'}
    else if debts
      res.send _formatResponse debts
    else
      res.status(404).send {error: "Not Found."}


summary = (req, res) ->
  userId = res.locals.user.ioweyouId

  debtsTable.getSummary userId, res.locals.filters, (error, summary) ->
    res.header "Content-Type", "application/json"
    if error
      res.status(500).send({error: 'Internal Server Error.'})
    else if summary
      res.send JSON.stringify({summary: summary})
    else
      res.status(404).send {error: 'Not Found.'}


count = (req, res) ->
  userId = res.locals.user.ioweyouId

  debtsTable.getCount userId, res.locals.filters, (error, count) ->
    res.header "Content-Type", "application/json"
    if error
      res.status(500).send("Internal Server Error.")
    else if count
      res.send(count)
    else
      res.status(404).send("Not Found.")


create = (req, res) ->
  # TODO: Check body
#  req.checkBody('borrower_id', 'Borrower id required.').notEmpty()
#  req.checkBody('borrower_name', 'Borrower name required.').notEmpty()
#  req.checkBody('lender_id', 'lender id required.').notEmpty()
#  req.checkBody('lender_name', 'lender name required.').notEmpty()
  req.checkBody('type_id', 'Type id required.').notEmpty()
  req.checkBody('value', 'Value required.').isFloat()

  if req.validationErrors()
    res.status(400).send()
    return

  values =
    name: ''
    value: 0
    status: 0
    lender_id: null
    borrower_id: null
    lender_name: null
    borrower_name: null
    debt_type_id: 1
    created_at: moment().format('YYYY-MM-DD HH:mm:ss')
    updated_at: moment().format('YYYY-MM-DD HH:mm:ss')

  userId = res.locals.user.ioweyouId
  values.name = req.body.name

  if userId is req.body.borrower_id
    friendId = req.body.lender_id
    values.lender_id = friendId
    values.lender_name = req.body.lender_name or ''
    values.borrower_id = req.body.borrower_id
    values.borrower_name = ''
  else if userId is req.body.lender_id
    friendId = req.body.borrower_id or null
    values.borrower_id = friendId
    values.borrower_name = req.body.borrower_name or ''
    values.lender_id = req.body.lender_id
    values.lender_name = ''

  values.value = req.body.value
  values.debt_type_id = req.body.debt_type_id

  # Save debt without friendship
  if not friendId
    debtsTable.create values, (error, debts)->
      if error
        res.status(404).send()
      else
        res.status(201).send({ message: "Success"})

  if friendId
    userFriendshipTable.friendshipsExists userId, [friendId], (exists) ->
      if exists
        debtsTable.create values, (error, debts)->
          if error
            res.status(404).send()
          else
            res.status(201).send({ message: "Success"})


accept = (req, res) ->
  req.assert('id', 'Invalid uid').notEmpty().isInt()

  if req.validationErrors()
    res.status(400).send()
    return

  debtsId = req.params.id
  userId = res.locals.user.ioweyouId

  debtsTable.accept userId, debtsId, (error, isModified) ->
    if error
      res.status(400).send {isModified: isModified}
    else
      res.status(200).send {isModified: isModified}


reject = (req, res) ->
  req.assert('id', 'Invalid uid').notEmpty().isInt()

  if req.validationErrors()
    res.status(400).send()
    return

  debtsId = req.params.id
  userId = res.locals.user.ioweyouId

  debtsTable.reject userId, debtsId, (error, isModified) ->
    if error
      res.status(500).send()
    else
      res.status(200).send {isModified: isModified}


remove = (req, res) ->
  req.assert('id', 'Invalid uid').notEmpty().isInt()

  if req.validationErrors()
    res.status(400).send(req.validationErrors())
    return

  debtsId = req.params.id
  userId = res.locals.user.ioweyouId

  debtsTable.remove userId, debtsId, (error, isModified) ->
    res.header "Content-Type", "application/json"
    if error
      res.status(500).send()
    else if isModified
      res.status(204).send {isModified: isModified}
    else
      res.status(404).send()


modify = (req, res) ->
  req.assert('id', 'Invalid uid').notEmpty().isInt()
  req.checkBody('value', 'Value must be number').isFloat()

  if req.validationErrors()
    res.status(400).send(req.validationErrors())
    return

  debtsId = req.params.id
  userId = res.locals.user.ioweyouId
  name = req.body.name
  value = req.body.value

  values =
    name: name
    value: value
    updated_at: moment().format('YYYY-MM-DD HH:mm:ss')

  debtsTable.modify userId, debtsId, values, (error, isModified) ->
    if error
      res.status(500).send()
    else
      res.status(200).send {isModified: isModified}



