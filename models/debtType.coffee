db = require '../db'

module.exports =
  getAll: (next) ->
    getAll(next)

getAll = ( next) ->
  db.postgres()
  .from('debt')
  .select(
    'id',
    'name'
  )
  .exec (error, reply) ->
    next(error, reply)