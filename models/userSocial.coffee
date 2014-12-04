db = require '../db'

module.exports =
  create: (fields, next) ->
    create(fields, next)

create = (fields, next) ->
  db.mysql('user_social')
    .insert(fields)
    .returning('id')
    .exec next
