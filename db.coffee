knex = require 'knex'
config = require './config'
redis = require 'redis'

module.exports =
	mysql: knex.initialize(config.database)