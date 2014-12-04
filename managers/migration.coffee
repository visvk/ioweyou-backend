migrationTable = require '../models/migration'
moment = require 'moment'
db = require '../db'

module.exports =
  initialize: (next) ->
    initialize(next)
  setVersion: (version, next) ->
    setVersion(version, next)


initialize = (next) ->

  db.mysql.schema.hasTable('migration').then (exists)->
    if not exists
      db.mysql.schema.createTable 'migration', (table)->
        table.bigIncrements('id')
        table.integer('version')
        table.timestamps()
      .then ()->
        console.log 'Migration table created successfully.'

        fields =
          version: 0
          created_at: moment().format('YYYY-MM-DD HH:mm:ss')
          updated_at: null

        migrationTable.create fields, (error, reply) ->
          if not error
            next('Migration initialized successfully.')
          else
            next(error)
    else
      next('Table migration already exists.')


setVersion = (version, next) ->

  fields =
    version: 0
    updated_at: moment().format('YYYY-MM-DD HH:mm:ss')

  migrationTable.modify fields, (error, reply) ->
    if not error and reply > 0
      message = " Migration version updated successfully, current version #{version}"
    else if not error and reply is 0
      message = " Migration version wasn't updated."
    else
      message = error

    next(message)


