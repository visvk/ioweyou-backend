db = require '../db'
async = require 'async'
grunt = require 'grunt'

module.exports =
  exec: (next) ->
    exec(next)

exec = (next) ->
  operations = [
    dropUserFriendshipTable,
    dropDebtTable,
    dropDeptTypeTable,
    dropUserTable,
    dropMigrationTable,
  ]

  async.series operations, (error, result) ->
    if error
      grunt.verbose.errorlns "#{result.length - 1} tables droped successfuly"
    else
      grunt.verbose.oklns "#{result.length} tables droped successfuly"

    next(error, result)


dropMigrationTable = (next) ->
  db.postgres.schema.dropTableIfExists('migration').then ()->
    grunt.verbose.oklns 'Migration table droped successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns error

dropUserTable = (next) ->
  db.postgres.schema.dropTableIfExists('user').then ()->
    grunt.verbose.oklns 'User table droped successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns error

dropUserFriendshipTable = (next) ->
  db.postgres.schema.dropTableIfExists('user_friendship').then ()->
    grunt.verbose.oklns 'UserFriendship table droped successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns error

dropDebtTable = (next) ->
  db.postgres.schema.dropTableIfExists('debt').then ()->
    grunt.verbose.oklns 'Debt table droped successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns error

dropDeptTypeTable = (next) ->
  db.postgres.schema.dropTableIfExists('debt_type').then ()->
    grunt.verbose.oklns 'debt_type table droped successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns error
