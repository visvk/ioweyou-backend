db = require '../db'
async = require 'async'
grunt = require 'grunt'

module.exports =
  exec: (next) ->
    exec(next)

exec = (next) ->
  operations = [
    createMigrationTable,
    createUserTable,
    createUserFriendshipTable,
    createDeptTypeTable,
    createDeptTable
  ]

  async.series operations, (error, result) ->
    if error
      grunt.verbose.errorlns "#{result.length - 1} tables created successfuly"
    else
      grunt.verbose.oklns "#{result.length} tables created successfuly"

    next(error, result)


createMigrationTable = (next) ->
  db.postgres.schema.createTable 'migration', (table)->
    table.bigIncrements('id')
    table.integer('version')
    table.timestamps()
  .then () ->
    grunt.verbose.oklns 'Migration table created successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns 'Migration table was not created, error occurred.'
    next(error)


createUserTable = (next) ->
  db.postgres.schema.createTable 'user', (table)->
    table.bigIncrements('id')
    table.string('password', 128).notNullable()
    table.string('username', 30).notNullable().unique().index()
    table.string('first_name', 30)
    table.string('last_name', 30)
    table.string('email', 75).index()
    table.string('token', 255)
    table.boolean('is_active').defaultTo(true)
    table.timestamps()
  .then () ->
    grunt.verbose.oklns 'User table created successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns 'User table was not created, error occurred.'
    next(error)

createUserFriendshipTable = (next) ->
  db.postgres.schema.createTable 'user_friendship', (table)->
    table.bigIncrements('id')
    table.integer('creator_id')
    .notNullable()
    .unsigned()
    .references('id')
    .inTable('user')
    .onDelete("CASCADE")
    table.integer('friend_id')
    .notNullable()
    .unsigned()
    .references('id')
    .inTable('user')
    .onDelete("CASCADE")
    table.timestamp('created_at')
  .then ()->
    grunt.verbose.oklns 'UserFriendship table created successfully.'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns 'UserFriendship table was not created, error occurred.'
    next(error)

createDeptTypeTable = (next) ->
  db.postgres.schema.createTable 'debt_type', (table)->
    table.bigIncrements('id')
    table.string('name', 255).notNullable()
    table.timestamps()
  .then ()->
    grunt.verbose.oklns 'debt_type table created successfully'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns 'debt_type table was not created, error occurred.'
    next(error)

createDeptTable = (next) ->
  db.postgres.schema.createTable 'debt', (table)->
    table.bigIncrements('id')
    table.string('name', 255).notNullable()
    table.float('value', 6, 2)
    table.tinyInteger('status')
    table.integer('borrower_id')
    .notNullable()
    .unsigned()
    .references('id')
    .inTable('user')
    .onDelete("SET NULL")
    table.string('borrower_name', 255)
    table.integer('lender_id')
    .notNullable()
    .unsigned()
    .references('id')
    .inTable('user')
    .onDelete("SET NULL")
    table.integer('debt_type_id')
    .notNullable()
    .unsigned()
    .references('id')
    .inTable('debt_type')
    .onDelete("SET NULL")
    table.string('lender_name', 255)
    table.timestamp('accepted_at')
    table.timestamp('rejected_at')
    table.timestamp('deleted_at')
    table.timestamps()
  .then ()->
    grunt.verbose.oklns 'debt table created successfully'
    next(null, true)
  , (error) ->
    grunt.verbose.errorlns 'debt table was not created, error occurred.'
    next(error)
