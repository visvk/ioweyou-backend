db = require '../db'

module.exports =
  create: (fields, next) ->
    create(fields, next)
  getById: (id, next) ->
    getById(id, next)
  getBy: (fieldName, value, next) ->
    getBy(fieldName, value, next)
#  getByFacebookId: (value, next) ->
#    getByFacebookId(value, next)
  getFriends: (userId, next) ->
    getFriends(userId, next)
#  findAllByFacebookIds: (facebookIds, next) ->
#    findAllByFacebookIds(facebookIds, next)


create = (fields, next) ->
  db.postgres('user')
  .insert(fields)
  .returning('id')
  .exec next


getBy = (fieldName, value, next) ->
  db.postgres()
  .from('user')
  .select(
    'user.id',
    'user.username'
  )
  .where(fieldName, value)
  .exec (error, reply) ->
    if not error
      next(reply[0])
    else
      next(false)


getById = (id, next) ->
  getBy('user.id', id, next)

# TODO: Escape id
getFriends = (id, next) ->
  subQuery = db.postgres.raw('
    SELECT uf.creator_id AS friend
    FROM user_friendship uf, "user" u
    WHERE u.id = uf.friend_id AND u.id = '+id+'
    UNION
    SELECT uf.friend_id AS friend
    FROM user_friendship uf, "user" u
    WHERE u.id = uf.creator_id AND u.id = '+id
  )

  db.postgres()
  .from('user')
  .select(
    'user.id',
    'user.username'
  )
  .whereIn('user.id', subQuery)
  .orderBy('user.username', 'ASC')
  .exec (error, reply) ->
    if not error
      next(reply)
    else
      next(false)