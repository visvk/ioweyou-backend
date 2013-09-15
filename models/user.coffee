db = require '../db'

module.exports =
  getById: (id, next) ->
    getById(id, next)
  getBy: (fieldName, value, next) ->
    getBy(fieldName, value, next)
  getByFacebookId: (value, next) ->
    getByFacebookId(value, next)
  getFriends: (userId, next) ->
    getFriends(userId, next)


getById = (id, next) ->
  db.postgres()
    .from('auth_user')
    .select(
      'auth_user.id',
      'auth_user.username',
      'auth_user.first_name',
      'auth_user.last_name',
      'auth_user.email',
      'sau.uid'
    )
    .join('social_auth_usersocialauth as sau', 'sau.user_id', '=', 'auth_user.id', 'left')
    .where('auth_user.id', id)
    .exec (error, reply) ->
      if not error
        next(reply[0])
      else
        next(false)


getBy = (fieldName, value, next) ->
  db.postgres()
    .from('auth_user')
    .select(
      'auth_user.id',
      'auth_user.username',
      'auth_user.first_name',
      'auth_user.last_name',
      'auth_user.email',
      'sau.uid'
    )
    .join('social_auth_usersocialauth as sau', 'sau.user_id', '=', 'auth_user.id', 'left')
    .where(fieldName, value)
    .exec (error, reply) ->
      if not error
        next(reply[0])
      else
        next(false)

getByFacebookId = (value, next) ->
  getBy('sau.uid', value, next)


getFriends = (id, next) ->
  subQuery = db.postgres.Raw('
    SELECT uf.creator_id AS friend
    FROM user_friendship uf, auth_user au
    WHERE au.id = uf.friend_id AND  au.id = '+id+'
    UNION
    SELECT uf.friend_id AS friend
    FROM user_friendship uf, auth_user au
    WHERE au.id = uf.creator_id AND  au.id = '+id
  )

  db.postgres()
    .from('auth_user')
    .select(
      'auth_user.username',
      'auth_user.first_name',
      'auth_user.last_name',
      'auth_user.email',
      'sau.uid'
    )
    .whereIn('auth_user.id', subQuery)
    .join('social_auth_usersocialauth as sau', 'sau.user_id', '=', 'auth_user.id', 'left')
    .exec (error, reply) ->
      if not error
        next(reply)
      else
        next(false)