db = require '../db'
moment = require 'moment'

module.exports =
  getById: (id, next) ->
    getById(id, next)
  getUserDebtById: (userId, debtId, next) ->
    getUserDebtById(userId, debtId, next)
  getAll: (userId, filters, next) ->
    getAll(userId, filters, next)
  getSummary: (userId, filters, next) ->
    getSummary(userId, filters, next)
  getCount: (userId, filters, next) ->
    getCount(userId, filters)
  getNbOfEntriesWaitingForAcceptance: (userId, next) ->
    getNbOfEntriesWaitingForAcceptance(userId, next)
  create: (fields, next) ->
    create(fields, next)
  modify: (userId, debtId, fields, next) ->
    modify(userId, debtId, fields, next)
  accept: (userId, debtId, next) ->
    accept(userId, debtId, next)
  reject: (userId, debtId, next) ->
    reject(userId, debtId, next)
  remove: (userId, debtId, next) ->
    remove(userId, debtId, next)

getDebtQuery = ()->
  db.postgres()
  .from('debt')
  .select(
    'debt.*',
    db.postgres.raw('COALESCE(borrower.username, debt.borrower_name) as borrower_name'),
    db.postgres.raw('COALESCE(lender.username, debt.lender_name) as lender_name')
  )
  .join('user as borrower', 'borrower.id', '=', 'debt.borrower_id', 'left')
  .join('user as lender', 'lender.id', '=', 'debt.lender_id', 'left')

create = (fields, next) ->
  db.postgres('debt')
  .insert(fields)
  .returning('id')
  .exec (error, reply) ->
    next(error, reply)

modify = (userId, debtId, fields, next) ->
  db.postgres('debt')
  .update(fields)
  .where('id', '=', debtId)
  .where (sub) ->
    sub.where('borrower_id', userId)
    .orWhere('lender_id', userId)
  .exec (error, reply) ->
    next(error, reply)

getById = (id, next) ->
  getDebtQuery()
  .where('debt.id', id)
  .where('debt.status', '<', '3')
  .exec (error, reply) ->
    if error
      next(error, null)
    else
      next(null, reply[0])

getUserDebtById = (userId, debtId, next) ->
  getDebtQuery()
  .where('debt.id', debtId)
  .where('debt.status', '<', '3')
  .where (sub) ->
    sub.where('borrower.id', userId)
    .orWhere('lender.id', userId)
  .exec (error, reply) ->
    if error
      next(error, null)
    else
      next(null, reply[0])

getNbOfEntriesWaitingForAcceptance = (userId, next) ->
  db.postgres()
  .from('debt')
  .count('id')
  .where('status', '=', 0)
  .where('borrower_id', '=', userId)
  .exec (error, reply) ->
    if error
      next(error, null)
    else
      next(null, reply[0])

getCount = (userId, filters, next) ->
  query = db.postgres()
  .from('debt')
  .count('id')
  .where('status', '!=', 3)
  .where (sub) ->
    sub.where('borrower_id', userId)
    .orWhere('lender_id', userId)

  if filters.from
    query.where('created_at', '>',  moment(filters.from).toISOString())

  if filters.to
    query.where('created_at', '<', moment(filters.to).toISOString())

  if filters.contractor
    query.where (sub) ->
      sub.where('borrower_id', filters.contractor)
      .orWhere('lender_id', filters.contractor)

  if filters.status?
    query.where('status', '=', filters.status)

  if filters.name
    query.where('name', 'ilike', '%'+filters.name+'%')

  query.exec (error, reply) ->
    if error
      next(error, null)
    else
      next(null, reply[0])

getAll = (userId, filters, next) ->
  query = getDebtQuery()
  .where (sub) ->
    sub.where('borrower_id', userId)
    .orWhere('lender_id', userId)
  .where('status', '!=', 3)
  .limit(filters.limit or 8)
  .offset(filters.offset or 0)
  .orderBy('created_at', filters.order or 'desc')

  if filters.from
    query.where('debt.created_at', '>',  moment(filters.from).toISOString())

  if filters.to
    query.where('debt.created_at', '<', moment(filters.to).toISOString())

  if filters.contractor
    query.where (sub) ->
      sub.where('borrower_id', filters.contractor)
      .orWhere('lender_id', filters.contractor)

  if filters.status?
    query.where('status', '=', filters.status)

  if filters.name
    query.where('name', 'ilike', '%'+filters.name+'%')

  query.exec (error, reply) ->
    next(error, reply)

getSummary = (userId, filters, next) ->
  query = db.postgres()
  .from('debt')
  .select('debt.value', 'debt.lender_id', 'debt.borrower_id')
  .where('debt.status', '=', '1')
  .where (sub) ->
    sub.where('borrower_id', userId)
    .orWhere('lender_id', userId)

  if filters.from
    query.where('created_at', '>',  moment(filters.from).toISOString())

  if filters.to
    query.where('created_at', '<', moment(filters.to).toISOString())

  if filters.contractor
    query.where (sub) ->
      sub.where('borrower_id', filters.contractor)
      .orWhere('lender_id', filters.contractor)

  if filters.status?
    query.where('status', '=', filters.status)

  if filters.name
    query.where('name', 'ilike', '%'+filters.name+'%')

  query.exec (error, reply) ->
    if not error
      summary = 0.0
      i = 0
      for row in reply
        if row.borrower_id is Number(userId)
          summary = parseFloat(summary) - parseFloat(row.value)
        if row.lender_id is Number(userId)
          summary = parseFloat(summary) + parseFloat(row.value)
        i = i + 1

      next null, summary.toFixed(2)
    else
      next error, null

accept = (userId, debtId, next) ->
  db.postgres('debt')
  .update({'accepted_at': new Date(), 'status': 1})
  .where('id', '=', debtId)
  .whereIn('status', [0,2]) # open|rejected
  .where('borrower_id', '=', userId)
  .exec (error, reply) ->
    next(error, reply)

reject = (userId, debtId, next) ->
  db.postgres('debt')
  .update({'rejected_at': new Date(), 'status': 2})
  .where('id', '=', debtId)
  .where('status', '=', 0) # open
  .where('borrower_id', '=', userId)
  .exec (error, reply) ->
    next(error, reply)

remove = (userId, debtId, next) ->
  db.postgres('debt')
  .update({'status': 3})
  .where('id', '=', debtId)
  .where('status', '=', 0) # open
  .where('lender_id', '=', userId)
  .exec (error, reply) ->
    next(error, reply)